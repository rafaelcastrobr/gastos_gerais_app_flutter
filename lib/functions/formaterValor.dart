import 'package:intl/intl.dart';

class Formatervalor {
  static String formaterForReal(double valor) {
    double valorNumerico = valor;
    NumberFormat formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String valorFormatado = formatador.format(valorNumerico);

    return valorFormatado;
  }

  static double limparString(String valor, bool entrada, bool saida) {
    String valorFormatado = valor;
    String valorSemPontos = valorFormatado.replaceAll('.', '');
    String valorComPonto = valorSemPontos.replaceAll(',', '.');
    double valorNumerico = double.parse(valorComPonto);
    double valorEntradaSaida = 0;

    if (entrada) {
      valorEntradaSaida = valorNumerico;
    }
    if (saida) {
      valorEntradaSaida = -valorNumerico;
    }

    return valorEntradaSaida;
  }
}
