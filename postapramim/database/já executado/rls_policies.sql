-- =====================================================================
-- POSTA PRA MIM — ROW LEVEL SECURITY (RLS)
-- =====================================================================
-- Execute após schema.sql. Modelo geral:
--   • Cliente: enxerga somente seus próprios dados.
--   • Coletador: enxerga somente coletas/solicitações a ele atribuídas.
--   • Administrador: acesso total (via função is_admin()).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Função utilitária: identifica o perfil do usuário autenticado
-- ---------------------------------------------------------------------
create or replace function is_admin()
returns boolean as $$
  select exists (
    select 1 from usuarios where id = auth.uid() and perfil = 'administrador'
  );
$$ language sql security definer stable;

create or replace function is_coletador()
returns boolean as $$
  select exists (
    select 1 from usuarios where id = auth.uid() and perfil = 'coletador'
  );
$$ language sql security definer stable;

-- =====================================================================
-- USUARIOS
-- =====================================================================
alter table usuarios enable row level security;

create policy "usuarios_select_proprio_ou_admin"
  on usuarios for select
  using (id = auth.uid() or is_admin());

create policy "usuarios_update_proprio_ou_admin"
  on usuarios for update
  using (id = auth.uid() or is_admin());

-- Nenhum insert/delete direto pela API: criação ocorre via trigger
-- handle_new_user() (security definer) no cadastro do Supabase Auth.

-- =====================================================================
-- CLIENTES / COLETADORES / ADMINISTRADORES
-- =====================================================================
alter table clientes enable row level security;
create policy "clientes_proprio_ou_admin"
  on clientes for all
  using (usuario_id = auth.uid() or is_admin());

alter table coletadores enable row level security;
create policy "coletadores_select_todos_autenticados"
  on coletadores for select
  using (auth.uid() is not null); -- clientes precisam ver dados básicos do coletador atribuído

create policy "coletadores_update_proprio_ou_admin"
  on coletadores for update
  using (usuario_id = auth.uid() or is_admin());

alter table administradores enable row level security;
create policy "administradores_apenas_admin"
  on administradores for all
  using (is_admin());

-- =====================================================================
-- ENDEREÇOS — somente o dono
-- =====================================================================
alter table enderecos enable row level security;

create policy "enderecos_select_proprio_ou_admin"
  on enderecos for select
  using (usuario_id = auth.uid() or is_admin());

create policy "enderecos_insert_proprio"
  on enderecos for insert
  with check (usuario_id = auth.uid());

create policy "enderecos_update_proprio_ou_admin"
  on enderecos for update
  using (usuario_id = auth.uid() or is_admin());

create policy "enderecos_delete_proprio_ou_admin"
  on enderecos for delete
  using (usuario_id = auth.uid() or is_admin());

-- =====================================================================
-- SOLICITAÇÕES
--   Cliente: somente as suas.
--   Coletador: somente as atribuídas a ele (coletador_id = auth.uid()).
--   Administrador: todas.
-- =====================================================================
alter table solicitacoes enable row level security;

create policy "solicitacoes_select"
  on solicitacoes for select
  using (
    cliente_id = auth.uid()
    or coletador_id = auth.uid()
    or is_admin()
  );

create policy "solicitacoes_insert_proprio_cliente"
  on solicitacoes for insert
  with check (cliente_id = auth.uid());

create policy "solicitacoes_update"
  on solicitacoes for update
  using (
    cliente_id = auth.uid()   -- ex.: cliente cancela a própria solicitação
    or coletador_id = auth.uid() -- coletador avança o status
    or is_admin()
  );

create policy "solicitacoes_delete_admin"
  on solicitacoes for delete
  using (is_admin());

-- =====================================================================
-- COLETAS — somente o coletador atribuído (ou admin)
-- =====================================================================
alter table coletas enable row level security;

create policy "coletas_select_atribuido_ou_admin"
  on coletas for select
  using (coletador_id = auth.uid() or is_admin());

create policy "coletas_insert_admin_ou_sistema"
  on coletas for insert
  with check (is_admin() or coletador_id = auth.uid());

create policy "coletas_update_atribuido_ou_admin"
  on coletas for update
  using (coletador_id = auth.uid() or is_admin());

-- =====================================================================
-- ROTAS — somente o próprio coletador (ou admin)
-- =====================================================================
alter table rotas enable row level security;

create policy "rotas_proprio_coletador_ou_admin"
  on rotas for all
  using (coletador_id = auth.uid() or is_admin());

-- =====================================================================
-- HISTÓRICO DE STATUS — leitura por quem participa da solicitação
-- =====================================================================
alter table historico_status enable row level security;

create policy "historico_select_participante_ou_admin"
  on historico_status for select
  using (
    is_admin()
    or exists (
      select 1 from solicitacoes s
      where s.id = historico_status.solicitacao_id
        and (s.cliente_id = auth.uid() or s.coletador_id = auth.uid())
    )
  );
-- Inserts acontecem somente via trigger (security definer).

-- =====================================================================
-- NOTIFICAÇÕES — somente o destinatário
-- =====================================================================
alter table notificacoes enable row level security;

create policy "notificacoes_select_proprio"
  on notificacoes for select
  using (usuario_id = auth.uid() or is_admin());

create policy "notificacoes_update_proprio"
  on notificacoes for update
  using (usuario_id = auth.uid());

-- =====================================================================
-- ARQUIVOS (metadados) — somente o dono ou participante da solicitação
-- =====================================================================
alter table arquivos enable row level security;

create policy "arquivos_select_dono_ou_participante_ou_admin"
  on arquivos for select
  using (
    usuario_id = auth.uid()
    or is_admin()
    or exists (
      select 1 from solicitacoes s
      where s.id = arquivos.solicitacao_id
        and (s.cliente_id = auth.uid() or s.coletador_id = auth.uid())
    )
  );

create policy "arquivos_insert_proprio"
  on arquivos for insert
  with check (usuario_id = auth.uid());

-- =====================================================================
-- CONFIGURAÇÕES — somente o próprio usuário
-- =====================================================================
alter table configuracoes enable row level security;

create policy "configuracoes_proprio"
  on configuracoes for all
  using (usuario_id = auth.uid());

-- =====================================================================
-- STORAGE POLICIES
-- =====================================================================

-- Avatares: público para leitura, escrita só do próprio dono
-- (caminho esperado: avatares/{user_id}/arquivo.jpg)
create policy "avatares_leitura_publica"
  on storage.objects for select
  using (bucket_id = 'avatares');

create policy "avatares_upload_proprio"
  on storage.objects for insert
  with check (bucket_id = 'avatares' and (storage.foldername(name))[1] = auth.uid()::text);

-- Fotos de coleta/embalagem e comprovantes: privados, acessíveis por
-- cliente e coletador da solicitação relacionada
-- (caminho esperado: {bucket}/{solicitacao_id}/arquivo.jpg)
create policy "fotos_coleta_acesso_participantes"
  on storage.objects for select
  using (
    bucket_id in ('fotos-coleta', 'fotos-embalagem', 'comprovantes')
    and exists (
      select 1 from solicitacoes s
      where s.id::text = (storage.foldername(name))[1]
        and (s.cliente_id = auth.uid() or s.coletador_id = auth.uid())
    )
  );

create policy "fotos_coleta_upload_coletador"
  on storage.objects for insert
  with check (
    bucket_id in ('fotos-coleta', 'fotos-embalagem', 'comprovantes')
    and exists (
      select 1 from solicitacoes s
      where s.id::text = (storage.foldername(name))[1]
        and s.coletador_id = auth.uid()
    )
  );

-- Documentos: acesso restrito ao dono ou admin
create policy "documentos_acesso_proprio_ou_admin"
  on storage.objects for select
  using (
    bucket_id = 'documentos'
    and ((storage.foldername(name))[1] = auth.uid()::text or is_admin())
  );

create policy "solicitacoes_insert_avulso"
  on solicitacoes for insert
  to anon, authenticated
  with check (avulsa = true and cliente_id is null);