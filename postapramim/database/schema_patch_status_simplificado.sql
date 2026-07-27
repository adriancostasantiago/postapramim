-- =====================================================================
-- POSTA PRA MIM — PATCH: reduzir status_solicitacao de 10 para 5 valores
-- =====================================================================
-- Execute após schema.sql + patches anteriores. Recomendo rodar em
-- ambiente de teste primeiro — altera um tipo enum usado em 3 tabelas.
--
-- Mapeamento (10 status antigos -> 5 novos):
--   aguardando, atribuida, aceita          -> solicitacao_realizada
--   em_rota, chegou_ao_local, coletada,
--     em_transporte, recebida              -> em_transito
--   concluida                              -> concluida
--   cancelada                               -> cancelada
--
-- Observação: linhas com o status antigo 'atribuida'/'aceita' (coletador
-- já atribuído, mas ainda não confirmou coleta) ficariam mais corretas
-- como 'aguardando_coleta'. Como o enum antigo não distinguia "aceita
-- mas não confirmou" de "aguardando ninguém aceitar" de forma que dê pra
-- automatizar 100%, migramos 'atribuida'/'aceita' para
-- 'aguardando_coleta' (não para 'solicitacao_realizada'), já que nesses
-- casos coletador_id já está preenchido. Confira o "case" abaixo.
-- =====================================================================

-- 1) Cria o novo tipo com os 5 valores.
create type status_solicitacao_v2 as enum (
  'solicitacao_realizada',
  'aguardando_coleta',
  'em_transito',
  'concluida',
  'cancelada'
);

-- 2) Solta o default das colunas antes de trocar o tipo (não dá pra
--    converter tipo com um default do tipo antigo "pendurado").
alter table solicitacoes alter column status drop default;
alter table coletas alter column status drop default;

-- 3) Converte a coluna em `solicitacoes`, mapeando pelos dados reais
--    (coletador_id preenchido = já foi aceita).
alter table solicitacoes
  alter column status type status_solicitacao_v2
  using (
    case
      when status = 'aguardando' then 'solicitacao_realizada'
      when status in ('atribuida', 'aceita') then 'aguardando_coleta'
      when status in ('em_rota', 'chegou_ao_local', 'coletada', 'em_transporte', 'recebida')
        then 'em_transito'
      when status = 'concluida' then 'concluida'
      when status = 'cancelada' then 'cancelada'
    end
  )::status_solicitacao_v2;

-- 4) Mesma coisa em `coletas` (tem a mesma coluna status).
alter table coletas
  alter column status type status_solicitacao_v2
  using (
    case
      when status = 'aguardando' then 'solicitacao_realizada'
      when status in ('atribuida', 'aceita') then 'aguardando_coleta'
      when status in ('em_rota', 'chegou_ao_local', 'coletada', 'em_transporte', 'recebida')
        then 'em_transito'
      when status = 'concluida' then 'concluida'
      when status = 'cancelada' then 'cancelada'
    end
  )::status_solicitacao_v2;

-- 5) `historico_status` guarda status_anterior/status_novo — mesma
--    conversão, mas aceitando NULL (status_anterior pode ser null na
--    primeira linha do histórico).
alter table historico_status
  alter column status_anterior type status_solicitacao_v2
  using (
    case
      when status_anterior is null then null
      when status_anterior = 'aguardando' then 'solicitacao_realizada'
      when status_anterior in ('atribuida', 'aceita') then 'aguardando_coleta'
      when status_anterior in ('em_rota', 'chegou_ao_local', 'coletada', 'em_transporte', 'recebida')
        then 'em_transito'
      when status_anterior = 'concluida' then 'concluida'
      when status_anterior = 'cancelada' then 'cancelada'
    end
  )::status_solicitacao_v2;

alter table historico_status
  alter column status_novo type status_solicitacao_v2
  using (
    case
      when status_novo = 'aguardando' then 'solicitacao_realizada'
      when status_novo in ('atribuida', 'aceita') then 'aguardando_coleta'
      when status_novo in ('em_rota', 'chegou_ao_local', 'coletada', 'em_transporte', 'recebida')
        then 'em_transito'
      when status_novo = 'concluida' then 'concluida'
      when status_novo = 'cancelada' then 'cancelada'
    end
  )::status_solicitacao_v2;

-- 6) Restaura os defaults, já com os novos valores.
alter table solicitacoes alter column status set default 'solicitacao_realizada';
alter table coletas alter column status set default 'aguardando_coleta';

-- 7) Descarta o tipo antigo e renomeia o novo para o nome original —
--    assim nenhuma outra parte do schema (funções, etc.) precisa saber
--    que o tipo mudou de nome.
drop type status_solicitacao;
alter type status_solicitacao_v2 rename to status_solicitacao;
