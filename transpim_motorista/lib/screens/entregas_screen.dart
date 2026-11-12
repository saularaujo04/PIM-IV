import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';
import '../models/entrega.dart';
import 'detalhe_screen.dart';

final _fmt = DateFormat('dd/MM HH:mm');

Color corDoStatus(BuildContext context, StatusEntrega s) {
  switch (s) {
    case StatusEntrega.emRota:
      return Colors.blue.shade100;
    case StatusEntrega.entregue:
      return Colors.green.shade100;
    case StatusEntrega.naoRealizada:
    case StatusEntrega.cancelada:
      return Colors.red.shade100;
    default:
      return Theme.of(context).colorScheme.secondaryContainer;
  }
}

class EntregasScreen extends StatelessWidget {
  const EntregasScreen({super.key});

  Future<void> _sair(BuildContext context) async {
    if (app.pendentes > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Sair mesmo assim?'),
          content: Text(
              'Há ${app.pendentes} operação(ões) ainda não enviada(s). Elas serão perdidas.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sair')),
          ],
        ),
      );
      if (ok != true) return;
    }
    await app.logout();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final avisos = <Widget>[
          if (app.lendoDoCache)
            _Aviso(Icons.cloud_off, 'Sem conexão: mostrando os últimos dados salvos.',
                Colors.orange.shade100),
          if (app.pendentes > 0)
            _Aviso(Icons.sync_problem,
                '${app.pendentes} operação(ões) aguardando envio.', Colors.amber.shade100),
        ];
        return Scaffold(
          appBar: AppBar(
            title: const Text('Minhas entregas'),
            actions: [
              IconButton(
                tooltip: 'Sincronizar',
                onPressed: app.carregando ? null : app.sincronizar,
                icon: Badge(
                  isLabelVisible: app.pendentes > 0,
                  label: Text('${app.pendentes}'),
                  child: const Icon(Icons.sync),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'sair') _sair(context);
                  if (v == 'offline') app.alternarOffline();
                },
                itemBuilder: (_) => [
                  if (app.ehMock)
                    PopupMenuItem(
                      value: 'offline',
                      child: Text(app.simulandoOffline
                          ? 'Voltar online (simulação)'
                          : 'Simular sem conexão'),
                    ),
                  const PopupMenuItem(value: 'sair', child: Text('Sair')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              ...avisos,
              if (app.carregando) const LinearProgressIndicator(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: app.sincronizar,
                  child: app.entregas.isEmpty
                      ? ListView(children: [
                          const SizedBox(height: 160),
                          Center(
                              child: Text(app.carregando
                                  ? 'Carregando...'
                                  : (app.erro ?? 'Nenhuma entrega atribuída a você.'))),
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: app.entregas.length,
                          itemBuilder: (context, i) => _CartaoEntrega(app.entregas[i]),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.icone, this.texto, this.cor);
  final IconData icone;
  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: cor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(icone, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ]),
      );
}

class _CartaoEntrega extends StatelessWidget {
  const _CartaoEntrega(this.e);
  final Entrega e;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => DetalheScreen(entregaId: e.id))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(e.codigoRastreio,
                        style: Theme.of(context).textTheme.titleMedium)),
                Chip(
                  label: Text(e.status.rotulo),
                  backgroundColor: corDoStatus(context, e.status),
                ),
              ]),
              const SizedBox(height: 4),
              Text(e.clienteNome),
              const SizedBox(height: 4),
              Text(e.destino, style: Theme.of(context).textTheme.bodyMedium),
              if (e.dataPrevista != null) ...[
                const SizedBox(height: 4),
                Text('Previsão: ${_fmt.format(e.dataPrevista!.toLocal())}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
