-- =====================================================================
-- POSTA PRA MIM — PATCH: handle_new_user()
-- =====================================================================
-- Execute no SQL Editor do Supabase. Como a função já existe (criada em
-- schema.sql), basta rodar este CREATE OR REPLACE — não precisa recriar
-- a trigger `on_auth_user_created`, ela continua apontando pra mesma
-- função.
--
-- O que muda em relação à versão original:
--   1) Grava `telefone` em `usuarios` (vem do metadata `telefone`,
--      preenchido pelo app com o valor do campo "Celular" do cadastro).
--   2) Grava `cpf` em `clientes`/`coletadores` (vem do metadata `cpf`).
--   3) Corrige o nome exibido no primeiro login via Google: antes só
--      olhava a chave `nome` (preenchida só no cadastro por e-mail/senha);
--      agora também tenta `full_name` e `name`, que é como o Google
--      normalmente entrega o nome via OAuth, antes de cair no fallback
--      da parte local do e-mail.
-- =====================================================================

create or replace function handle_new_user()
returns trigger as $$
declare
  v_perfil perfil_usuario;
  v_nome text;
  v_cpf text;
  v_telefone text;
begin
  v_perfil := coalesce((new.raw_user_meta_data ->> 'perfil')::perfil_usuario, 'cliente');

  -- 'nome' -> preenchido pelo app no cadastro por e-mail/senha.
  -- 'full_name' / 'name' -> preenchidos automaticamente pelo Google (e a
  -- maioria dos provedores OAuth) no raw_user_meta_data.
  v_nome := coalesce(
    new.raw_user_meta_data ->> 'nome',
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'name',
    split_part(new.email, '@', 1)
  );

  v_cpf := new.raw_user_meta_data ->> 'cpf';
  v_telefone := new.raw_user_meta_data ->> 'telefone';

  insert into usuarios (id, nome, email, telefone, perfil, email_verificado)
  values (
    new.id,
    v_nome,
    new.email,
    v_telefone,
    v_perfil,
    new.email_confirmed_at is not null
  );

  if v_perfil = 'cliente' then
    insert into clientes (usuario_id, cpf) values (new.id, v_cpf);
  elsif v_perfil = 'coletador' then
    insert into coletadores (usuario_id, cpf) values (new.id, v_cpf);
  elsif v_perfil = 'administrador' then
    insert into administradores (usuario_id) values (new.id);
  end if;

  insert into configuracoes (usuario_id) values (new.id);

  return new;
end;
$$ language plpgsql security definer;

-- Nada a fazer com a trigger — ela já existe e continua válida:
-- create trigger on_auth_user_created
--   after insert on auth.users
--   for each row execute function handle_new_user();
