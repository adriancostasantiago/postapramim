import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/utils/validators.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:postapramim/presentation/solicitacoes/providers/solicitacoes_providers.dart';

/// Fluxo avulso (guest): o usuário informa o código de devolução e os
/// dados de contato/endereço sem precisar criar conta. Em produção, isso
/// exige uma política de RLS específica em `solicitacoes` permitindo
/// `insert` com `cliente_id null` + um `contato_avulso` (nome/telefone/
/// e-mail) — ver seção "Backlog" em ARCHITECTURE.md para o desenho
/// completo dessa variação da tabela e das policies.
///
/// Visual: segue o mesmo Design System das telas de Login/Boas-vindas —
/// banner amarelo no topo com o logo e a ilustração do caminhão, campos
/// em "cards" com ícone + label flutuante, bloco de aviso informativo e
/// botão final amarelo preenchido.
class SolicitarSemCadastroPage extends ConsumerStatefulWidget {
  const SolicitarSemCadastroPage({super.key});

  @override
  ConsumerState<SolicitarSemCadastroPage> createState() =>
      _SolicitarSemCadastroPageState();
}

Future<void> enviarWhatsApp({
  required String telefone,
  required String mensagem,
}) async {
  final numero = telefone.replaceAll(RegExp(r'[^0-9]'), '');

  final uri = Uri.parse(
    'https://wa.me/55$numero?text=${Uri.encodeComponent(mensagem)}',
  );

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Não foi possível abrir o WhatsApp.');
  }
}

class _SolicitarSemCadastroPageState
    extends ConsumerState<SolicitarSemCadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _enderecoCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _complementoCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  String? _estado;
  String get mensagem =>
      '''
📦 *Posta Pra Mim*

Olá, ${_nomeCtrl.text}!

Solicitação de coleta

📍 Endereço:
${_enderecoCtrl.text}, ${_numeroCtrl.text}
${_bairroCtrl.text}
${_cidadeCtrl.text} - ${_estado ?? ''}

CEP: ${_cepCtrl.text}

CPF: ${_cpfCtrl.text}

Código de devolução:
${_codigoCtrl.text}

Telefone:
${_telefoneCtrl.text}

Via APP v${AppConstants.versaoApp}
''';

  static const _estados = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _telefoneCtrl.dispose();
    _cepCtrl.dispose();
    _enderecoCtrl.dispose();
    _numeroCtrl.dispose();
    _complementoCtrl.dispose();
    _bairroCtrl.dispose();
    _cidadeCtrl.dispose();
    super.dispose();
  }

  String? _validarCpf(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return 'CPF inválido';
    return null;
  }

  Future<void> _buscarEndereco() async {
    if (_cepCtrl.text.trim().isEmpty) return;
    // TODO: BuscarEnderecoPorCepUsecase (ex.: ViaCEP) preenchendo
    // _enderecoCtrl / _bairroCtrl / _cidadeCtrl / _estado.
  }

  // Future<void> _solicitar() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   await enviarWhatsApp(telefone: '75992873792', mensagem: mensagem);

  //   if (!mounted) return;

  //   context.go(RoutePaths.boasVindas);
  // }

  Future<void> _solicitar() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await ref.read(criarSolicitacaoAvulsaUsecaseProvider)(
      codigoDevolucao: _codigoCtrl.text.trim(),
      nomeContato: _nomeCtrl.text.trim(),
      cpfContato: _cpfCtrl.text.trim(),
      telefoneContato: _telefoneCtrl.text.trim(),
      cep: _cepCtrl.text.trim(),
      logradouro: _enderecoCtrl.text.trim(),
      numero: _numeroCtrl.text.trim(),
      complemento: _complementoCtrl.text.trim().isEmpty
          ? null
          : _complementoCtrl.text.trim(),
      bairro: _bairroCtrl.text.trim(),
      cidade: _cidadeCtrl.text.trim(),
      uf: _estado ?? '',
    );

    if (!mounted) return;

    await result.fold(
      onSuccess: (_) async {
        await enviarWhatsApp(telefone: '75992873792', mensagem: mensagem);
        if (!mounted) return;
        context.go(RoutePaths.boasVindas);
      },
      onFailure: (f) async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível enviar sua solicitação: ${f.message}',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.amareloClaro,
      body: SafeArea(
        child: Column(
          children: [
            const _Cabecalho(),
            Expanded(
              child: Container(
                color: AppColors.branco,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CampoCard(
                          icone: Icons.qr_code_scanner,
                          label: 'Código de devolução',
                          hint: 'Digite o código fornecido pela loja',
                          controller: _codigoCtrl,
                          validator: (v) =>
                              Validators.obrigatorio(v, campo: 'Código'),
                        ),
                        const SizedBox(height: 14),
                        _CampoCard(
                          icone: Icons.person_outline,
                          label: 'Nome completo',
                          hint: 'Digite seu nome completo',
                          controller: _nomeCtrl,
                          validator: (v) =>
                              Validators.obrigatorio(v, campo: 'Nome'),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _CampoCard(
                                icone: Icons.badge_outlined,
                                label: 'CPF',
                                hint: '000.000.000-00',
                                controller: _cpfCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(11),
                                ],
                                validator: _validarCpf,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _CampoCard(
                                icone: Icons.smartphone_outlined,
                                label: 'Whatsapp',
                                hint: '(00) 00000-0000',
                                controller: _telefoneCtrl,
                                keyboardType: TextInputType.phone,
                                validator: Validators.telefone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _CampoCard(
                                icone: Icons.location_on_outlined,
                                label: 'CEP',
                                hint: '00000-000',
                                controller: _cepCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(8),
                                ],
                                validator: Validators.cep,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _buscarEndereco,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Buscar endereço',
                                    style: AppTextStyles.corpo.copyWith(
                                      color: AppColors.azulInstitucional,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.search,
                                    size: 18,
                                    color: AppColors.azulInstitucional,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _CampoCard(
                          icone: Icons.map_outlined,
                          label: 'Endereço',
                          hint: 'Rua, Avenida, etc.',
                          controller: _enderecoCtrl,
                          validator: (v) =>
                              Validators.obrigatorio(v, campo: 'Endereço'),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _CampoCard(
                                icone: Icons.holiday_village_outlined,
                                label: 'Bairro',
                                hint: 'Digite o bairro',
                                controller: _bairroCtrl,
                                validator: (v) =>
                                    Validators.obrigatorio(v, campo: 'Bairro'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: _CampoCard(
                                icone: Icons.home_outlined,
                                label: 'Número',
                                hint: '123',
                                controller: _numeroCtrl,
                                keyboardType: TextInputType.number,
                                validator: (v) =>
                                    Validators.obrigatorio(v, campo: 'Número'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _CampoCard(
                          icone: Icons.description_outlined,
                          label: 'Complemento',
                          hint: 'Apto, Casa, etc.',
                          controller: _complementoCtrl,
                        ),

                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _CampoCard(
                                icone: Icons.location_city_outlined,
                                label: 'Cidade',
                                hint: 'Digite sua cidade',
                                controller: _cidadeCtrl,
                                validator: (v) =>
                                    Validators.obrigatorio(v, campo: 'Cidade'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: _CampoCardDropdown(
                                icone: Icons.flag_outlined,
                                label: 'Estado',
                                hint: 'UF',
                                valor: _estado,
                                opcoes: _estados,
                                onChanged: (v) => setState(() => _estado = v),
                                validator: (v) =>
                                    v == null ? 'Obrigatório' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _AvisoImportante(),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.amarelo,
                              foregroundColor: AppColors.darkFundo,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _solicitar,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.local_shipping_outlined),
                                const SizedBox(width: 10),
                                Text(
                                  'Solicitar coleta',
                                  style: AppTextStyles.botao.copyWith(
                                    color: AppColors.darkFundo,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

/// Banner amarelo do topo com logo, ilustração e título da página.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // Fundo em degradê amarelo -> branco (mesma referência visual da
          // ilustração de banner fornecida pelo design).
          Container(
            width: double.infinity,
            height: 220,
            // decoration: const BoxDecoration(color: AppColors.amareloClaro),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.amareloClaro, AppColors.branco],
              ),
            ),
          ),

          // Ilustração do caminhão (asset fornecido pelo design), ancorada
          // à direita do banner.
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/ilustracao_nova_solicitacao.png',
                height: 200,
                // fit: BoxFit.contain,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.darkFundo,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Image.asset('assets/images/logo.png', height: 46),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SizedBox(
                    width: 210,
                    child: Text(
                      'Preencha os dados abaixo para solicitar a coleta da sua devolução sem cadastro.',
                      style: AppTextStyles.corpo.copyWith(
                        fontSize: 13,
                        color: AppColors.cinzaTexto,
                      ),
                    ),
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

/// Card de campo com ícone circular à esquerda e label flutuante fixo
/// acima do valor/placeholder, no padrão da tela "Nova solicitação".
class _CampoCard extends StatelessWidget {
  final IconData icone;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _CampoCard({
    required this.icone,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
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
        ],
      ),
    );
  }
}

/// Variante do card de campo usada para o seletor de Estado (UF).
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
                  .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
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
                        text: 'até 24 horas.',
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
