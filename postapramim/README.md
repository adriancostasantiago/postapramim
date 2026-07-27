# Posta Pra Mim 📦

App de **logística reversa**: o cliente solicita a coleta de uma encomenda
para devolução, um **coletador** (motorista) aceita e executa a coleta, e um
**administrador** supervisiona toda a operação.

Stack: **Flutter + Riverpod + GoRouter + Supabase** (Auth, Postgres, Storage,
Realtime, Edge Functions), Clean Architecture organizada **Feature First**.

---

## 🚀 Como rodar

```bash
flutter pub get

# Gera os arquivos .freezed.dart / .g.dart de todas as features
dart run build_runner build --delete-conflicting-outputs

# Rode informando as credenciais do seu projeto Supabase
flutter run \
  --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY
```

Antes de rodar, execute no **SQL Editor do Supabase**, nesta ordem:

1. `database/schema.sql` — tabelas, enums, triggers, buckets de Storage.
2. `database/rls_policies.sql` — Row Level Security e políticas de Storage.

> 📄 Veja `ARCHITECTURE.md` para o detalhamento de cada camada e
> `ROADMAP.md` para o plano de sprints do MVP até produção.

---

## 📁 Estrutura de pastas

```
lib/
├── main.dart                     # bootstrap: Hive, Supabase, Firebase
├── app/
│   ├── app.dart                  # MaterialApp.router
│   ├── router/                   # GoRouter + rotas protegidas
│   └── theme/                    # ThemeData, cores, tipografia (Design System)
├── core/
│   ├── constants/                # constantes de app e do Supabase (tabelas, buckets)
│   ├── error/                    # Failure, Exception, Result Pattern
│   ├── network/                  # Dio (somente APIs externas, ex.: ViaCEP)
│   ├── services/                 # Supabase, Logger, Notificações, Conectividade
│   └── utils/                    # validators, formatters
├── shared/
│   ├── widgets/                  # AppButton, AppTextField, AppCard, estados
│   └── providers/                # conectividade, Hive boxes, sync orchestrator
└── features/
    ├── auth/                     # login, cadastro, recuperação de senha
    ├── dashboard/                 # home do cliente / painel do coletador
    ├── solicitacoes/             # CRUD + realtime + offline (implementação de referência)
    ├── coletas/                  # execução da coleta, scanner
    ├── rotas/                    # mapa e otimização da rota do dia
    ├── perfil/                   # dados do usuário, avatar
    ├── notificacoes/             # lista de notificações
    └── configuracoes/            # preferências do app
```

Cada feature segue **sempre** a mesma estrutura interna:

```
feature/
├── data/
│   ├── datasources/   # única camada que fala com Supabase (ou Hive)
│   ├── models/        # Freezed + JsonSerializable, espelham as tabelas
│   └── repositories/  # implementação concreta do contrato de domínio
├── domain/
│   ├── entities/      # objetos puros de negócio (sem Supabase/JSON)
│   ├── repositories/  # interfaces (abstrações)
│   └── usecases/      # uma classe por caso de uso, `call()` único
└── presentation/
    ├── controllers/   # estados imutáveis (ex.: AuthState)
    ├── providers/     # DI via Riverpod + AsyncNotifier/Notifier
    ├── pages/         # telas (ConsumerWidget/ConsumerStatefulWidget)
    └── widgets/        # widgets específicos da feature
```

### Fluxo de dependência (obrigatório, sem exceções)

```
UI  →  Controller  →  UseCase  →  Repository (interface)  →  Datasource  →  Supabase
```

Nenhuma `Page`, `Widget` ou `Controller` importa `supabase_flutter` diretamente.

---

## 🧩 Features de referência já implementadas por completo

- **`auth`** — login (e-mail/senha, Google, Apple preparado, Magic Link),
  cadastro, recuperação de senha, persistência de sessão, logout.
- **`solicitacoes`** — CRUD completo, **Realtime** (stream direto do Supabase)
  e **offline-first** (cache em Hive com fallback automático).

As demais features (`coletas`, `rotas`, `perfil`, `notificacoes`,
`configuracoes`, `dashboard`) já têm a estrutura de pastas e páginas
funcionais criadas; a camada `data`/`domain` segue **exatamente o mesmo
padrão** de `solicitacoes` (ver comentários `// TODO` nos arquivos e a
seção "Roadmap" para a ordem sugerida de implementação).

---

## 📚 Documentos deste projeto

| Arquivo | Conteúdo |
|---|---|
| `ARCHITECTURE.md` | Modelagem do banco, estratégias offline/realtime/notificações, boas práticas |
| `ROADMAP.md` | Sprints do MVP até a versão de produção |
| `database/schema.sql` | Tabelas, enums, triggers, buckets |
| `database/rls_policies.sql` | RLS de tabelas e do Storage |
