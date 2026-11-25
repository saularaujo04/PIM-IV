import 'package:flutter/material.dart';

import '../theme.dart';

/// Tela de "nada aqui" ou de erro, com ação opcional (ex.: tentar novamente).
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    this.mensagem,
    this.acaoRotulo,
    this.aoAcionar,
  });

  final IconData icone;
  final String titulo;
  final String? mensagem;
  final String? acaoRotulo;
  final VoidCallback? aoAcionar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 56, color: Cores.textoSuave),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, color: Cores.texto),
          ),
          if (mensagem != null) ...[
            const SizedBox(height: 8),
            Text(
              mensagem!,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Cores.textoSuave),
            ),
          ],
          if (aoAcionar != null && acaoRotulo != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: OutlinedButton.icon(
                onPressed: aoAcionar,
                icon: const Icon(Icons.refresh),
                label: Text(acaoRotulo!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
