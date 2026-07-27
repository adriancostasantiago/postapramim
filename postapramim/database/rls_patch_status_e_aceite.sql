-- =====================================================================
-- POSTA PRA MIM — PATCH: aceitar solicitação + ver nome do contraparte
-- =====================================================================
-- Execute após schema.sql + rls_policies.sql + schema_patch_dashboard.sql
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Permitir que QUALQUER coletador autenticado ACEITE uma solicitação
--    que ainda não tem coletador (coletador_id is null). A policy
--    `solicitacoes_update` já existente (coletador_id = auth.uid() OR
--    cliente_id = auth.uid() OR is_admin()) não cobre esse caso, porque
--    antes de aceitar o coletador_id ainda não é o do coletador.
--
--    USING     -> autoriza a TENTATIVA de update (linha antes da mudança)
--    WITH CHECK -> valida o resultado (linha depois da mudança): só pode
--    ficar associada ao PRÓPRIO coletador que está aceitando, nunca a
--    outro usuário.
-- ---------------------------------------------------------------------
create policy "solicitacoes_aceitar_coletador"
  on solicitacoes for update
  using (coletador_id is null and is_coletador())
  with check (coletador_id = auth.uid());

-- ---------------------------------------------------------------------
-- 2) Permitir que cliente e coletador de uma MESMA solicitação vejam o
--    nome (e telefone) um do outro. Hoje `usuarios_select_proprio_ou_admin`
--    só libera ver a própria linha; sem isso, o cliente não consegue
--    resolver o nome do coletador que aceitou (e vice-versa).
--
--    É permissiva (combina com OR com a policy já existente), então só
--    AMPLIA o acesso — nenhuma policy anterior precisa ser removida.
-- ---------------------------------------------------------------------
create policy "usuarios_select_participante_solicitacao"
  on usuarios for select
  using (
    exists (
      select 1 from solicitacoes s
      where (s.cliente_id = usuarios.id or s.coletador_id = usuarios.id)
        and (s.cliente_id = auth.uid() or s.coletador_id = auth.uid())
    )
  );
