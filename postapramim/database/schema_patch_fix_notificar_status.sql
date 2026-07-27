-- =====================================================================
-- POSTA PRA MIM — PATCH: corrige erro
--   "unrecognized configuration parameter app.settings.supabase_functions_url"
-- =====================================================================
-- Causa: notificar_mudanca_status() chama
--   current_setting('app.settings.supabase_functions_url')
-- sem o segundo argumento (missing_ok). Se esse GUC nunca foi setado no
-- banco, o Postgres lança erro 42704 e a transação inteira do UPDATE em
-- `solicitacoes` é abortada — por isso o PATCH via REST retorna 400.
--
-- Correção: usar current_setting(..., true), que retorna NULL em vez de
-- lançar erro quando o parâmetro não existe, e só disparar o
-- net.http_post quando a URL estiver de fato configurada. Assim o fluxo
-- de aceitar/atualizar solicitação funciona mesmo sem a Edge Function
-- configurada, e volta a funcionar sozinho assim que você configurar o
-- parâmetro (ver Opção A, alter database ... set ...).
-- =====================================================================

create or replace function notificar_mudanca_status()
returns trigger as $$
declare
  v_functions_url text;
begin
  if old.status is distinct from new.status then
    v_functions_url := current_setting('app.settings.supabase_functions_url', true);

    if v_functions_url is not null and v_functions_url <> '' then
      perform net.http_post(
        url := v_functions_url || '/enviar-push-notification',
        headers := jsonb_build_object('Content-Type', 'application/json'),
        body := jsonb_build_object(
          'solicitacao_id', new.id,
          'cliente_id', new.cliente_id,
          'coletador_id', new.coletador_id,
          'status_novo', new.status
        )
      );
    end if;
  end if;
  return new;
end;
$$ language plpgsql security definer;

-- Não precisa recriar a trigger — ela já aponta para esta função:
-- create trigger trg_notificar_status
--   after update on solicitacoes
--   for each row execute function notificar_mudanca_status();
