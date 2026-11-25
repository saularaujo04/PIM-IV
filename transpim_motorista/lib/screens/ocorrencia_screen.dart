import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/entrega.dart';
<<<<<<< HEAD
import '../theme.dart';
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d

class OcorrenciaScreen extends StatefulWidget {
  const OcorrenciaScreen({super.key, required this.entregaId});
  final int entregaId;

  @override
  State<OcorrenciaScreen> createState() => _OcorrenciaScreenState();
}

class _OcorrenciaScreenState extends State<OcorrenciaScreen> {
  final _form = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  TipoOcorrencia _tipo = TipoOcorrencia.ausenteDestinatario;
  bool _salvando = false;

  @override
  void dispose() {
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    Entrega? entrega;
    for (final x in app.entregas) {
      if (x.id == widget.entregaId) entrega = x;
    }
    if (entrega == null) return;
    setState(() => _salvando = true);
    final msg = await app.registrarOcorrencia(entrega, _tipo, _descricao.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg ?? 'Ocorrência registrada.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: barraApp(titulo: 'Registrar ocorrência'),
=======
      appBar: AppBar(title: const Text('Registrar ocorrência')),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
<<<<<<< HEAD
            Text('Tipo',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
=======
            Text('Tipo', style: Theme.of(context).textTheme.titleMedium),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TipoOcorrencia.values
                  .map((t) => ChoiceChip(
                        label: Text(t.rotulo),
                        selected: _tipo == t,
                        onSelected: (_) => setState(() => _tipo = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descricao,
              maxLines: 4,
              maxLength: 500,
<<<<<<< HEAD
              decoration: decoracaoCampo('Descrição'),
=======
              decoration: const InputDecoration(
                  labelText: 'Descrição', border: OutlineInputBorder()),
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Descreva brevemente o ocorrido.' : null,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(
                      height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Salvar ocorrência'),
            ),
          ],
        ),
      ),
    );
  }
}
