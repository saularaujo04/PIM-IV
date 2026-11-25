import 'package:flutter/material.dart';
<<<<<<< HEAD

import '../app_state.dart';
import '../config.dart';
import '../theme.dart';
=======
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../config.dart';
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _senha = TextEditingController();
  bool _ocultar = true;

  @override
  void dispose() {
    _usuario.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    await app.login(_usuario.text.trim(), _senha.text);
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final estilo = Theme.of(context).textTheme;
=======
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
<<<<<<< HEAD
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: app,
                builder: (context, _) => Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(
                            color: Cores.sidebar,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_shipping,
                              size: 42, color: Cores.marca),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('TransPIM',
                          textAlign: TextAlign.center,
                          style: estilo.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800, color: Cores.texto)),
                      const SizedBox(height: 4),
                      Text('Área do motorista',
                          textAlign: TextAlign.center,
                          style: estilo.bodyLarge?.copyWith(color: Cores.textoSuave)),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _usuario,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username, AutofillHints.email],
                        decoration: decoracaoCampo('E-mail', icone: Icons.mail_outline),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Informe o e-mail.' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senha,
                        obscureText: _ocultar,
                        onFieldSubmitted: (_) => _entrar(),
                        autofillHints: const [AutofillHints.password],
                        decoration: decoracaoCampo(
                          'Senha',
                          icone: Icons.lock_outline,
                          sufixo: IconButton(
                            tooltip: _ocultar ? 'Mostrar senha' : 'Ocultar senha',
                            icon: Icon(_ocultar ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _ocultar = !_ocultar),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Informe a senha.' : null,
                      ),
                      if (app.erro != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Cores.erroFundo,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline, color: Cores.erro),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(app.erro!, style: const TextStyle(color: Cores.erro)),
                            ),
                          ]),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: app.carregando ? null : _entrar,
                        child: app.carregando
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Entrar'),
                      ),
                      if (AppConfig.useMock) ...[
                        const SizedBox(height: 16),
                        Text('Modo simulado: use qualquer e-mail e a senha 123.',
                            textAlign: TextAlign.center,
                            style: estilo.bodySmall?.copyWith(color: Cores.textoSuave)),
                      ],
                    ],
                  ),
=======
            child: ListenableBuilder(
              listenable: app,
              builder: (context, _) => Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.local_shipping,
                        size: 72, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('TransPIM Motorista',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _usuario,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                      decoration: const InputDecoration(
                          labelText: 'E-mail', border: OutlineInputBorder()),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Informe o e-mail.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senha,
                      obscureText: _ocultar,
                      onFieldSubmitted: (_) => _entrar(),
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _ocultar ? 'Mostrar senha' : 'Ocultar senha',
                          icon: Icon(_ocultar ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _ocultar = !_ocultar),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe a senha.' : null,
                    ),
                    if (app.erro != null) ...[
                      const SizedBox(height: 12),
                      Text(app.erro!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: app.carregando ? null : _entrar,
                      child: app.carregando
                          ? const SizedBox(
                              height: 24, width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Entrar'),
                    ),
                    if (AppConfig.useMock) ...[
                      const SizedBox(height: 16),
                      Text('Modo simulado: use qualquer e-mail e a senha 123.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
