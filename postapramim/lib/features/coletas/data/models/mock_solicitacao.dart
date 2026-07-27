import 'package:flutter/material.dart';

class MockSolicitacao {
  final MockStatus status;
  final String codigoDevolucao;
  final DateTime criadoEm;

  final MockCliente cliente;
  final MockEndereco endereco;

  final DateTime janelaColetaInicio;
  final DateTime janelaColetaFim;

  final String? descricaoItem;
  final String observacoes;
  final int quantidadeVolumes;

  MockSolicitacao({
    required this.status,
    required this.codigoDevolucao,
    required this.criadoEm,
    required this.cliente,
    required this.endereco,
    required this.janelaColetaInicio,
    required this.janelaColetaFim,
    required this.descricaoItem,
    required this.observacoes,
    required this.quantidadeVolumes,
  });
}

class MockStatus {
  final String label;
  final String valorBanco;

  MockStatus({required this.label, required this.valorBanco});
}

class MockCliente {
  final String nome;
  final String telefone;
  final String email;

  MockCliente({
    required this.nome,
    required this.telefone,
    required this.email,
  });
}

class MockEndereco {
  final String logradouro;
  final String numero;
  final String bairro;
  final String cidade;
  final String uf;
  final String cep;

  MockEndereco({
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.cep,
  });
}
