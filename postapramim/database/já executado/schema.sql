-- =====================================================================
-- POSTA PRA MIM — SCHEMA POSTGRESQL (SUPABASE)
-- =====================================================================
-- Execute este arquivo no SQL Editor do Supabase (ou via supabase db push).
-- Ordem: extensions -> tipos -> tabelas -> índices -> triggers -> funções.
-- RLS e políticas ficam em rls_policies.sql (executar depois deste).
-- =====================================================================

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- TIPOS ENUM
-- ---------------------------------------------------------------------
create type perfil_usuario as enum ('cliente', 'coletador', 'administrador');

create type status_solicitacao as enum (
  'aguardando',
  'atribuida',
  'aceita',
  'em_rota',
  'chegou_ao_local',
  'coletada',
  'em_transporte',
  'recebida',
  'concluida',
  'cancelada'
);

-- ---------------------------------------------------------------------
-- USUARIOS (espelha auth.users; 1:1 via trigger handle_new_user)
-- ---------------------------------------------------------------------
create table usuarios (
  id uuid primary key references auth.users (id) on delete cascade,
  nome text not null,
  email text not null unique,
  telefone text,
  avatar_url text,
  perfil perfil_usuario not null default 'cliente',
  email_verificado boolean not null default false,
  fcm_token text,
  ativo boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table clientes (
  usuario_id uuid primary key references usuarios (id) on delete cascade,
  cpf text unique,
  data_nascimento date,
  criado_em timestamptz not null default now()
);

create table coletadores (
  usuario_id uuid primary key references usuarios (id) on delete cascade,
  cpf text unique,
  cnh text,
  placa_veiculo text,
  modelo_veiculo text,
  disponivel boolean not null default true,
  latitude_atual double precision,
  longitude_atual double precision,
  avaliacao_media numeric(3, 2) default 5.0,
  criado_em timestamptz not null default now()
);

create table administradores (
  usuario_id uuid primary key references usuarios (id) on delete cascade,
  nivel_acesso text not null default 'padrao',
  criado_em timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- ENDEREÇOS
-- ---------------------------------------------------------------------
create table enderecos (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references usuarios (id) on delete cascade,
  apelido text,
  cep text not null,
  logradouro text not null,
  numero text not null,
  complemento text,
  bairro text not null,
  cidade text not null,
  uf text not null,
  latitude double precision,
  longitude double precision,
  principal boolean not null default false,
  criado_em timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- SOLICITAÇÕES
-- ---------------------------------------------------------------------
create table solicitacoes (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references usuarios (id),
  coletador_id uuid references usuarios (id),
  status status_solicitacao not null default 'aguardando',
  endereco_id uuid not null references enderecos (id),
  descricao_item text not null,
  codigo_devolucao text,
  observacoes text,
  janela_coleta_inicio timestamptz,
  janela_coleta_fim timestamptz,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index idx_solicitacoes_cliente on solicitacoes (cliente_id);
create index idx_solicitacoes_coletador on solicitacoes (coletador_id);
create index idx_solicitacoes_status on solicitacoes (status);

-- ---------------------------------------------------------------------
-- COLETAS (execução operacional de uma solicitação)
-- ---------------------------------------------------------------------
create table coletas (
  id uuid primary key default gen_random_uuid(),
  solicitacao_id uuid not null references solicitacoes (id) on delete cascade,
  coletador_id uuid not null references usuarios (id),
  status status_solicitacao not null default 'atribuida',
  codigo_escaneado text,
  latitude_coleta double precision,
  longitude_coleta double precision,
  iniciada_em timestamptz,
  concluida_em timestamptz,
  criado_em timestamptz not null default now()
);

create index idx_coletas_coletador on coletas (coletador_id);
create index idx_coletas_solicitacao on coletas (solicitacao_id);

-- ---------------------------------------------------------------------
-- ROTAS (agrupa coletas do dia de um coletador, otimizadas)
-- ---------------------------------------------------------------------
create table rotas (
  id uuid primary key default gen_random_uuid(),
  coletador_id uuid not null references usuarios (id),
  data_rota date not null default current_date,
  coleta_ids uuid[] not null default '{}',
  distancia_total_m integer,
  duracao_estimada_s integer,
  iniciada_em timestamptz,
  finalizada_em timestamptz,
  criado_em timestamptz not null default now()
);

create index idx_rotas_coletador_data on rotas (coletador_id, data_rota);

-- ---------------------------------------------------------------------
-- HISTÓRICO DE STATUS (auditoria de todo o fluxo)
-- ---------------------------------------------------------------------
create table historico_status (
  id uuid primary key default gen_random_uuid(),
  solicitacao_id uuid not null references solicitacoes (id) on delete cascade,
  status_anterior status_solicitacao,
  status_novo status_solicitacao not null,
  alterado_por uuid references usuarios (id),
  observacao text,
  criado_em timestamptz not null default now()
);

create index idx_historico_solicitacao on historico_status (solicitacao_id);

-- ---------------------------------------------------------------------
-- NOTIFICAÇÕES
-- ---------------------------------------------------------------------
create table notificacoes (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references usuarios (id) on delete cascade,
  titulo text not null,
  corpo text not null,
  tipo text not null default 'status_solicitacao',
  referencia_id uuid,
  lida boolean not null default false,
  criado_em timestamptz not null default now()
);

create index idx_notificacoes_usuario on notificacoes (usuario_id, lida);

-- ---------------------------------------------------------------------
-- ARQUIVOS (metadados dos objetos no Supabase Storage)
-- ---------------------------------------------------------------------
create table arquivos (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references usuarios (id) on delete cascade,
  solicitacao_id uuid references solicitacoes (id) on delete cascade,
  coleta_id uuid references coletas (id) on delete cascade,
  bucket text not null,
  caminho text not null,
  tipo text not null, -- foto_coleta | foto_embalagem | comprovante | documento | avatar
  criado_em timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- CONFIGURAÇÕES (por usuário; ex.: preferências de notificação/tema)
-- ---------------------------------------------------------------------
create table configuracoes (
  usuario_id uuid primary key references usuarios (id) on delete cascade,
  notificacoes_push boolean not null default true,
  tema text not null default 'sistema', -- claro | escuro | sistema
  atualizado_em timestamptz not null default now()
);

-- =====================================================================
-- TRIGGERS
-- =====================================================================

-- Cria automaticamente a linha em `usuarios` (+ tabela de perfil
-- específica) quando um novo usuário se registra via Supabase Auth.
create or replace function handle_new_user()
returns trigger as $$
declare
  v_perfil perfil_usuario;
begin
  v_perfil := coalesce((new.raw_user_meta_data ->> 'perfil')::perfil_usuario, 'cliente');

  insert into usuarios (id, nome, email, perfil, email_verificado)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nome', split_part(new.email, '@', 1)),
    new.email,
    v_perfil,
    new.email_confirmed_at is not null
  );

  if v_perfil = 'cliente' then
    insert into clientes (usuario_id) values (new.id);
  elsif v_perfil = 'coletador' then
    insert into coletadores (usuario_id) values (new.id);
  elsif v_perfil = 'administrador' then
    insert into administradores (usuario_id) values (new.id);
  end if;

  insert into configuracoes (usuario_id) values (new.id);

  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- Registra automaticamente cada mudança de status em `historico_status`
-- e atualiza `atualizado_em`.
create or replace function registrar_historico_status()
returns trigger as $$
begin
  if old.status is distinct from new.status then
    insert into historico_status (solicitacao_id, status_anterior, status_novo, alterado_por)
    values (new.id, old.status, new.status, auth.uid());
  end if;
  new.atualizado_em := now();
  return new;
end;
$$ language plpgsql security definer;

create trigger trg_historico_status
  before update on solicitacoes
  for each row execute function registrar_historico_status();

-- Dispara a Edge Function de push notification a cada mudança de status
-- (ver docs/edge-functions.md). Usa pg_net para chamada HTTP assíncrona.
create extension if not exists pg_net;

create or replace function notificar_mudanca_status()
returns trigger as $$
begin
  if old.status is distinct from new.status then
    perform net.http_post(
      url := current_setting('app.settings.supabase_functions_url') || '/enviar-push-notification',
      headers := jsonb_build_object('Content-Type', 'application/json'),
      body := jsonb_build_object(
        'solicitacao_id', new.id,
        'cliente_id', new.cliente_id,
        'coletador_id', new.coletador_id,
        'status_novo', new.status
      )
    );
  end if;
  return new;
end;
$$ language plpgsql security definer;

create trigger trg_notificar_status
  after update on solicitacoes
  for each row execute function notificar_mudanca_status();

-- =====================================================================
-- STORAGE BUCKETS
-- =====================================================================
insert into storage.buckets (id, name, public) values
  ('fotos-coleta', 'fotos-coleta', false),
  ('fotos-embalagem', 'fotos-embalagem', false),
  ('comprovantes', 'comprovantes', false),
  ('documentos', 'documentos', false),
  ('avatares', 'avatares', true)
on conflict (id) do nothing;
