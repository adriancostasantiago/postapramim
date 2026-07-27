import 'package:flutter/material.dart';
import 'package:postapramim/shared/widgets/app_button.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class EmptyState extends StatelessWidget {
  final String titulo;
  final String? mensagem;
  final IconData icone;

  const EmptyState({
    super.key,
    required this.titulo,
    this.mensagem,
    this.icone = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            if (mensagem != null) ...[
              const SizedBox(height: 4),
              Text(
                mensagem!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String mensagem;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.mensagem, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(mensagem, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AppButton(label: 'Tentar novamente', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
