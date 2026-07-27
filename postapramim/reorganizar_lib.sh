#!/usr/bin/env bash
# Reorganiza lib/data e lib/domain em subpastas por assunto (auth / pedido).
# Rode a partir da raiz do projeto Flutter (onde está o pubspec.yaml).
set -euo pipefail

if [ ! -f pubspec.yaml ]; then
  echo "Erro: rode este script na raiz do projeto (onde está o pubspec.yaml)."
  exit 1
fi

echo "==> 1/4: Corrigindo imports em todos os arquivos .dart..."

# Mapa: caminho antigo -> caminho novo (dentro de package:posta_pra_mim/...)
declare -A MOVES=(
  ["domain/entities/user.dart"]="domain/auth/entities/user.dart"
  ["domain/entities/user_role.dart"]="domain/auth/entities/user_role.dart"
  ["domain/repositories/auth_repository.dart"]="domain/auth/repositories/auth_repository.dart"
  ["domain/usecases/auth_usecases.dart"]="domain/auth/usecases/auth_usecases.dart"

  ["domain/entities/pedido.dart"]="domain/pedido/entities/pedido.dart"
  ["domain/entities/pedido_detalhe.dart"]="domain/pedido/entities/pedido_detalhe.dart"
  ["domain/entities/pedido_status.dart"]="domain/pedido/entities/pedido_status.dart"
  ["domain/repositories/pedido_repository.dart"]="domain/pedido/repositories/pedido_repository.dart"
  ["domain/usecases/pedido_usecases.dart"]="domain/pedido/usecases/pedido_usecases.dart"

  ["data/datasources/auth_local_datasource.dart"]="data/auth/datasources/auth_local_datasource.dart"
  ["data/datasources/auth_remote_datasource.dart"]="data/auth/datasources/auth_remote_datasource.dart"
  ["data/datasources/google_auth_datasource.dart"]="data/auth/datasources/google_auth_datasource.dart"
  ["data/models/user_model.dart"]="data/auth/models/user_model.dart"
  ["data/repositories/auth_repository_impl.dart"]="data/auth/repositories/auth_repository_impl.dart"
  ["data/repositories/mock_pedido_repository.dart"]="data/pedido/repositories/mock_pedido_repository.dart"
)

for OLD in "${!MOVES[@]}"; do
  NEW="${MOVES[$OLD]}"
  # Escapa barras para o sed
  OLD_ESC=$(printf '%s\n' "$OLD" | sed 's/[\/&]/\\&/g')
  NEW_ESC=$(printf '%s\n' "$NEW" | sed 's/[\/&]/\\&/g')
  find lib -type f -name "*.dart" -print0 \
    | xargs -0 sed -i "s/${OLD_ESC}/${NEW_ESC}/g"
done

echo "==> 2/4: Movendo arquivos (git mv preserva histórico)..."

mkdir -p lib/domain/auth/entities lib/domain/auth/repositories lib/domain/auth/usecases
mkdir -p lib/domain/pedido/entities lib/domain/pedido/repositories lib/domain/pedido/usecases
mkdir -p lib/data/auth/datasources lib/data/auth/models lib/data/auth/repositories
mkdir -p lib/data/pedido/repositories

for OLD in "${!MOVES[@]}"; do
  NEW="${MOVES[$OLD]}"
  if [ -f "lib/$OLD" ]; then
    git mv "lib/$OLD" "lib/$NEW"
  fi
done

echo "==> 3/4: Removendo arquivo duplicado/morto (login_usecase.dart)..."
if [ -f "lib/domain/usecases/login_usecase.dart" ]; then
  git rm "lib/domain/usecases/login_usecase.dart"
fi

echo "==> 4/4: Removendo pastas vazias..."
find lib/data lib/domain -type d -empty -delete

echo ""
echo "Concluído! Agora rode:"
echo "  flutter analyze"
echo "para conferir se sobrou algum import quebrado."
