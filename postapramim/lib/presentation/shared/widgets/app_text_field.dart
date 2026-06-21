import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Campo de texto padronizado do app: ícone à esquerda, borda
/// arredondada, placeholder cinza. Reutilizado em login e cadastro
/// para manter consistência visual sem duplicar `InputDecoration`.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.icon,
    required this.hintText,
    this.controller,
    this.label,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.inputFormatters,
    super.key,
  });

  final IconData icon;
  final String hintText;
  final String? label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          inputFormatters: inputFormatters,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botão de olho para alternar visibilidade de senha. Extraído como
/// widget próprio para isolar o `setState` local ao menor escopo
/// possível (ephemeral UI state).
class PasswordVisibilityToggle extends StatefulWidget {
  const PasswordVisibilityToggle({required this.onChanged, super.key});

  final ValueChanged<bool> onChanged;

  @override
  State<PasswordVisibilityToggle> createState() =>
      _PasswordVisibilityToggleState();
}

class _PasswordVisibilityToggleState extends State<PasswordVisibilityToggle> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      tooltip: _visible ? 'Ocultar senha' : 'Mostrar senha',
      onPressed: () {
        setState(() => _visible = !_visible);
        widget.onChanged(_visible);
      },
    );
  }
}
