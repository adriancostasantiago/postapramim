import 'package:flutter/material.dart';
import 'package:posta_pra_mim/domain/entities/pedido_detalhe.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/pedido_detalhe_field.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/pedido_detalhe_section.dart';

/// Conteúdo da seção "Destinatário": nome, CPF, telefone, e-mail e
/// endereço completo de entrega.
class DestinatarioCard extends StatelessWidget {
  const DestinatarioCard({required this.destinatario, super.key});

  final Destinatario destinatario;

  @override
  Widget build(BuildContext context) {
    return PedidoDetalheSection(
      icon: Icons.person_outline,
      title: 'Destinatário',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PedidoDetalheField(
            label: 'Nome Completo',
            value: destinatario.nomeCompleto,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    PedidoDetalheField(label: 'CPF', value: destinatario.cpf),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PedidoDetalheField(
                  label: 'Telefone',
                  value: destinatario.telefone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PedidoDetalheField(label: 'E-mail', value: destinatario.email),
          const SizedBox(height: 12),
          PedidoDetalheField(
            label: 'Endereço de Entrega',
            value: destinatario.enderecoEntrega,
          ),
        ],
      ),
    );
  }
}
