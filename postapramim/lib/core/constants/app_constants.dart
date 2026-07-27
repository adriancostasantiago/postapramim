enum PerfilUsuario { cliente, coletador, administrador }

enum StatusSolicitacao {
  /// Cliente criou a solicitação; ainda sem coletador — qualquer
  /// coletador autenticado pode aceitar (ver RLS
  /// `solicitacoes_aceitar_coletador`).
  solicitacaoRealizada,

  /// Um coletador já aceitou (coletador_id preenchido); ele ainda vai até
  /// o endereço buscar o item.
  aguardandoColeta,

  /// Coletador já pegou o item e está levando para o destino.
  emTransito,

  concluida,
  cancelada,
}

extension StatusSolicitacaoX on StatusSolicitacao {
  String get valorBanco => switch (this) {
    StatusSolicitacao.solicitacaoRealizada => 'solicitacao_realizada',
    StatusSolicitacao.aguardandoColeta => 'aguardando_coleta',
    StatusSolicitacao.emTransito => 'em_transito',
    StatusSolicitacao.concluida => 'concluida',
    StatusSolicitacao.cancelada => 'cancelada',
  };

  String get label => switch (this) {
    StatusSolicitacao.solicitacaoRealizada => 'Solicitação realizada',
    StatusSolicitacao.aguardandoColeta => 'Aguardando coleta',
    StatusSolicitacao.emTransito => 'Em trânsito',
    StatusSolicitacao.concluida => 'Concluída',
    StatusSolicitacao.cancelada => 'Cancelada',
  };

  static StatusSolicitacao fromBanco(String valor) {
    return StatusSolicitacao.values.firstWhere(
      (s) => s.valorBanco == valor,
      orElse: () => StatusSolicitacao.solicitacaoRealizada,
    );
  }

  /// Próximo status "natural" no fluxo linear (usado pelo botão único de
  /// avançar em `detalhe_coleta_page.dart`). É `null` quando não há mais
  /// próximo passo manual (concluída/cancelada são estados finais) ou
  /// quando o próximo passo depende de uma ação diferente — sair de
  /// `solicitacaoRealizada` é feito pelo botão "Aceitar" (que também
  /// grava o coletador), não por aqui.
  StatusSolicitacao? get proximoStatus => switch (this) {
    StatusSolicitacao.solicitacaoRealizada => null,
    StatusSolicitacao.aguardandoColeta => StatusSolicitacao.emTransito,
    StatusSolicitacao.emTransito => StatusSolicitacao.concluida,
    StatusSolicitacao.concluida => null,
    StatusSolicitacao.cancelada => null,
  };
}

void testeStatusSolicitacao() {
  final status = StatusSolicitacao.concluida;

  print(status.label);
  print(status.valorBanco);
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Posta Pra Mim';
  static const String versaoApp = '1.0.0';
  static const int timeoutRequestSeconds = 30;
  static const int raioBuscaColetadorKm = 15;

  // Hive boxes
  static const String boxUsuario = 'box_usuario';
  static const String boxRotaDoDia = 'box_rota_do_dia';
  static const String boxColetasDoDia = 'box_coletas_do_dia';
  static const String boxConfiguracoes = 'box_configuracoes';
  static const String boxCacheGenerico = 'box_cache';

  // Secure storage keys
  static const String secureKeyAccessToken = 'access_token';
  static const String secureKeyRefreshToken = 'refresh_token';
}
