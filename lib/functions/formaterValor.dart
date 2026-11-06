import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Formatervalor {
  static String formaterForReal(double valor) {
    double valorNumerico = valor;
    NumberFormat formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String valorFormatado = formatador.format(valorNumerico);

    return valorFormatado;
  }

  /// Valor sem o símbolo da moeda e sem sinal, para preencher um campo de texto (ex.: 1.234,50).
  static String paraCampo(double valor) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: '').format(valor.abs()).trim();
  }

  static double limparString2(String valor, bool entrada, bool saida) {
    String valorFormatado = valor.trim();
    String valorComPonto = valorFormatado.replaceAll(',', '.');

    // Remove todos os pontos, exceto o último
    int lastDotIndex = valorComPonto.lastIndexOf('.');
    if (lastDotIndex != -1) {
      valorComPonto = valorComPonto.replaceAll('.', '');
      valorComPonto = '${valorComPonto.substring(0, lastDotIndex)}.${valorComPonto.substring(lastDotIndex)}';
    }

    double valorNumerico = valorComPonto.isEmpty ? 0.0 : double.parse(valorComPonto);
    double valorEntradaSaida = 0.0;

    if (entrada) {
      valorEntradaSaida = valorComPonto.contains('-') ? valorNumerico.abs() : valorNumerico;
    }
    if (saida) {
      valorEntradaSaida = -valorNumerico;
    }

    if (!saida && !entrada) {
      valorEntradaSaida = valorNumerico;
    }

    return valorEntradaSaida;
  }

  static double limparString(String valor, bool entrada, bool saida) {
    String valorFormatado = valor.trim();
    String valorComPonto = valorFormatado.replaceAll(',', '.');

    int lastDotIndex = valorComPonto.lastIndexOf('.');
    if (lastDotIndex != -1) {
      valorComPonto = valorComPonto.substring(0, lastDotIndex).replaceAll('.', '') + valorComPonto.substring(lastDotIndex);
    }

    double valorNumerico = valorComPonto.isEmpty ? 0.0 : double.parse(valorComPonto);
    double valorEntradaSaida = 0.0;

    if (entrada) {
      valorEntradaSaida = valorComPonto.contains('-') ? valorNumerico.abs() : valorNumerico;
    }
    if (saida) {
      valorEntradaSaida = -valorNumerico;
    }

    if (!saida && !entrada) {
      valorEntradaSaida = valorNumerico;
    }

    return valorEntradaSaida;
  }

  static Color verificaSeENegativo(String valor) {
    bool valorDouble = valor.contains('-');

    return valorDouble ? Colors.red : const Color.fromARGB(255, 9, 101, 177);
  }
}
