import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
<<<<<<< HEAD
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../models/entrega.dart';
import '../theme.dart';
import '../widgets/cartao.dart';
import '../widgets/status_chip.dart';
=======

import '../app_state.dart';
import '../models/entrega.dart';
import 'entregas_screen.dart' show corDoStatus;
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
import 'ocorrencia_screen.dart';

final _fmt = DateFormat('dd/MM HH:mm');

class DetalheScreen extends StatelessWidget {
  const DetalheScreen({super.key, required this.entregaId});
  final int entregaId;

<<<<<<< HEAD
  Future<void> _mudarStatus(BuildContext context, Entrega e, StatusEntrega novo) async {
    // Concluir e "não realizada" pedem confirmação (um toque errado em campo é comum).
    if (novo == StatusEntrega.concluida || novo == StatusEntrega.ocorrencia) {
      final concluir = novo == StatusEntrega.concluida;
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(concluir ? 'Confirmar a entrega?' : 'Marcar como não realizada?'),
          content: Text(concluir
              ? 'A entrega será marcada como concluída e não poderá mais ser alterada.'
              : 'Será registrada uma ocorrência. Depois você poderá retomar o trajeto.'),
=======
  Future<void> _mudarStatus(
      BuildContext context, Entrega e, StatusEntrega novo, {bool confirmar = false}) async {
    if (confirmar) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Marcar como "${novo.rotulo}"?'),
          content: const Text('Esta ação não pode ser desfeita.'),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
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

<<<<<<< HEAD
  Future<void> _abrirMapa(BuildContext context, String destino) async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destino,
      'travelmode': 'driving',
    });
    var abriu = false;
    try {
      abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      abriu = false;
    }
    if (!abriu && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Não foi possível abrir o mapa.')));
    }
  }

=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
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
<<<<<<< HEAD
            appBar: barraApp(titulo: 'Entrega'),
            body: const Center(child: Text('Entrega não encontrada.')),
          );
        }
        final entrega = e;
        final estilo = Theme.of(context).textTheme;

        return Scaffold(
          appBar: barraApp(titulo: entrega.codigoRastreio),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Cartao(
                acento: visualDoStatus(entrega.status).cor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text('Andamento',
                            style: estilo.titleSmall?.copyWith(color: Cores.textoSuave)),
                      ),
                      StatusChip(entrega.status),
                    ]),
                    const SizedBox(height: 16),
                    _Progresso(entrega.status),
                    if (entrega.status == StatusEntrega.ocorrencia) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Esta entrega tem uma ocorrência. Retome o trajeto quando puder tentar de novo.',
                        style: TextStyle(color: Cores.erro),
                      ),
                    ],
                  ],
                ),
              ),
              Cartao(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Linha('Cliente', entrega.clienteNome),
                    _Linha('Origem', entrega.origem),
                    _Linha('Destino', entrega.destino),
                    if (entrega.veiculoPlaca.isNotEmpty) _Linha('Veículo', entrega.veiculoPlaca),
                    if (entrega.dataCriacao != null)
                      _Linha('Criada em', _fmt.format(entrega.dataCriacao!.toLocal())),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.navigation),
                      label: const Text('Abrir destino no mapa'),
                      onPressed: () => _abrirMapa(context, entrega.destino),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
=======
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
              if (entrega.veiculoPlaca.isNotEmpty) _Linha('Veículo', entrega.veiculoPlaca),
              if (entrega.dataCriacao != null)
                _Linha('Criada em', _fmt.format(entrega.dataCriacao!.toLocal())),
              const SizedBox(height: 16),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
              if (entrega.status == StatusEntrega.pendente ||
                  entrega.status == StatusEntrega.ocorrencia)
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: Text(entrega.status == StatusEntrega.ocorrencia
                      ? 'Retomar trajeto'
                      : 'Iniciar trajeto'),
                  onPressed: () => _mudarStatus(context, entrega, StatusEntrega.emTransito),
                ),
              if (entrega.status == StatusEntrega.emTransito) ...[
                FilledButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirmar entrega'),
<<<<<<< HEAD
                  onPressed: () => _mudarStatus(context, entrega, StatusEntrega.concluida),
=======
                  onPressed: () => _mudarStatus(context, entrega, StatusEntrega.concluida,
                      confirmar: true),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Entrega não realizada'),
<<<<<<< HEAD
                  onPressed: () => _mudarStatus(context, entrega, StatusEntrega.ocorrencia),
=======
                  onPressed: () => _mudarStatus(
                      context, entrega, StatusEntrega.ocorrencia, confirmar: true),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
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
<<<<<<< HEAD
              Text('Ocorrências',
                  style: estilo.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (entrega.ocorrencias.isEmpty)
                Text('Nenhuma ocorrência registrada.',
                    style: estilo.bodyMedium?.copyWith(color: Cores.textoSuave))
              else
                ...entrega.ocorrencias.reversed.map((o) => Cartao(
                      acento: Cores.erro,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.descricao, style: estilo.bodyLarge),
                          const SizedBox(height: 6),
                          Text(_fmt.format(o.dataHora.toLocal()),
                              style: estilo.bodySmall?.copyWith(color: Cores.textoSuave)),
                        ],
=======
              Text('Ocorrências', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (entrega.ocorrencias.isEmpty)
                const Text('Nenhuma ocorrência registrada.')
              else
                ...entrega.ocorrencias.reversed.map((o) => Card(
                      child: ListTile(
                        title: Text(o.descricao),
                        trailing: Text(_fmt.format(o.dataHora.toLocal()),
                            style: Theme.of(context).textTheme.bodySmall),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }
}

<<<<<<< HEAD
/// Três etapas: Pendente -> Em trânsito -> Concluída (ocorrência fica em vermelho na etapa 2).
class _Progresso extends StatelessWidget {
  const _Progresso(this.status);
  final StatusEntrega status;

  int get _etapa {
    switch (status) {
      case StatusEntrega.pendente:
        return 0;
      case StatusEntrega.emTransito:
      case StatusEntrega.ocorrencia:
        return 1;
      case StatusEntrega.concluida:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    const rotulos = ['Pendente', 'Em trânsito', 'Concluída'];
    final etapa = _etapa;
    final corAtual = visualDoStatus(status).cor;

    Widget ponto(int i) {
      final feito = i < etapa;
      final atual = i == etapa;
      final cor = (feito || atual) ? (atual ? corAtual : Cores.primaria) : Cores.borda;
      return Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (feito || atual) ? cor : Cores.superficie,
              border: Border.all(color: cor, width: 2),
            ),
            child: Icon(
              feito ? Icons.check : (atual ? Icons.circle : Icons.circle_outlined),
              size: feito ? 16 : 10,
              color: (feito || atual) ? Colors.white : Cores.borda,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rotulos[i],
            style: TextStyle(
              fontSize: 12,
              fontWeight: atual ? FontWeight.w800 : FontWeight.w500,
              color: atual ? Cores.texto : Cores.textoSuave,
            ),
          ),
        ],
      );
    }

    Widget linha(int i) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Container(
              height: 3,
              color: i < etapa ? Cores.primaria : Cores.borda,
            ),
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ponto(0), linha(0), ponto(1), linha(1), ponto(2)],
    );
  }
}

=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
class _Linha extends StatelessWidget {
  const _Linha(this.rotulo, this.valor);
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
<<<<<<< HEAD
          Text(rotulo,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Cores.textoSuave, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
=======
          Text(rotulo, style: Theme.of(context).textTheme.labelMedium),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
          Text(valor, style: Theme.of(context).textTheme.bodyLarge),
        ]),
      );
}
