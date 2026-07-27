import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/utils/validators.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/domain/enderecos/entities/endereco_resumo.dart';
import 'package:postapramim/presentation/enderecos/providers/enderecos_providers.dart';

/// Estados brasileiros, usados no seletor de UF.
const _ufsBrasil = [
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

/// Tela de cadastro/edição do endereço do cliente.
///
/// Reaproveitada nos dois fluxos:
/// - **Cadastrar**: quando o cliente ainda não tem nenhum endereço (chegue
///   aqui com `enderecoExistente == null`).
/// - **Editar**: quando o cliente já tem um endereço e quer alterá-lo
///   (chegue aqui com `enderecoExistente` preenchido).
///
/// Ao salvar com sucesso, faz `context.pop(true)` — quem chamou esta tela
/// (ex.: `NovaSolicitacaoPage`) deve invalidar/reobservar o provider do
/// endereço para refletir a mudança.
class EnderecoFormPage extends ConsumerStatefulWidget {
  final EnderecoResumo? enderecoExistente;

  const EnderecoFormPage({super.key, this.enderecoExistente});

  @override
  ConsumerState<EnderecoFormPage> createState() => _EnderecoFormPageState();
}

class _EnderecoFormPageState extends ConsumerState<EnderecoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cepCtrl;
  late final TextEditingController _logradouroCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _complementoCtrl;
  late final TextEditingController _bairroCtrl;
  late final TextEditingController _cidadeCtrl;

  String? _ufSelecionada;
  bool _buscandoCep = false;

  /// Nome/CPF/telefone são somente leitura aqui — vêm do cadastro do
  /// cliente, não do endereço. Busco na tabela `clientes` pelo
  /// `usuario_id` do usuário logado.
  ///
  /// TODO: se o projeto já tiver uma feature/provider de `clientes`
  /// (equivalente ao datasource de `solicitacoes`), troque esta busca
  /// direta pelo repository/usecase correspondente, seguindo o mesmo
  /// padrão de Clean Architecture usado no resto do app. Deixei a
  /// consulta direta ao Supabase aqui só porque não tinha visibilidade
  /// dessa camada para a feature de clientes/perfil.
  late final Future<Map<String, String?>> _dadosPerfilFuture;

  bool get _editando => widget.enderecoExistente != null;

  @override
  void initState() {
    super.initState();
    final e = widget.enderecoExistente;
    _cepCtrl = TextEditingController(text: e?.cep ?? '');
    _logradouroCtrl = TextEditingController(text: e?.logradouro ?? '');
    _numeroCtrl = TextEditingController(text: e?.numero ?? '');
    _complementoCtrl = TextEditingController(text: e?.complemento ?? '');
    _bairroCtrl = TextEditingController(text: e?.bairro ?? '');
    _cidadeCtrl = TextEditingController(text: e?.cidade ?? '');
    _ufSelecionada = (e?.uf ?? '').isEmpty ? null : e!.uf.toUpperCase();

    final usuario = ref.read(authControllerProvider).usuario;
    _dadosPerfilFuture = usuario != null
        ? _buscarDadosPerfil(usuario.id)
        : Future.value({'cpf': null, 'telefone': null});
  }

  @override
  void dispose() {
    _cepCtrl.dispose();
    _logradouroCtrl.dispose();
    _numeroCtrl.dispose();
    _complementoCtrl.dispose();
    _bairroCtrl.dispose();
    _cidadeCtrl.dispose();
    super.dispose();
  }

  Future<Map<String, String?>> _buscarDadosPerfil(String usuarioId) async {
    try {
      final data = await Supabase.instance.client
          .from('clientes')
          .select('cpf, telefone')
          .eq('usuario_id', usuarioId)
          .maybeSingle();
      return {
        'cpf': data?['cpf'] as String?,
        'telefone': data?['telefone'] as String?,
      };
    } catch (_) {
      // Se a coluna/tabela não existir com esse nome, não trava a tela —
      // só deixa os campos em branco.
      return {'cpf': null, 'telefone': null};
    }
  }

  /// Consulta o ViaCEP e preenche Endereço/Bairro/Cidade/UF automaticamente.
  Future<void> _buscarEnderecoPorCep() async {
    final cep = _cepCtrl.text.trim();
    if (cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um CEP válido com 8 dígitos.')),
      );
      return;
    }

    setState(() => _buscandoCep = true);
    try {
      final resposta = await http
          .get(Uri.parse('https://viacep.com.br/ws/$cep/json/'))
          .timeout(const Duration(seconds: 10));

      if (resposta.statusCode != 200) {
        throw Exception('Falha ao consultar o CEP.');
      }

      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      if (dados['erro'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('CEP não encontrado.')));
        return;
      }

      setState(() {
        _logradouroCtrl.text = (dados['logradouro'] as String?) ?? '';
        _bairroCtrl.text = (dados['bairro'] as String?) ?? '';
        _cidadeCtrl.text = (dados['localidade'] as String?) ?? '';
        final uf = (dados['uf'] as String?)?.toUpperCase();
        if (uf != null && _ufsBrasil.contains(uf)) {
          _ufSelecionada = uf;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao buscar o CEP: $e')));
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = ref.read(authControllerProvider).usuario;
    if (usuario == null) return;

    final ok = await ref
        .read(enderecoFormControllerProvider.notifier)
        .salvar(
          id: widget.enderecoExistente?.id,
          usuarioId: usuario.id,
          apelido: widget.enderecoExistente?.apelido,
          cep: _cepCtrl.text.trim(),
          logradouro: _logradouroCtrl.text.trim(),
          numero: _numeroCtrl.text.trim(),
          complemento: _complementoCtrl.text.trim().isEmpty
              ? null
              : _complementoCtrl.text.trim(),
          bairro: _bairroCtrl.text.trim(),
          cidade: _cidadeCtrl.text.trim(),
          uf: (_ufSelecionada ?? '').toUpperCase(),
        );

    if (ok && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(enderecoFormControllerProvider);
    final usuario = ref.watch(authControllerProvider).usuario;

    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        backgroundColor: AppColors.branco,
        elevation: 0,
        foregroundColor: AppColors.preto,
        title: Text(
          _editando ? 'Editar endereço' : 'Cadastrar endereço',
          style: AppTextStyles.subtitulo.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 75,
                      decoration: BoxDecoration(color: AppColors.branco),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 130, top: 30),
                      child: Text(
                        _editando
                            ? 'Atualize os dados do seu endereço de coleta.'
                            : 'Cadastre o endereço onde suas coletas serão realizadas.',
                        style: AppTextStyles.corpo.copyWith(
                          color: AppColors.cinzaTexto,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IgnorePointer(
                        // TODO: trocar pelo asset final, se for diferente do
                        // usado no dashboard do coletador.
                        child: Image.asset(
                          'assets/images/editar_endereco.png',
                          height: 100,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ---- Dados do perfil (somente leitura) ----
                FutureBuilder<Map<String, String?>>(
                  future: _dadosPerfilFuture,
                  builder: (context, snapshot) {
                    final carregando =
                        snapshot.connectionState == ConnectionState.waiting;
                    final cpf = snapshot.data?['cpf'];
                    final telefone = snapshot.data?['telefone'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CampoSomenteLeitura(
                          icone: Icons.person_outline,
                          label: 'Nome completo',
                          valor: usuario?.nome ?? '',
                        ),
                        // const SizedBox(height: 14),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Expanded(
                        //       child: _CampoSomenteLeitura(
                        //         icone: Icons.badge_outlined,
                        //         label: 'CPF',
                        //         valor: carregando ? '...' : (cpf ?? '—'),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 12),
                        //     Expanded(
                        //       child: _CampoSomenteLeitura(
                        //         icone: Icons.call_outlined,
                        //         label: 'Telefone',
                        //         valor: carregando ? '...' : (telefone ?? '—'),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),

                // ---- CEP com busca automática ----
                _Campo(
                  icone: Icons.location_on_outlined,
                  label: 'CEP',
                  hint: '00000-000',
                  controller: _cepCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  validator: (v) {
                    final obrigatorio = Validators.obrigatorio(v, campo: 'CEP');
                    if (obrigatorio != null) return obrigatorio;
                    if (v!.trim().length != 8) return 'CEP inválido';
                    return null;
                  },
                  trailing: InkWell(
                    onTap: _buscandoCep ? null : _buscarEnderecoPorCep,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Buscar endereço',
                            style: AppTextStyles.corpo.copyWith(
                              color: AppColors.azulInstitucional,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buscandoCep
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.search,
                                  size: 18,
                                  color: AppColors.azulInstitucional,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                _Campo(
                  icone: Icons.map_outlined,
                  label: 'Endereço',
                  hint: 'Rua, avenida...',
                  controller: _logradouroCtrl,
                  validator: (v) =>
                      Validators.obrigatorio(v, campo: 'Endereço'),
                ),

                const SizedBox(height: 14),
                _Campo(
                  icone: Icons.holiday_village_outlined,
                  label: 'Bairro',
                  hint: 'Bairro',
                  controller: _bairroCtrl,
                  validator: (v) => Validators.obrigatorio(v, campo: 'Bairro'),
                ),
                const SizedBox(height: 14),
                _Campo(
                  icone: Icons.description_outlined,
                  label: 'Complemento (opcional)',
                  hint: 'Apto, bloco...',
                  controller: _complementoCtrl,
                ),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _Campo(
                        icone: Icons.home_outlined,
                        label: 'Número',
                        hint: '123',
                        controller: _numeroCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            Validators.obrigatorio(v, campo: 'Número'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _CampoUf(
                        valor: _ufSelecionada,
                        onChanged: (v) => setState(() => _ufSelecionada = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _Campo(
                  icone: Icons.location_city_outlined,
                  label: 'Cidade',
                  hint: 'Cidade',
                  controller: _cidadeCtrl,
                  validator: (v) => Validators.obrigatorio(v, campo: 'Cidade'),
                ),
                const SizedBox(height: 24),

                // Campo "Referência" removido intencionalmente — não faz
                // parte deste fluxo.
                const _InfoImportante(),
                const SizedBox(height: 20),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amarelo,
                      foregroundColor: AppColors.preto,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: formState.carregando ? null : _salvar,
                    child: formState.carregando
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
                              const Icon(
                                Icons.local_shipping_outlined,
                                color: AppColors.preto,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _editando
                                    ? 'Salvar alterações'
                                    : 'Cadastrar endereço',
                                style: AppTextStyles.botao.copyWith(
                                  color: AppColors.preto,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (formState.erro != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    formState.erro!,
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
    );
  }
}

/// Campo de texto editável com ícone circular + label flutuante, no mesmo
/// padrão visual usado em `NovaSolicitacaoPage`/`SolicitarSemCadastroPage`.
/// Aceita um [trailing] opcional (ex.: ação de "Buscar endereço" no CEP).
class _Campo extends StatelessWidget {
  final IconData icone;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? trailing;

  const _Campo({
    required this.icone,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.trailing,
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
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.amarelo.withValues(alpha: .25),
            child: Icon(icone, size: 18, color: AppColors.darkFundo),
          ),
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
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Campo somente leitura (ex.: dados do perfil do cliente), com o mesmo
/// visual do `_Campo`, mas sem edição.
class _CampoSomenteLeitura extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;

  const _CampoSomenteLeitura({
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
        color: AppColors.branco,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.amarelo.withValues(alpha: .25),
            child: Icon(icone, size: 18, color: AppColors.darkFundo),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.subtitulo.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  valor.isEmpty ? '—' : valor,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.corpo.copyWith(
                    fontSize: 15,
                    color: AppColors.cinzaTexto,
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

/// Seletor de UF (dropdown), no mesmo visual dos demais campos.
class _CampoUf extends StatelessWidget {
  final String? valor;
  final ValueChanged<String?> onChanged;

  const _CampoUf({required this.valor, required this.onChanged});

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
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.amarelo.withValues(alpha: .25),
            child: const Icon(
              Icons.flag_outlined,
              size: 18,
              color: AppColors.darkFundo,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: valor,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Selecione o estado' : null,
              style: AppTextStyles.subtitulo.copyWith(
                fontSize: 15,
                color: AppColors.preto,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                labelText: 'Estado',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: AppTextStyles.subtitulo.copyWith(fontSize: 14),
              ),
              items: _ufsBrasil
                  .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloco informativo azul, mesmo padrão do restante do app.
class _InfoImportante extends StatelessWidget {
  const _InfoImportante();

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
                            'Confirme se o endereço está correto para '
                            'evitar atrasos na coleta. O prazo de coleta é '
                            'de ',
                      ),
                      TextSpan(
                        text: 'até 3 dias úteis.',
                        style: TextStyle(
                          color: AppColors.azulInstitucional,
                          fontWeight: FontWeight.w700,
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
