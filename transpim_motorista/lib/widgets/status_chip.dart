import 'package:flutter/material.dart';

import '../models/entrega.dart';
import '../theme.dart';

/// Selo colorido com o status da entrega (mesmas cores do painel web).
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final StatusEntrega status;

  @override
  Widget build(BuildContext context) {
    final v = visualDoStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: v.fundo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(v.icone, size: 14, color: v.cor),
          const SizedBox(width: 6),
          Text(
            status.rotulo,
            style: TextStyle(color: v.cor, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
