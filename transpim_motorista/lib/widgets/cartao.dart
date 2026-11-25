import 'package:flutter/material.dart';

import '../theme.dart';

/// Cartão branco com borda suave. [acento] desenha uma faixa colorida na esquerda.
class Cartao extends StatelessWidget {
  const Cartao({
    super.key,
    required this.child,
    this.onTap,
    this.acento,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? acento;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(12);
    final conteudo = Padding(padding: padding, child: child);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Cores.superficie,
        borderRadius: raio,
        border: Border.all(color: Cores.borda),
      ),
      child: ClipRRect(
        borderRadius: raio,
        child: Material(
          color: Cores.superficie,
          child: InkWell(
            onTap: onTap,
            child: acento == null
                ? conteudo
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(width: 5, color: acento),
                        Expanded(child: conteudo),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
