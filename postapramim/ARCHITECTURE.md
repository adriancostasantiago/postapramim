# Arquitetura — Posta Pra Mim

## 1. Visão geral

Clean Architecture organizada **Feature First**, com Riverpod como único
mecanismo de estado e injeção de dependência. Nenhuma tela acessa o Supabase
diretamente — tudo passa por `UI → Controller → UseCase → Repository →
Datasource → Supabase`.

## 2. Perfis de usuário

| Perfil | Acesso |
|---|---|
| Cliente | Cria solicitações, acompanha status, gerencia endereços/perfil |
| Coletador | Vê coletas atribuídas, executa rota, escaneia código, atualiza status |
| Administrador | Acesso total (preparado para painel web futuro) |

## 3. Modelagem do banco (resumo)

```
usuarios ──┬── clientes (1:1)
           ├── coletadores (1:1)
           └── administradores (1:1)

enderecos ──> usuarios

solicitacoes ──> usuarios (cliente_id, coletador_id)
             ──> enderecos

coletas ──> solicitacoes
        ──> usuarios (coletador_id)

rotas ──> usuarios (coletador_id)   -- array de coleta_ids do dia

historico_status ──> solicitacoes   -- auditoria, populada via trigger

notificacoes ──> usuarios
arquivos ──> usuarios / solicitacoes / coletas
configuracoes ──> usuarios (1:1)
```

Scripts completos em `database/schema.sql` (tabelas/triggers) e
`database/rls_policies.sql` (RLS + Storage policies).

### Fluxo de status da solicitação

```
aguardando → atribuida → aceita → em_rota → chegou_ao_local → coletada
    → em_transporte → recebida → concluida
                                        (ou cancelada, a qualquer momento)
```

Cada transição é registrada automaticamente em `historico_status` via
trigger (`registrar_historico_status`) e dispara push notification via
Edge Function (`notificar_mudanca_status`).

## 4. Regras de RLS (resumo)

- **Cliente**: `select`/`update` apenas onde `cliente_id = auth.uid()`.
- **Coletador**: `select`/`update` apenas onde `coletador_id = auth.uid()`.
- **Administrador**: bypassa tudo via função `is_admin()`.
- **Storage**: fotos de coleta/embalagem/comprovante só acessíveis pelos
  participantes da solicitação (`storage.foldername(name)` = `solicitacao_id`);
  avatares são públicos para leitura.

## 5. Estratégia Offline

Camada: **Hive** (cache) + **connectivity_plus** (detecção de rede).

1. Toda leitura remota bem-sucedida grava uma cópia em uma box do Hive
   (ex.: `SolicitacoesLocalDatasource.salvarLista`).
2. Se o dispositivo estiver offline (`ConnectivityService.isOnline == false`),
   o Repository retorna diretamente o cache local — a UI nunca trava
   esperando rede.
3. Ao detectar retorno da conectividade, `SyncOrchestrator`
   (`shared/providers/shared_providers.dart`) dispara a re-sincronização de
   cada feature (`controller.sincronizar()`), atualizando o cache com dados
   frescos do servidor.
4. Boxes reservadas: `usuário` (sessão), `rota do dia`, `coletas do dia`,
   `configurações`, `cache genérico` — ver `AppConstants`.

> Regra de ouro: o Datasource remoto nunca sabe que existe cache; quem decide
> ler de qual fonte é sempre o **Repository** — mantendo o Datasource puro e
> testável isoladamente.

## 6. Estratégia Realtime

Usamos o método `.stream()` do `supabase_flutter`, que abre um canal
Realtime e emite uma nova lista a cada `INSERT`/`UPDATE`/`DELETE` que
casar com o filtro (`SolicitacoesRemoteDatasource.observarPorCliente`).

Eventos cobertos automaticamente pelo mesmo mecanismo:
`nova coleta`, `coleta aceita`, `coleta cancelada`, `coleta concluída`.

Exposto à UI como `StreamProvider` (`minhasSolicitacoesRealtimeProvider`),
consumido com `.when(loading:, error:, data:)` — sem necessidade de
polling manual.

Para o chat/mensagens (feature futura), o mesmo padrão se aplica: um canal
por conversa, filtrado pelo `solicitacao_id`.

## 7. Estratégia de Notificações (Push)

```
Trigger SQL (mudança de status)
        │  pg_net.http_post
        ▼
Edge Function `enviar-push-notification`
        │  busca fcm_token em `usuarios`
        ▼
Firebase Cloud Messaging
        │
        ▼
Dispositivo do Cliente/Coletador (FCM SDK no app)
```

No app, `NotificationService` (`core/services/notification_service.dart`):

- solicita permissão e obtém o token do dispositivo;
- salva/atualiza o token em `usuarios.fcm_token`;
- escuta mensagens em foreground e taps em background
  (`FirebaseMessaging.onMessage` / `onMessageOpenedApp`) para navegar via
  GoRouter até a tela relevante (deep link).

## 8. Providers Riverpod — padrão de DI

Cada feature segue a mesma cadeia de providers gerados via
`@riverpod` (riverpod_generator):

```
xxxRemoteDatasourceProvider   (ou local)
        │
xxxRepositoryProvider          (implementa a interface do domain)
        │
xxxUsecaseProvider (um por caso de uso)
        │
xxxController (Notifier/AsyncNotifier)  ← consumido pela UI
```

Isso garante que trocar a fonte de dados (ex.: Supabase → outro backend)
exige alterar **apenas o Datasource**, sem tocar em UseCase, Controller
ou UI.

## 9. Result Pattern & tratamento de erros

- `Datasource` lança `Exception`s tipadas (`AuthException`,
  `ServerException`, `CacheException`...).
- `Repository` captura essas exceptions e as converte em `Failure`
  (`core/error/failures.dart`), retornando sempre um `Result<T>`
  (`core/error/result.dart`).
- `Controller`/UI consomem via `.fold(onSuccess:, onFailure:)` — nunca
  há `try/catch` na camada de apresentação.

## 10. Design System / Tema

- Cores: `AppColors` (amarelo predominante, azul institucional, muito
  branco) — `lib/app/theme/app_colors.dart`.
- Tipografia: `AppTextStyles`.
- `ThemeData` completo (light + dark, Material 3) em `AppTheme`.
- Componentes base compartilhados: `AppButton`, `AppTextField`, `AppCard`,
  `EmptyState`/`ErrorState`/`LoadingIndicator`.

## 11. Boas práticas adotadas

- **SOLID**: interfaces em toda fronteira entre camadas (`AuthRepository`,
  `SolicitacoesRepository`, datasources abstratos).
- **Entities ≠ Models**: entities são puras (domínio); models carregam
  `@JsonKey`/Freezed e só existem na camada `data`.
- **Um UseCase = uma responsabilidade**, sempre com método `call()` —
  permite compor fluxos complexos combinando UseCases pequenos.
- **Result Pattern** elimina exceptions vazando para a UI.
- **Logger centralizado** (`LoggerService`) — nenhum `print` no código.
- **Nenhum widget acessa Supabase/Hive diretamente** — sempre via provider.
- Nomes de arquivos, classes e providers em português (domínio) mas
  termos técnicos (Datasource, Repository, UseCase) mantidos em inglês
  por serem convenções da própria Clean Architecture.

## 12. Testes (preparado)

Estrutura sugerida (não incluída neste scaffold para focar na arquitetura
de produção, mas o desenho já viabiliza 100% de cobertura):

```
test/
└── features/
    └── auth/
        ├── domain/usecases/login_usecase_test.dart   (mocka AuthRepository)
        └── data/repositories/auth_repository_impl_test.dart (mocka Datasource)
```

Como toda dependência é injetada por interface, qualquer camada é testável
isoladamente com `mocktail`/`mockito`, sem precisar de um Supabase real.
