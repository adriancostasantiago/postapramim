import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/domain/entities/novo_pedido.dart';
import 'package:posta_pra_mim/presentation/novo_pedido/widgets/endereco_form_section.dart';
import 'package:posta_pra_mim/presentation/novo_pedido/widgets/mapa_preview_stub.dart';
import 'package:posta_pra_mim/presentation/novo_pedido/widgets/novo_pedido_text_field.dart';
import 'package:posta_pra_mim/presentation/shared/state/novo_pedido_controller.dart';

/// Etapa 1: identificação do remetente e endereço de coleta.
class RemetenteStep extends StatefulWidget {
  const RemetenteStep({required this.formKey, this.dadosIniciais, super.key});

  final GlobalKey<FormState> formKey;
  final RascunhoRemetente? dadosIniciais;

  @override
  State<RemetenteStep> createState() => RemetenteStepState();
}

class RemetenteStepState extends State<RemetenteStep> {
  late final TextEditingController _nome;
  late final TextEditingController _cpfCnpj;
  late final TextEditingController _telefone;
  late final TextEditingController _cep;
  late final TextEditingController _logradouro;
  late final TextEditingController _numero;
  late final TextEditingController _complemento;
  late final TextEditingController _bairro;
  late final TextEditingController _cidade;
  late final TextEditingController _uf;

  bool _buscandoCep = false;

  @override
  void initState() {
    super.initState();
    final d = widget.dadosIniciais;
    _nome = TextEditingController(text: d?.nomeCompleto ?? '');
    _cpfCnpj = TextEditingController(text: d?.cpfOuCnpj ?? '');
    _telefone = TextEditingController(text: d?.telefone ?? '');
    _cep = TextEditingController(text: d?.endereco.cep ?? '');
    _logradouro = TextEditingController(text: d?.endereco.logradouro ?? '');
    _numero = TextEditingController(text: d?.endereco.numero ?? '');
    _complemento = TextEditingController(text: d?.endereco.complemento ?? '');
    _bairro = TextEditingController(text: d?.endereco.bairro ?? '');
    _cidade = TextEditingController(text: d?.endereco.cidade ?? '');
    _uf = TextEditingController(text: d?.endereco.uf ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _nome,
      _cpfCnpj,
      _telefone,
      _cep,
      _logradouro,
      _numero,
      _complemento,
      _bairro,
      _cidade,
      _uf,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _buscarCep() async {
    setState(() => _buscandoCep = true);
    final dados =
        await context.read<NovoPedidoController>().buscarCep(_cep.text);
    if (!mounted) return;
    if (dados != null) {
      _logradouro.text = dados.logradouro;
      _bairro.text = dados.bairro;
      _cidade.text = dados.cidade;
      _uf.text = dados.uf;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP não encontrado.')),
      );
    }
    setState(() => _buscandoCep = false);
  }

  /// Chamado pela página ao apertar "Próximo Passo". Valida, constrói
  /// o rascunho e envia ao controller.
  bool confirmarEAvancar() {
    if (!(widget.formKey.currentState?.validate() ?? false)) return false;
    context.read<NovoPedidoController>().confirmarRemetente(
          RascunhoRemetente(
            nomeCompleto: _nome.text.trim(),
            cpfOuCnpj: _cpfCnpj.text.trim(),
            telefone: _telefone.text.trim(),
            endereco: RascunhoEndereco(
              cep: _cep.text.trim(),
              logradouro: _logradouro.text.trim(),
              numero: _numero.text.trim(),
              complemento: _complemento.text.trim(),
              bairro: _bairro.text.trim(),
              cidade: _cidade.text.trim(),
              uf: _uf.text.trim().toUpperCase(),
            ),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          const Text(
            'Identificação do Remetente',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          NovoPedidoTextField(
            controller: _nome,
            hint: 'Nome Completo / Razão Social',
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Informe o nome.' : null,
          ),
          const SizedBox(height: 10),
          NovoPedidoTextField(
            controller: _cpfCnpj,
            hint: 'CPF ou CNPJ',
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Informe o CPF/CNPJ.' : null,
          ),
          const SizedBox(height: 10),
          NovoPedidoTextField(
            controller: _telefone,
            hint: 'Telefone de Contato',
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Informe o telefone.' : null,
          ),
          const SizedBox(height: 20),
          EnderecoFormSection(
            titulo: 'Endereço de Coleta',
            cepController: _cep,
            logradouroController: _logradouro,
            numeroController: _numero,
            complementoController: _complemento,
            bairroController: _bairro,
            cidadeController: _cidade,
            ufController: _uf,
            onBuscarCep: _buscarCep,
            isBuscandoCep: _buscandoCep,
          ),
          const SizedBox(height: 12),
          const MapaPreviewStub(),
        ],
      ),
    );
  }
}
