<#
.SYNOPSIS
    Reorganiza lib/ do projeto postapramim de "por feature" (features/<x>/data|domain|presentation)
    para "por camada" (domain/<x>, data/<x>, presentation/<x>).
.DESCRIPTION
    Rode a partir da raiz do projeto Flutter (onde está o pubspec.yaml).
    Depois de rodar: apague os arquivos gerados (.freezed.dart/.g.dart) e
    rode build_runner de novo, e depois `flutter analyze`.
#>

$ErrorActionPreference = "Stop"

if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "Erro: rode este script na raiz do projeto (onde está o pubspec.yaml)." -ForegroundColor Red
    exit 1
}

Write-Host "==> 1/5: Mapeando movimentações..." -ForegroundColor Cyan

# Caminho antigo -> novo, relativo a lib/
$Moves = [ordered]@{

    # ---------------- AUTH ----------------
    "features/auth/domain/entities/user_entity.dart"                       = "domain/auth/entities/user_entity.dart"
    "features/auth/domain/repositories/auth_repository.dart"               = "domain/auth/repositories/auth_repository.dart"
    "features/auth/domain/usecases/login_usecase.dart"                     = "domain/auth/usecases/login_usecase.dart"
    "features/auth/domain/usecases/logout_usecase.dart"                    = "domain/auth/usecases/logout_usecase.dart"
    "features/auth/domain/usecases/register_usecase.dart"                  = "domain/auth/usecases/register_usecase.dart"
    "features/auth/domain/usecases/recover_password_usecase.dart"          = "domain/auth/usecases/recover_password_usecase.dart"
    "features/auth/domain/usecases/get_current_user_usecase.dart"         = "domain/auth/usecases/get_current_user_usecase.dart"

    "features/auth/data/models/user_model.dart"                            = "data/auth/models/user_model.dart"
    "features/auth/data/repositories/auth_repository_impl.dart"            = "data/auth/repositories/auth_repository_impl.dart"
    "features/auth/data/datasources/auth_remote_datasource.dart"           = "data/auth/datasources/auth_remote_datasource.dart"

    "features/auth/presentation/controllers/auth_controller.dart"          = "presentation/auth/controllers/auth_controller.dart"
    "features/auth/presentation/providers/auth_providers.dart"             = "presentation/auth/providers/auth_providers.dart"
    "features/auth/presentation/pages/splash_page.dart"                    = "presentation/auth/pages/splash_page.dart"
    "features/auth/presentation/pages/boas_vindas_page.dart"               = "presentation/auth/pages/boas_vindas_page.dart"
    "features/auth/presentation/pages/solicitar_sem_cadastro_page.dart"    = "presentation/auth/pages/solicitar_sem_cadastro_page.dart"
    "features/auth/presentation/pages/login_page.dart"                     = "presentation/auth/pages/login_page.dart"
    "features/auth/presentation/pages/register_page.dart"                  = "presentation/auth/pages/register_page.dart"
    "features/auth/presentation/pages/forgot_password_page.dart"           = "presentation/auth/pages/forgot_password_page.dart"
    "features/auth/presentation/widgets/splash_loading_card.dart"          = "presentation/auth/widgets/splash_loading_card.dart"
    "features/auth/presentation/widgets/animated_logo.dart"                = "presentation/auth/widgets/animated_logo.dart"
    "features/auth/presentation/widgets/speed_lines_background.dart"      = "presentation/auth/widgets/speed_lines_background.dart"
    "features/auth/presentation/widgets/opcao_card.dart"                   = "presentation/auth/widgets/opcao_card.dart"

    # ------------- SOLICITACOES -------------
    "features/solicitacoes/domain/entities/solicitacao_entity.dart"                    = "domain/solicitacoes/entities/solicitacao_entity.dart"
    "features/solicitacoes/domain/repositories/solicitacoes_repository.dart"           = "domain/solicitacoes/repositories/solicitacoes_repository.dart"
    "features/solicitacoes/domain/usecases/listar_solicitacoes_usecase.dart"           = "domain/solicitacoes/usecases/listar_solicitacoes_usecase.dart"
    "features/solicitacoes/domain/usecases/cancelar_solicitacao_usecase.dart"          = "domain/solicitacoes/usecases/cancelar_solicitacao_usecase.dart"
    "features/solicitacoes/domain/usecases/criar_solicitacao_usecase.dart"             = "domain/solicitacoes/usecases/criar_solicitacao_usecase.dart"
    "features/solicitacoes/domain/usecases/criar_solicitacao_avulsa_usecase.dart"      = "domain/solicitacoes/usecases/criar_solicitacao_avulsa_usecase.dart"
    "features/solicitacoes/domain/usecases/obter_solicitacao_usecase.dart"             = "domain/solicitacoes/usecases/obter_solicitacao_usecase.dart"
    "features/solicitacoes/domain/usecases/atualizar_status_solicitacao_usecase.dart"  = "domain/solicitacoes/usecases/atualizar_status_solicitacao_usecase.dart"
    "features/solicitacoes/domain/usecases/observar_solicitacoes_usecase.dart"         = "domain/solicitacoes/usecases/observar_solicitacoes_usecase.dart"
    "features/solicitacoes/domain/usecases/listar_minhas_solicitacoes_usecase.dart"    = "domain/solicitacoes/usecases/listar_minhas_solicitacoes_usecase.dart"
    "features/solicitacoes/domain/usecases/observar_minhas_solicitacoes_usecase.dart"  = "domain/solicitacoes/usecases/observar_minhas_solicitacoes_usecase.dart"
    "features/solicitacoes/domain/usecases/listar_todas_solicitacoes_usecase.dart"     = "domain/solicitacoes/usecases/listar_todas_solicitacoes_usecase.dart"
    "features/solicitacoes/domain/usecases/observar_todas_solicitacoes_usecase.dart"   = "domain/solicitacoes/usecases/observar_todas_solicitacoes_usecase.dart"

    "features/solicitacoes/data/models/solicitacao_model.dart"                         = "data/solicitacoes/models/solicitacao_model.dart"
    "features/solicitacoes/data/datasources/solicitacoes_local_datasource.dart"        = "data/solicitacoes/datasources/solicitacoes_local_datasource.dart"
    "features/solicitacoes/data/datasources/solicitacoes_remote_datasource.dart"       = "data/solicitacoes/datasources/solicitacoes_remote_datasource.dart"
    "features/solicitacoes/data/repositories/solicitacoes_repository_impl.dart"        = "data/solicitacoes/repositories/solicitacoes_repository_impl.dart"

    "features/solicitacoes/presentation/pages/nova_solicitacao_page.dart"              = "presentation/solicitacoes/pages/nova_solicitacao_page.dart"
    "features/solicitacoes/presentation/pages/detalhe_solicitacao_page.dart"           = "presentation/solicitacoes/pages/detalhe_solicitacao_page.dart"
    "features/solicitacoes/presentation/pages/historico_solicitacoes_page.dart"        = "presentation/solicitacoes/pages/historico_solicitacoes_page.dart"
    "features/solicitacoes/presentation/providers/solicitacoes_providers.dart"         = "presentation/solicitacoes/providers/solicitacoes_providers.dart"
    "features/solicitacoes/presentation/providers/usuario_publico_provider.dart"       = "presentation/solicitacoes/providers/usuario_publico_provider.dart"
    "features/solicitacoes/presentation/status_solicitacao_ui.dart"                    = "presentation/solicitacoes/status_solicitacao_ui.dart"

    # ---------------- COLETAS ----------------
    "features/coletas/domain/entities/coleta_entity.dart"                  = "domain/coletas/entities/coleta_entity.dart"
    "features/coletas/data/models/mock_solicitacao.dart"                   = "data/coletas/models/mock_solicitacao.dart"
    "features/coletas/presentation/pages/detalhe_coleta_page.dart"         = "presentation/coletas/pages/detalhe_coleta_page.dart"
    "features/coletas/presentation/pages/scanner_page.dart"                = "presentation/coletas/pages/scanner_page.dart"
    "features/coletas/presentation/pages/minhas_coletas_page.dart"         = "presentation/coletas/pages/minhas_coletas_page.dart"

    # ---------------- DASHBOARD ----------------
    "features/dashboard/presentation/pages/cliente_home_page.dart"         = "presentation/dashboard/pages/cliente_home_page.dart"
    "features/dashboard/presentation/pages/coletador_dashboard_page.dart"  = "presentation/dashboard/pages/coletador_dashboard_page.dart"

    # ---------------- ENDERECOS ----------------
    "features/enderecos/domain/entities/endereco_resumo.dart"              = "domain/enderecos/entities/endereco_resumo.dart"
    "features/enderecos/presentation/pages/endereco_form_page.dart"        = "presentation/enderecos/pages/endereco_form_page.dart"
    "features/enderecos/presentation/providers/enderecos_providers.dart"   = "presentation/enderecos/providers/enderecos_providers.dart"

    # ---------------- PERFIL ----------------
    "features/perfil/presentation/pages/perfil_page.dart"                  = "presentation/perfil/pages/perfil_page.dart"
    "features/perfil/presentation/pages/editar_perfil_page.dart"           = "presentation/perfil/pages/editar_perfil_page.dart"

    # ---------------- CONFIGURACOES / NOTIFICACOES / ROTAS ----------------
    "features/configuracoes/presentation/pages/configuracoes_page.dart"    = "presentation/configuracoes/pages/configuracoes_page.dart"
    "features/notificacoes/presentation/pages/notificacoes_page.dart"      = "presentation/notificacoes/pages/notificacoes_page.dart"
    "features/rotas/presentation/pages/mapa_rota_page.dart"                = "presentation/rotas/pages/mapa_rota_page.dart"
}

Write-Host "==> 2/5: Corrigindo imports (package:postapramim/...) em todos os .dart..." -ForegroundColor Cyan

$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse -File
foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $original = $content
    foreach ($old in $Moves.Keys) {
        $new = $Moves[$old]
        $content = $content -replace [regex]::Escape($old), $new
    }
    if ($content -ne $original) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
    }
}

Write-Host "==> 3/5: Criando pastas novas..." -ForegroundColor Cyan

$novasPastas = $Moves.Values | ForEach-Object { Split-Path $_ -Parent } | Select-Object -Unique
foreach ($p in $novasPastas) {
    New-Item -ItemType Directory -Path "lib/$p" -Force | Out-Null
}

Write-Host "==> 4/5: Movendo arquivos (git mv preserva histórico)..." -ForegroundColor Cyan

foreach ($old in $Moves.Keys) {
    $new = $Moves[$old]
    $oldPath = "lib/$old"
    $newPath = "lib/$new"

    if (Test-Path $oldPath) {
        git mv $oldPath $newPath

        # Move junto os arquivos gerados (freezed/json_serializable), se existirem.
        # Eles serão regenerados de qualquer forma pelo build_runner, mas mover
        # evita erro de "part file not found" até você rodar o build_runner.
        $baseOld = $oldPath -replace "\.dart$", ""
        $baseNew = $newPath -replace "\.dart$", ""
        foreach ($sufixo in @(".freezed.dart", ".g.dart")) {
            if (Test-Path "$baseOld$sufixo") {
                git mv "$baseOld$sufixo" "$baseNew$sufixo"
            }
        }
    } else {
        Write-Host "   (aviso: não encontrado, pulei) $oldPath" -ForegroundColor Yellow
    }
}

Write-Host "==> 5/5: Removendo pastas vazias em lib/features..." -ForegroundColor Cyan

function Remove-EmptyDirs {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return }
    $dirs = Get-ChildItem -Path $Path -Recurse -Directory | Sort-Object { $_.FullName.Length } -Descending
    foreach ($dir in $dirs) {
        if ((Get-ChildItem -Path $dir.FullName -Force | Measure-Object).Count -eq 0) {
            Remove-Item -Path $dir.FullName -Force
        }
    }
    if ((Get-ChildItem -Path $Path -Force | Measure-Object).Count -eq 0) {
        Remove-Item -Path $Path -Force
    }
}

Remove-EmptyDirs -Path "lib/features"

Write-Host ""
Write-Host "Concluído! Próximos passos:" -ForegroundColor Green
Write-Host "  1) flutter pub run build_runner build --delete-conflicting-outputs"
Write-Host "  2) flutter analyze   (para conferir se sobrou algum import quebrado)"