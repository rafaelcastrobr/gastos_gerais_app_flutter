import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Formatervalor {
  static String formaterForReal(double valor) {
    double valorNumerico = valor;
    NumberFormat formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String valorFormatado = formatador.format(valorNumerico);

    return valorFormatado;
  }

  static double limparString(String valor, bool entrada, bool saida) {
    String valorFormatado = valor.trim();
    String valorComPonto = valorFormatado.replaceAll(',', '.');
    double valorNumerico = valorComPonto.isEmpty ? 0.0 : double.parse(valorComPonto);
    double valorEntradaSaida = 0.0;

    if (entrada) {
      valorEntradaSaida =valorComPonto.contains('-') ? valorNumerico.abs() : valorNumerico;
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

    return valorDouble ? Colors.red : Colors.blue;
  }
}
