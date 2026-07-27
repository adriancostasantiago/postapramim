class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o e-mail';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(value.trim())) return 'E-mail inválido';
    return null;
  }

  static String? senha(String? value) {
    if (value == null || value.isEmpty) return 'Informe a senha';
    if (value.length < 6) return 'A senha deve ter ao menos 6 caracteres';
    return null;
  }

  static String? obrigatorio(String? value, {String campo = 'Campo'}) {
    if (value == null || value.trim().isEmpty) return '$campo é obrigatório';
    return null;
  }

  static String? cep(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o CEP';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return 'CEP inválido';
    return null;
  }

  static String? telefone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o telefone';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 11) return 'Telefone inválido';
    return null;
  }
}
