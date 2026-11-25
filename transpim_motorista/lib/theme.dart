import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/entrega.dart';

/// Paleta única do TransPIM (a mesma do painel web: wwwroot/estilos/app.css).
class Cores {
  static const marca = Color(0xFF0EA5E9);
  static const primaria = Color(0xFF0369A1); // marca mais escura: contraste melhor com texto branco
  static const sidebar = Color(0xFF0F172A);
  static const fundo = Color(0xFFF1F5F9);
  static const superficie = Color(0xFFFFFFFF);
  static const texto = Color(0xFF0F172A);
  static const textoSuave = Color(0xFF64748B);
  static const borda = Color(0xFFE2E8F0);
  static const erro = Color(0xFFB91C1C);
  static const erroFundo = Color(0xFFFEE2E2);
  static const aviso = Color(0xFFB45309);
  static const avisoFundo = Color(0xFFFEF3C7);
}

/// Cores e ícone de cada status (iguais às do painel web).
class VisualStatus {
  const VisualStatus(this.cor, this.fundo, this.icone);
  final Color cor;
  final Color fundo;
  final IconData icone;
}

VisualStatus visualDoStatus(StatusEntrega s) {
  switch (s) {
    case StatusEntrega.pendente:
      return const VisualStatus(Color(0xFFB45309), Color(0xFFFEF3C7), Icons.schedule);
    case StatusEntrega.emTransito:
      return const VisualStatus(Color(0xFF1D4ED8), Color(0xFFDBEAFE), Icons.local_shipping);
    case StatusEntrega.concluida:
      return const VisualStatus(Color(0xFF047857), Color(0xFFD1FAE5), Icons.check_circle);
    case StatusEntrega.ocorrencia:
      return const VisualStatus(Color(0xFFB91C1C), Color(0xFFFEE2E2), Icons.report_problem);
  }
}

ThemeData construirTema() {
  final esquema = ColorScheme.fromSeed(seedColor: Cores.marca)
      .copyWith(primary: Cores.primaria, onPrimary: Colors.white);

  final formaBotao = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: Cores.fundo,
    // Alvos de toque amplos: uso em campo, com uma mão.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: formaBotao,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: formaBotao,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
  );
}

/// Barra superior escura (mesma identidade do menu lateral do painel).
AppBar barraApp({required String titulo, List<Widget>? acoes}) => AppBar(
      title: Text(titulo),
      actions: acoes,
      backgroundColor: Cores.sidebar,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
      scrolledUnderElevation: 0,
    );

/// Campo de formulário padrão (cantos arredondados, fundo branco).
InputDecoration decoracaoCampo(String rotulo, {IconData? icone, Widget? sufixo}) {
  final borda = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Cores.borda),
  );
  return InputDecoration(
    labelText: rotulo,
    prefixIcon: icone == null ? null : Icon(icone),
    suffixIcon: sufixo,
    filled: true,
    fillColor: Cores.superficie,
    border: borda,
    enabledBorder: borda,
  );
}
