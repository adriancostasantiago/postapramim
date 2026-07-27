-- =====================================================================
-- POSTA PRA MIM — PATCH: solicitação avulsa (sem cadastro)
-- =====================================================================
-- Execute após schema.sql + schema_patch_cadastro.sql + rls_policies.sql
-- =====================================================================

alter table solicitacoes
  alter column cliente_id drop not null,
  alter column endereco_id drop not null,
  alter column descricao_item drop not null;

alter table solicitacoes
  add column if not exists avulsa boolean not null default false,
  add column if not exists nome_contato text,
  add column if not exists cpf_contato text,
  add column if not exists telefone_contato text,
  add column if not exists cep_contato text,
  add column if not exists logradouro_contato text,
  add column if not exists numero_contato text,
  add column if not exists complemento_contato text,
  add column if not exists bairro_contato text,
  add column if not exists cidade_contato text,
  add column if not exists uf_contato text;

-- Garante que toda linha tenha OU os dados de cliente cadastrado, OU os
-- dados de contato avulso completos — nunca os dois vazios.
alter table solicitacoes
  add constraint chk_solicitacao_identificacao
  check (
    (avulsa = false and cliente_id is not null and endereco_id is not null)
    or
    (avulsa = true
      and nome_contato is not null
      and telefone_contato is not null
      and cep_contato is not null
      and logradouro_contato is not null
      and numero_contato is not null
      and bairro_contato is not null
      and cidade_contato is not null
      and uf_contato is not null)
  );

create index if not exists idx_solicitacoes_avulsa
  on solicitacoes (avulsa) where avulsa = true;