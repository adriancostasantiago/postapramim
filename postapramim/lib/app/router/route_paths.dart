class RoutePaths {
  RoutePaths._();

  // Públicas
  static const splash = '/';
  static const boasVindas = '/boas-vindas';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const recuperarSenha = '/recuperar-senha';
  static const solicitarSemCadastro = '/solicitar-sem-cadastro';

  // Cliente
  static const clienteHome = '/cliente/home';
  static const clienteNovaSolicitacao = '/cliente/solicitacoes/nova';
  static const clienteDetalheSolicitacao = '/cliente/solicitacoes/:id';
  static const clienteHistorico = '/cliente/historico';

  // Coletador
  static const coletadorDashboard = '/coletador/dashboard';
  static const coletadorMinhasColetas = '/coletador/coletas';
  static const coletadorDetalheColeta = '/coletador/coletas/:id';
  static const coletadorScanner = '/coletador/scanner';
  static const coletadorMapaRota = '/coletador/rota';
  static const coletadorHistorico = '/coletador/historico';

  // Compartilhadas
  static const perfil = '/perfil';
  static const editarPerfil = '/perfil/editar';
  static const configuracoes = '/configuracoes';
  static const notificacoes = '/notificacoes';
  static const ajuda = '/ajuda';

  // Administrador (preparado para painel web futuro)
  static const adminDashboard = '/admin/dashboard';

  //Endereco
  static const clienteEnderecoForm = '/cliente/endereco';
}
