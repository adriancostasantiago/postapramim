-- =====================================================================
-- POSTA PRA MIM — PATCH: RLS para os dashboards de cliente e coletador
-- =====================================================================
-- Execute após schema.sql + schema_patch_cadastro.sql +
-- schema_patch_solicitacao_avulsa.sql + rls_policies.sql
--
-- Contexto: hoje a policy `solicitacoes_select` só deixa um coletador ver
-- as solicitações já atribuídas a ele (coletador_id = auth.uid()). Como
-- o dashboard do coletador precisa mostrar TODA a demanda em aberto (para
-- ele poder aceitar novas coletas), qualquer coletador autenticado precisa
-- enxergar todas as linhas de `solicitacoes`.
--
-- Também: solicitações avulsas (sem cadastro) têm cliente_id nulo, então
-- hoje um cliente que se cadastrou depois de pedir uma coleta avulsa não
-- consegue ver esse histórico. Adicionamos uma policy que libera a leitura
-- quando o CPF da solicitação avulsa bate com o CPF do cliente logado.
--
-- Como policies do tipo "permissive" (padrão do Postgres) se combinam com
-- OR, isso apenas AMPLIA o acesso já existente — nenhuma policy anterior
-- precisa ser removida.
-- =====================================================================

create policy "solicitacoes_select_coletador_todas"
  on solicitacoes for select
  using (is_coletador());

create policy "solicitacoes_select_avulsa_por_cpf"
  on solicitacoes for select
  using (
    avulsa = true
    and cpf_contato is not null
    and exists (
      select 1 from clientes c
      where c.usuario_id = auth.uid()
        and c.cpf = solicitacoes.cpf_contato
    )
  );

-- ---------------------------------------------------------------------
-- Observação (fora do escopo deste patch, mas relevante para o próximo
-- passo do fluxo): hoje `solicitacoes_update` só permite que um coletador
-- atualize linhas onde coletador_id = auth.uid(). Ou seja, um coletador
-- ainda NÃO consegue "aceitar" uma solicitação sem dono (coletador_id
-- null) por essa policy. Se/quando implementar o botão de aceitar coleta
-- no dashboard, será necessário uma policy adicional permitindo update
-- quando (coletador_id is null and is_coletador()).
-- ---------------------------------------------------------------------
