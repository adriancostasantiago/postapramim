import 'package:postapramim/core/constants/app_constants.dart';

/// Agrupamento dos 5 status reais do banco (`StatusSolicitacao`) em 4
/// "baldes" visuais, usados tanto na Home do cliente quanto no dashboard
/// do coletador. Cada tela decide suas próprias cores/ícones/labels para
/// esses baldes através de uma extension própria.
enum GrupoStatusExibicao { realizada, coleta, emtransito, concluida, cancelada }

extension StatusSolicitacaoExibicaoX on StatusSolicitacao {
  GrupoStatusExibicao get grupoExibicao {
    switch (this) {
      case StatusSolicitacao.solicitacaoRealizada:
        return GrupoStatusExibicao.realizada;
      case StatusSolicitacao.aguardandoColeta:
        return GrupoStatusExibicao.coleta;
      case StatusSolicitacao.emTransito:
        return GrupoStatusExibicao.emtransito;
      case StatusSolicitacao.concluida:
        return GrupoStatusExibicao.concluida;
      case StatusSolicitacao.cancelada:
        return GrupoStatusExibicao.cancelada;
    }
  }
}
