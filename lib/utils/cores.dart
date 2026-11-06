import 'package:flutter/material.dart';

/// Paleta do app nos modos claro e escuro. O escuro segue o desenho aprovado
/// (cartão cinza bem escuro, valores em vermelho/azul suaves, âmbar na soma).
class AppCores {
  final bool escuro;

  const AppCores._(this.escuro);

  factory AppCores.of(BuildContext context) {
    return AppCores._(Theme.of(context).brightness == Brightness.dark);
  }

  Color get fundo => escuro ? const Color(0xFF121212) : const Color(0xFFFBE9E7);
  Color get cartao => escuro ? const Color(0xFF1C1C1C) : Colors.white;
  Color get borda => escuro ? const Color(0xFF2E2E2E) : const Color(0x1F000000);
  Color get texto => escuro ? const Color(0xFFECEAE3) : const Color(0xFF2C2C2A);
  Color get textoSecundario => escuro ? const Color(0xFFC9C7BE) : const Color(0xFF5F5E5A);
  Color get mudo => escuro ? const Color(0xFF8E8D86) : const Color(0xFF888780);
  Color get positivo => escuro ? const Color(0xFF6EA8E8) : const Color(0xFF185FA5);
  Color get negativo => escuro ? const Color(0xFFE47D7D) : const Color(0xFFA32D2D);
  Color get somaFundo => escuro ? const Color(0xFF341C00) : const Color(0xFFFAEEDA);
  Color get somaIcone => escuro ? const Color(0xFFE69A1F) : const Color(0xFFBA7517);
  Color get botao => escuro ? const Color(0xFFECEAE3) : Colors.black;
  Color get botaoTexto => escuro ? const Color(0xFF121212) : Colors.white;

  /// Cor de um valor já formatado: negativo em vermelho, positivo em azul.
  Color valor(String formatado) => formatado.contains('-') ? negativo : positivo;
}
