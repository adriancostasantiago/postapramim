# Roadmap de Desenvolvimento — Posta Pra Mim

Sprints de 1 semana (ajuste conforme o tamanho do time). Cada sprint entrega
algo demonstrável. Segue exatamente a ordem de dependência técnica do app.

---

## Sprint 0 — Fundação (infra)
- Criar projeto Supabase; rodar `schema.sql` e `rls_policies.sql`.
- Configurar Firebase (Android/iOS) para FCM.
- Configurar variáveis via `--dart-define` (ou `.env` + `flutter_dotenv`).
- Rodar `flutter pub get` + `build_runner build` e validar que o app sobe
  até a `SplashPage`.
- CI básico (lint + `flutter analyze` + testes).

**Entrega:** app compila, conecta ao Supabase, mostra Splash.

---

## Sprint 1 — Autenticação (MVP)
- Validar fluxo completo de `auth`: cadastro (cliente e coletador), login,
  logout, recuperação de senha.
- Implementar Login com Google (OAuth já modelado no Datasource).
- Redirecionamento por perfil já funciona via `GoRouter` (`app_router.dart`).
- Testes unitários de `LoginUsecase` e `AuthRepositoryImpl`.

**Entrega:** qualquer perfil consegue criar conta e entrar no app certo.

---

## Sprint 2 — Perfil & Endereços
- Completar `perfil`: upload de avatar (bucket `avatares`), edição de
  nome/telefone (`UpdateProfileUsecase` seguindo o padrão de `auth`).
- Nova feature interna `enderecos` (ou dentro de `perfil`): CRUD de
  endereços do cliente, com busca de CEP via **ViaCEP** (Dio).
- Tela "Nova Solicitação" passa a usar endereço real (hoje mockado).

**Entrega:** cliente cadastra endereço e usa no fluxo de solicitação.

---

## Sprint 3 — Solicitações (fluxo principal do cliente)
- Já implementado como feature de referência: revisar e ligar o endereço
  real (Sprint 2) na criação.
- Tela de histórico com Realtime já funcional — validar em dispositivo real.
- Implementar cancelamento (`CancelarSolicitacaoUsecase` já existe na
  camada de domínio — falta o botão na UI de detalhe).
- Testes de `SolicitacoesRepositoryImpl` (online, offline, fallback de erro).

**Entrega:** cliente cria, acompanha (realtime) e cancela solicitações.

---

## Sprint 4 — Coletas (lado do Coletador)
- Implementar `data`/`domain` de `coletas` seguindo **exatamente** o padrão
  de `solicitacoes` (Datasource remoto + local Hive + Repository +
  UseCases: listar, aceitar, iniciar, concluir).
- Dashboard do coletador passa a mostrar números reais (resumo do dia).
- Tela "Minhas Coletas" consumindo o Realtime de `coletas`.
- Trigger no banco para atribuição automática (Edge Function
  `atribuir-coleta`, por proximidade/disponibilidade) ou atribuição manual
  pelo admin — escolher conforme o MVP.

**Entrega:** coletador vê e aceita coletas atribuídas a ele, com atualização
automática de status.

---

## Sprint 5 — Scanner & Evidências
- Ligar `ScannerPage` ao fluxo real: código lido atualiza
  `coletas.codigo_escaneado` e avança status para `coletada`.
- Upload de fotos (coleta/embalagem) e comprovante via `image_picker` +
  Supabase Storage (buckets já criados e protegidos por RLS).
- Registrar metadados em `arquivos`.

**Entrega:** coletador escaneia o código e anexa evidências da coleta.

---

## Sprint 6 — Rotas & Mapa
- Implementar feature `rotas`: listar coletas do dia, desenhar no
  `GoogleMap` (marcadores + polyline), mostrar distância/tempo estimado.
- Botão "Iniciar rota" grava `iniciada_em` em `rotas`.
- Cache offline da rota do dia (box `boxRotaDoDia`) para funcionar sem
  internet durante o trajeto.

**Entrega:** coletador visualiza e navega pela rota do dia, mesmo offline.

---

## Sprint 7 — Notificações Push
- Deploy da Edge Function `enviar-push-notification` (Supabase Functions +
  Firebase Admin SDK) — trigger SQL já criado em `schema.sql`.
- Popular a tabela `notificacoes` a partir da mesma Edge Function, para
  a `NotificacoesPage` funcionar mesmo sem push (histórico in-app).
- Deep link: tap na notificação abre a tela correta via GoRouter.

**Entrega:** mudanças de status geram push + notificação in-app.

---

## Sprint 8 — Painel Administrativo (preparação)
- Confirmar que toda a camada `domain`/`data` já suporta um cliente Flutter
  Web (ou outro client) reaproveitando os mesmos Repositories/UseCases.
- Criar rotas `/admin/*` básicas: lista de usuários, solicitações e coletas
  (somente leitura), aproveitando `is_admin()` no RLS.

**Entrega:** esqueleto do painel admin funcional (mobile ou web).

---

## Sprint 9 — Polimento & Dark Mode
- Revisar `ThemeData` dark em todas as telas.
- Estados vazios/erro (`EmptyState`/`ErrorState`) em 100% das listagens.
- Acessibilidade básica (tamanhos de toque, contraste).
- Ajustar Design System com telas reais fornecidas pelo time de produto.

**Entrega:** app visualmente consistente em light e dark mode.

---

## Sprint 10 — Qualidade & Performance
- Cobertura de testes unitários em todos os UseCases e Repositories
  (mock de Datasources).
- Testes de widget das telas críticas (login, nova solicitação, scanner).
- Auditoria de RLS (tentar acessar dados de outro usuário e confirmar bloqueio).
- Revisão de índices no Postgres com base em queries reais.

**Entrega:** suíte de testes verde, RLS auditado.

---

## Sprint 11 — Preparação para Produção
- Configurar ambientes (dev/staging/prod) via `--dart-define` diferentes
  por flavor.
- Assinatura de release Android (keystore) e certificados iOS.
- Política de privacidade / termos de uso reais nas telas já criadas.
- Monitoramento de erros (ex.: Sentry) plugado ao `LoggerService`.
- Checklist de store (ícones, screenshots, descrição) para Play Store/App Store.

**Entrega:** build de release pronta para submissão nas lojas.

---

### Backlog contínuo (pós-MVP)
- Chat em tempo real entre cliente e coletador (Realtime, mesmo padrão).
- Avaliação do coletador pelo cliente ao concluir a coleta.
- Multi-idioma (estrutura `intl` já presente).
- Reagendamento de coleta pelo cliente.
- Métricas/dashboard analítico para o administrador.
