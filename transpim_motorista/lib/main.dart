import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/entregas_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.iniciar();
  runApp(const TransPimApp());
}

class TransPimApp extends StatelessWidget {
  const TransPimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TransPIM Motorista',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1F4E9C),
        useMaterial3: true,
        // Alvos de toque amplos: uso em campo, com uma mão.
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        ),
      ),
      home: ListenableBuilder(
        listenable: app,
        builder: (context, _) =>
            app.logado ? const EntregasScreen() : const LoginScreen(),
      ),
    );
  }
}
