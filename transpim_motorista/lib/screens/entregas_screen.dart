import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';
import '../models/entrega.dart';
<<<<<<< HEAD
import '../theme.dart';
import '../widgets/cartao.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/status_chip.dart';
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
import 'detalhe_screen.dart';

final _fmt = DateFormat('dd/MM HH:mm');

<<<<<<< HEAD
/// Ordem na lista: o que está acontecendo agora aparece primeiro.
int _prioridade(StatusEntrega s) {
  switch (s) {
    case StatusEntrega.emTransito:
      return 0;
    case StatusEntrega.ocorrencia:
      return 1;
    case StatusEntrega.pendente:
      return 2;
    case StatusEntrega.concluida:
      return 3;
  }
}

class EntregasScreen extends StatefulWidget {
  const EntregasScreen({super.key});

  @override
  State<EntregasScreen> createState() => _EntregasScreenState();
}

class _EntregasScreenState extends State<EntregasScreen> {
  StatusEntrega? _filtro; // null = todas

  Future<void> _sair() async {
=======
Color corDoStatus(BuildContext context, StatusEntrega s) {
  switch (s) {
    case StatusEntrega.emTransito:
      return Colors.blue.shade100;
    case StatusEntrega.concluida:
      return Colors.green.shade100;
    case StatusEntrega.ocorrencia:
      return Colors.red.shade100;
    case StatusEntrega.pendente:
      return Theme.of(context).colorScheme.secondaryContainer;
  }
}

class EntregasScreen extends StatelessWidget {
  const EntregasScreen({super.key});

  Future<void> _sair(BuildContext context) async {
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
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
<<<<<<< HEAD
        final todas = app.entregas;
        final visiveis = todas.where((e) => _filtro == null || e.status == _filtro).toList()
          ..sort((a, b) {
            final p = _prioridade(a.status).compareTo(_prioridade(b.status));
            return p != 0 ? p : b.id.compareTo(a.id);
          });

        return Scaffold(
          appBar: barraApp(
            titulo: 'Minhas entregas',
            acoes: [
=======
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
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
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
<<<<<<< HEAD
                  if (v == 'sair') _sair();
=======
                  if (v == 'sair') _sair(context);
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
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
<<<<<<< HEAD
              if (app.lendoDoCache)
                const _Aviso(Icons.cloud_off, 'Sem conexão: mostrando os últimos dados salvos.'),
              if (app.pendentes > 0)
                _Aviso(Icons.sync_problem, '${app.pendentes} operação(ões) aguardando envio.'),
              if (app.carregando) const LinearProgressIndicator(minHeight: 3),
              if (todas.isNotEmpty) _Filtros(
                todas: todas,
                atual: _filtro,
                aoEscolher: (s) => setState(() => _filtro = s),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: app.sincronizar,
                  child: _corpo(todas, visiveis),
=======
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
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
                ),
              ),
            ],
          ),
        );
      },
    );
  }
<<<<<<< HEAD

  Widget _corpo(List<Entrega> todas, List<Entrega> visiveis) {
    // ListView sempre rolável para o "puxar para atualizar" funcionar também nos estados vazios.
    if (todas.isEmpty) {
      final Widget estado;
      if (app.carregando) {
        estado = const Padding(
          padding: EdgeInsets.only(top: 96),
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (app.erro != null) {
        estado = EstadoVazio(
          icone: Icons.wifi_off,
          titulo: 'Não foi possível carregar',
          mensagem: app.erro,
          acaoRotulo: 'Tentar novamente',
          aoAcionar: app.sincronizar,
        );
      } else {
        estado = const EstadoVazio(
          icone: Icons.inbox_outlined,
          titulo: 'Nenhuma entrega por aqui',
          mensagem: 'Quando uma entrega for atribuída a você, ela aparece nesta lista.',
        );
      }
      return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [estado]);
    }

    if (visiveis.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          EstadoVazio(
            icone: Icons.filter_alt_off,
            titulo: 'Nenhuma entrega neste filtro',
            mensagem: 'Escolha outro status acima para ver as demais.',
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: visiveis.length,
      itemBuilder: (context, i) => _CartaoEntrega(visiveis[i]),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.todas, required this.atual, required this.aoEscolher});
  final List<Entrega> todas;
  final StatusEntrega? atual;
  final ValueChanged<StatusEntrega?> aoEscolher;

  @override
  Widget build(BuildContext context) {
    int contar(StatusEntrega s) => todas.where((e) => e.status == s).length;

    Widget chip(String rotulo, StatusEntrega? valor, int qtd) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text('$rotulo ($qtd)'),
            selected: atual == valor,
            onSelected: (_) => aoEscolher(valor),
          ),
        );

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          chip('Todas', null, todas.length),
          chip('Em trânsito', StatusEntrega.emTransito, contar(StatusEntrega.emTransito)),
          chip('Pendentes', StatusEntrega.pendente, contar(StatusEntrega.pendente)),
          chip('Ocorrência', StatusEntrega.ocorrencia, contar(StatusEntrega.ocorrencia)),
          chip('Concluídas', StatusEntrega.concluida, contar(StatusEntrega.concluida)),
        ],
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.icone, this.texto);
  final IconData icone;
  final String texto;
=======
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.icone, this.texto, this.cor);
  final IconData icone;
  final String texto;
  final Color cor;
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
<<<<<<< HEAD
        color: Cores.avisoFundo,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(icone, size: 20, color: Cores.aviso),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(color: Cores.aviso))),
=======
        color: cor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(icone, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
        ]),
      );
}

class _CartaoEntrega extends StatelessWidget {
  const _CartaoEntrega(this.e);
  final Entrega e;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final estilo = Theme.of(context).textTheme;
    return Cartao(
      acento: visualDoStatus(e.status).cor,
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetalheScreen(entregaId: e.id))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(e.codigoRastreio,
                  style: estilo.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
            StatusChip(e.status),
          ]),
          const SizedBox(height: 6),
          Text(e.clienteNome,
              style: estilo.bodyMedium?.copyWith(color: Cores.textoSuave),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          _Trecho(Icons.trip_origin, e.origem, suave: true),
          const SizedBox(height: 4),
          _Trecho(Icons.place, e.destino),
          if (e.dataCriacao != null) ...[
            const SizedBox(height: 8),
            Text('Criada em ${_fmt.format(e.dataCriacao!.toLocal())}',
                style: estilo.bodySmall?.copyWith(color: Cores.textoSuave)),
          ],
        ],
=======
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
              if (e.dataCriacao != null) ...[
                const SizedBox(height: 4),
                Text('Criada em ${_fmt.format(e.dataCriacao!.toLocal())}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
      ),
    );
  }
}
<<<<<<< HEAD

class _Trecho extends StatelessWidget {
  const _Trecho(this.icone, this.texto, {this.suave = false});
  final IconData icone;
  final String texto;
  final bool suave;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 16, color: suave ? Cores.textoSuave : Cores.primaria),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: suave ? Cores.textoSuave : Cores.texto,
                fontWeight: suave ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
        ],
      );
}
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
