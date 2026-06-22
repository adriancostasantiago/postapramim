import 'package:flutter/material.dart';
import 'package:posta_pra_mim/domain/entities/pedido_detalhe.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/pedido_detalhe_field.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/pedido_detalhe_section.dart';

/// Conteúdo da seção "Remetente": mesma estrutura de campos do
/// `DestinatarioCard` (nome, CPF, telefone, e-mail e endereço) —
/// dados de quem está enviando o pacote, não de quem o recebe.
class RemetenteCard extends StatelessWidget {
  const RemetenteCard({required this.remetente, super.key});

  final Remetente remetente;

  @override
  Widget build(BuildContext context) {
    return PedidoDetalheSection(
      icon: Icons.outbox_outlined,
      title: 'Remetente',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PedidoDetalheField(
            label: 'Nome Completo',
            value: remetente.nomeCompleto,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PedidoDetalheField(label: 'CPF', value: remetente.cpf),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PedidoDetalheField(
                  label: 'Telefone',
                  value: remetente.telefone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PedidoDetalheField(label: 'E-mail', value: remetente.email),
          const SizedBox(height: 12),
          PedidoDetalheField(
            label: 'Endereço de Origem',
            value: remetente.enderecoOrigem,
          ),
        ],
      ),
    );
  }
}
