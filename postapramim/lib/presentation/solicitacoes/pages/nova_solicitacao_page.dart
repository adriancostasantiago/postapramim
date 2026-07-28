import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/utils/validators.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/domain/enderecos/entities/endereco_resumo.dart';
import 'package:postapramim/presentation/enderecos/pages/endereco_form_page.dart';
import 'package:postapramim/presentation/enderecos/providers/enderecos_providers.dart';
import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/presentation/solicitacoes/providers/solicitacoes_providers.dart';

/// Tela de nova solicitação para o cliente já autenticado.
///
/// Reaproveita o Design System de cards (ícone circular + label flutuante)
/// da tela `SolicitarSemCadastroPage`, mas com o cabeçalho de usuário logado
/// no padrão da `ClienteHomePage`, e já preenche nome/telefone/e-mail a
/// partir do usuário autenticado — sem pedir esses dados de novo.
///
/// O código de devolução agora vai para `SolicitacaoEntity.codigoDevolucao`
/// (campo dedicado). O endereço vem do endereço principal cadastrado do
/// cliente (ver `enderecos_providers.dart`) — se ele ainda não tiver
/// nenhum endereço, a tela pede pra cadastrar antes de enviar.
class NovaSolicitacaoPage extends ConsumerStatefulWidget {
  const NovaSolicitacaoPage({super.key});

  @override
  ConsumerState<NovaSolicitacaoPage> createState() =>
      _NovaSolicitacaoPageState();
}

const _periodosColeta = [
  'Manhã (08h às 12h)',
  'Tarde (12h às 18h)',
  'Qualquer horário',
];

class _NovaSolicitacaoPageState extends ConsumerState<NovaSolicitacaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtrl = TextEditingController();
  final _observacoesCtrl = TextEditingController();
  String? _periodoColeta = _periodosColeta.first;

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _observacoesCtrl.dispose();
    super.dispose();
  }

  /// Converte o período escolhido (texto) numa janela de horário real.
  /// Usa hoje como data-base; se a janela de hoje já passou, agenda para
  /// amanhã. TODO: quando houver um seletor de data no formulário,
  /// substituir `agora` pela data escolhida pelo usuário.
  (DateTime inicio, DateTime fim) _janelaParaPeriodo(String periodo) {
    late final int horaInicio;
    late final int horaFim;
    switch (periodo) {
      case 'Manhã (08h às 12h)':
        horaInicio = 8;
        horaFim = 12;
        break;
      case 'Tarde (12h às 18h)':
        horaInicio = 12;
        horaFim = 18;
        break;
      default: // 'Qualquer horário'
        horaInicio = 8;
        horaFim = 18;
    }

    final agora = DateTime.now();
    var data = DateTime(agora.year, agora.month, agora.day);
    final fimHoje = DateTime(data.year, data.month, data.day, horaFim);
    if (agora.isAfter(fimHoje)) {
      data = data.add(const Duration(days: 1));
    }
    final inicio = DateTime(data.year, data.month, data.day, horaInicio);
    final fim = DateTime(data.year, data.month, data.day, horaFim);
    return (inicio, fim);
  }

  Future<void> _abrirFormularioEndereco(EnderecoResumo? enderecoAtual) async {
    final usuario = ref.read(authControllerProvider).usuario;
    if (usuario == null) return;

    final resultado = await context.push<bool>(
      RoutePaths.clienteEnderecoForm,
      extra: enderecoAtual,
    );

    if (resultado == true && mounted) {
      ref.invalidate(enderecoPrincipalClienteProvider(usuario.id));
    }
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = ref.read(authControllerProvider).usuario;
    if (usuario == null) return;

    final endereco = await ref.read(
      enderecoPrincipalClienteProvider(usuario.id).future,
    );

    if (endereco == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Você ainda não tem um endereço cadastrado. Cadastre um '
            'endereço antes de solicitar a coleta.',
          ),
          action: SnackBarAction(
            label: 'Cadastrar',
            onPressed: () => _abrirFormularioEndereco(null),
          ),
        ),
      );
      return;
    }

    final (janelaInicio, janelaFim) = _janelaParaPeriodo(
      _periodoColeta ?? _periodosColeta.first,
    );

    final solicitacao = SolicitacaoEntity(
      id: '',
      clienteId: usuario.id,
      status: StatusSolicitacao.solicitacaoRealizada,
      enderecoId: endereco.id,
      codigoDevolucao: _codigoCtrl.text.trim(),
      observacoes: _observacoesCtrl.text.trim().isEmpty
          ? null
          : _observacoesCtrl.text.trim(),
      janelaColetaInicio: janelaInicio,
      janelaColetaFim: janelaFim,
      criadoEm: DateTime.now(),
      // Snapshot dos dados do cliente e do endereço escolhido no momento
      // da criação. Usamos os mesmos campos `*Contato` do fluxo avulso,
      // para que a solicitação sempre exiba nome/telefone/endereço de
      // "quando foi criada" — mesmo que o cliente altere o perfil ou o
      // endereço depois. Ver `SolicitacaoEntity.nomeExibicao` /
      // `.enderecoResumo`.
      nomeContato: usuario.nome,
      telefoneContato: usuario.telefone,
      cepContato: endereco.cep,
      logradouroContato: endereco.logradouro,
      numeroContato: endereco.numero,
      complementoContato: endereco.complemento,
      bairroContato: endereco.bairro,
      cidadeContato: endereco.cidade,
      ufContato: endereco.uf,
    );

    final ok = await ref
        .read(solicitacoesControllerProvider.notifier)
        .criar(solicitacao);
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(solicitacoesControllerProvider);
    final usuario = ref.watch(authControllerProvider).usuario;
    final primeiroNome = (usuario?.nome ?? '').split(' ').first;

    final enderecoAsync = usuario == null
        ? const AsyncValue<EnderecoResumo?>.data(null)
        : ref.watch(enderecoPrincipalClienteProvider(usuario.id));

    final podeEnviar =
        !actionState.carregando &&
        enderecoAsync.maybeWhen(data: (e) => e != null, orElse: () => false);

    return Scaffold(
      backgroundColor: AppColors.branco,
      body: SafeArea(
        child: Column(
          children: [
            _Cabecalho(nome: primeiroNome),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Código de devolução',
                        style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      _CampoCard(
                        icone: Icons.qr_code_scanner,
                        label: 'Código de devolução',
                        hint: 'Digite o código fornecido pela loja',
                        controller: _codigoCtrl,
                        validator: (v) =>
                            Validators.obrigatorio(v, campo: 'Código'),
                        suffixIcon: Tooltip(
                          message:
                              'Código enviado pela loja no momento da compra, '
                              'usado para identificar a devolução.',
                          child: const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppColors.cinzaTexto,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Dados da coleta',
                              style: AppTextStyles.subtitulo.copyWith(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                _abrirFormularioEndereco(enderecoAsync.value),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: AppColors.azulInstitucional,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Editar',
                                  style: AppTextStyles.corpo.copyWith(
                                    color: AppColors.azulInstitucional,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _EnderecoCadastradoCard(
                        enderecoAsync: enderecoAsync,
                        onTap: () =>
                            _abrirFormularioEndereco(enderecoAsync.value),
                      ),
                      const SizedBox(height: 14),
                      _DadoReadOnlyCard(
                        icone: Icons.person_outline,
                        label: 'Nome completo',
                        valor: usuario?.nome ?? '—',
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _DadoReadOnlyCard(
                              icone: Icons.badge_outlined,
                              label: 'CPF',
                              // TODO: CPF mora na tabela `clientes`, não em
                              // `usuarios` — expor via UserEntity quando o
                              // repositório trouxer esse join.
                              valor: 'Não informado',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DadoReadOnlyCard(
                              icone: Icons.smartphone_outlined,
                              label: 'Telefone',
                              valor: usuario?.telefone ?? '—',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _DadoReadOnlyCard(
                        icone: Icons.mail_outline,
                        label: 'E-mail',
                        valor: usuario?.email ?? '—',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Informações adicionais',
                        style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      _CampoCardDropdown(
                        icone: Icons.calendar_month_outlined,
                        label: 'Melhor período para coleta',
                        hint: 'Selecione um período',
                        valor: _periodoColeta,
                        opcoes: _periodosColeta,
                        onChanged: (v) => setState(() => _periodoColeta = v),
                        validator: (v) => v == null ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 14),
                      _CampoObservacoes(controller: _observacoesCtrl),
                      const SizedBox(height: 20),
                      const _AvisoImportante(),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.amarelo,
                            foregroundColor: AppColors.preto,
                            disabledBackgroundColor: AppColors.amarelo
                                .withValues(alpha: .4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: podeEnviar ? _enviar : null,
                          child: actionState.carregando
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: AppColors.preto,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.local_shipping_outlined),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Solicitar coleta',
                                      style: AppTextStyles.botao.copyWith(
                                        color: AppColors.preto,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (actionState.erro != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          actionState.erro!,
                          style: AppTextStyles.legenda.copyWith(
                            color: AppColors.erro,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cabeçalho com botão voltar, logo, saudação do usuário logado (padrão
/// `ClienteHomePage`) e o título/subtítulo da tela (padrão
/// `SolicitarSemCadastroPage`).
class _Cabecalho extends StatelessWidget {
  final String nome;

  const _Cabecalho({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.preto),
                onPressed: () => context.pop(),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.amarelo.withValues(alpha: .25),
                child: const Icon(Icons.person, color: AppColors.amarelo),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Olá, ${nome.isEmpty ? 'visitante' : nome}! 👋',
                    style: AppTextStyles.subtitulo.copyWith(fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => context.push(RoutePaths.editarPerfil),
                    child: Text(
                      'Minha conta',
                      style: AppTextStyles.legenda.copyWith(
                        color: AppColors.azulInstitucional,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 155,
                decoration: BoxDecoration(color: AppColors.branco),
              ),
              Positioned(
                top: -35,
                right: -10,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/ilustracao_nova_solicitacao_cadastro.png',
                    height: 200,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Image.asset('assets/images/logo.png', height: 46),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'Nova solicitação',
                        style: AppTextStyles.titulo.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: SizedBox(
                        width: 210,
                        child: Text(
                          'Preencha os dados abaixo para solicitar a coleta da sua devolução sem cadastro.',
                          style: AppTextStyles.corpo.copyWith(
                            fontSize: 13,
                            color: AppColors.darkFundo,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card não-editável mostrando o endereço cadastrado do cliente, com um
/// chevron para ir à tela de endereços. Trata os 3 estados do
/// [enderecoAsync]: carregando, erro, e "sem endereço cadastrado" (que é
/// um `data(null)` bem-sucedido, não um erro).
class _EnderecoCadastradoCard extends StatelessWidget {
  final AsyncValue<EnderecoResumo?> enderecoAsync;
  final VoidCallback onTap;

  const _EnderecoCadastradoCard({
    required this.enderecoAsync,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cinzaBorda),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.amarelo.withValues(alpha: .25),
              child: const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.darkFundo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Endereço cadastrado',
                    style: AppTextStyles.legenda.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  enderecoAsync.when(
                    loading: () => const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (erro, stackTrace) => Text(
                      'Não foi possível carregar seu endereço.',
                      style: AppTextStyles.subtitulo.copyWith(
                        fontSize: 13,
                        color: AppColors.erro,
                      ),
                    ),
                    data: (endereco) => Text(
                      endereco?.enderecoFormatado ??
                          'Nenhum endereço cadastrado — toque para cadastrar.',
                      style: AppTextStyles.subtitulo.copyWith(
                        fontSize: 14,
                        color: endereco == null ? AppColors.erro : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.cinzaTexto),
          ],
        ),
      ),
    );
  }
}

/// Card somente-leitura para exibir um dado já cadastrado do usuário
/// (nome, cpf, telefone, e-mail), sem permitir edição direta nesta tela.
class _DadoReadOnlyCard extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;

  const _DadoReadOnlyCard({
    required this.icone,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cinzaBorda),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _IconeCircular(icone: icone),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.legenda.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: AppTextStyles.subtitulo.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Campo de observações com contador de caracteres (0/200), como no mockup.
class _CampoObservacoes extends StatefulWidget {
  final TextEditingController controller;

  const _CampoObservacoes({required this.controller});

  @override
  State<_CampoObservacoes> createState() => _CampoObservacoesState();
}

class _CampoObservacoesState extends State<_CampoObservacoes> {
  static const _limite = 200;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cinzaBorda),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconeCircular(icone: Icons.chat_bubble_outline),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  maxLines: 2,
                  maxLength: _limite,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                  style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    labelText: 'Observações (opcional)',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: AppTextStyles.subtitulo.copyWith(fontSize: 14),
                    hintText:
                        'Informe alguma observação importante para a coleta',
                    hintStyle: AppTextStyles.legenda,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${widget.controller.text.length}/$_limite',
              style: AppTextStyles.legenda.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de campo com ícone circular à esquerda e label flutuante fixo,
/// no mesmo padrão visual de `SolicitarSemCadastroPage`.
class _CampoCard extends StatelessWidget {
  final IconData icone;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _CampoCard({
    required this.icone,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cinzaBorda),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _IconeCircular(icone: icone),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: validator,
              style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                labelText: label,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: AppTextStyles.subtitulo.copyWith(fontSize: 14),
                hintText: hint,
                hintStyle: AppTextStyles.legenda,
              ),
            ),
          ),
          if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon!],
        ],
      ),
    );
  }
}

/// Variante do card de campo usada para seletores (dropdown), como o
/// período de coleta.
class _CampoCardDropdown extends StatelessWidget {
  final IconData icone;
  final String label;
  final String hint;
  final String? valor;
  final List<String> opcoes;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _CampoCardDropdown({
    required this.icone,
    required this.label,
    required this.hint,
    required this.valor,
    required this.opcoes,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cinzaBorda),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _IconeCircular(icone: icone),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: valor,

              dropdownColor: AppColors.branco,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              validator: validator,
              onChanged: onChanged,
              style: AppTextStyles.subtitulo.copyWith(
                fontSize: 15,
                color: AppColors.darkFundo,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                labelText: label,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: AppTextStyles.subtitulo.copyWith(fontSize: 14),
                hintText: hint,
                hintStyle: AppTextStyles.legenda,
              ),
              items: opcoes
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconeCircular extends StatelessWidget {
  final IconData icone;
  const _IconeCircular({required this.icone});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.amarelo.withValues(alpha: .25),
      child: Icon(icone, size: 18, color: AppColors.darkFundo),
    );
  }
}

/// Bloco de aviso informativo sobre embalagem, código e prazo de coleta.
class _AvisoImportante extends StatelessWidget {
  const _AvisoImportante();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.azulInstitucional.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.azulInstitucional),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Importante',
                  style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.corpo.copyWith(
                      fontSize: 13,
                      color: AppColors.cinzaTexto,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'Tenha em mãos sua embalagem e o código de devolução. '
                            'O prazo de coleta é de ',
                      ),
                      TextSpan(
                        text: 'até 3 dias úteis.',
                        style: AppTextStyles.corpo.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulInstitucional,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
