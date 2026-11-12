import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/entrega.dart';

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
      appBar: AppBar(title: const Text('Registrar ocorrência')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Tipo', style: Theme.of(context).textTheme.titleMedium),
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
              decoration: const InputDecoration(
                  labelText: 'Descrição', border: OutlineInputBorder()),
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
