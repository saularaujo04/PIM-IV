import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';
import '../models/entrega.dart';
import 'entregas_screen.dart' show corDoStatus;
import 'ocorrencia_screen.dart';

final _fmt = DateFormat('dd/MM HH:mm');

class DetalheScreen extends StatelessWidget {
  const DetalheScreen({super.key, required this.entregaId});
  final int entregaId;

  Future<void> _mudarStatus(
      BuildContext context, Entrega e, StatusEntrega novo, {bool confirmar = false}) async {
    if (confirmar) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Marcar como "${novo.rotulo}"?'),
          content: const Text('Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Confirmar')),
          ],
        ),
      );
      if (ok != true) return;
    }
    final msg = await app.atualizarStatus(e, novo);
    if (msg != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        Entrega? e;
        for (final x in app.entregas) {
          if (x.id == entregaId) e = x;
        }
        if (e == null) {
          return Scaffold(
              appBar: AppBar(), body: const Center(child: Text('Entrega não encontrada.')));
        }
        final entrega = e;
        return Scaffold(
          appBar: AppBar(title: Text(entrega.codigoRastreio)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(entrega.status.rotulo),
                  backgroundColor: corDoStatus(context, entrega.status),
                ),
              ),
              _Linha('Cliente', entrega.clienteNome),
              _Linha('Origem', entrega.origem),
              _Linha('Destino', entrega.destino),
              _Linha('Peso', '${entrega.pesoKg.toStringAsFixed(1)} kg'),
              if (entrega.dataPrevista != null)
                _Linha('Previsão', _fmt.format(entrega.dataPrevista!.toLocal())),
              const SizedBox(height: 16),
              if (entrega.status == StatusEntrega.alocada)
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar trajeto'),
                  onPressed: () => _mudarStatus(context, entrega, StatusEntrega.emRota),
                ),
              if (entrega.status == StatusEntrega.emRota) ...[
                FilledButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirmar entrega'),
                  onPressed: () => _mudarStatus(context, entrega, StatusEntrega.entregue,
                      confirmar: true),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Entrega não realizada'),
                  onPressed: () => _mudarStatus(
                      context, entrega, StatusEntrega.naoRealizada, confirmar: true),
                ),
              ],
              if (!entrega.status.finalizada) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.report_problem),
                  label: const Text('Registrar ocorrência'),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OcorrenciaScreen(entregaId: entrega.id))),
                ),
              ],
              const SizedBox(height: 24),
              Text('Ocorrências', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (entrega.ocorrencias.isEmpty)
                const Text('Nenhuma ocorrência registrada.')
              else
                ...entrega.ocorrencias.reversed.map((o) => Card(
                      child: ListTile(
                        title: Text(o.tipo.rotulo),
                        subtitle: Text(o.descricao),
                        trailing: Text(_fmt.format(o.dataHora.toLocal()),
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha(this.rotulo, this.valor);
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rotulo, style: Theme.of(context).textTheme.labelMedium),
          Text(valor, style: Theme.of(context).textTheme.bodyLarge),
        ]),
      );
}
