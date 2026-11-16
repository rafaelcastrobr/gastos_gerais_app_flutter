import 'package:shared_preferences/shared_preferences.dart';

/// Opção "passar o saldo negativo para o Próx. Mês".
///
/// Ligada, quando o Mês Atual fecha negativo o app mantém no Próx. Mês um item
/// 💣 com esse valor, em dia a cada mudança do Mês Atual. Apagar o item não
/// desliga a opção: ele volta na próxima mudança do Mês Atual.
class SaldoNegativo {
  static const String _chave = 'passarSaldoNegativo';

  /// Id do item automático, para não existir mais de um.
  static const String idItem = 'saldo-negativo-automatico';

  static const String titulo = '💣 Saldo do mês anterior';

  static Future<bool> ativo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chave) ?? false;
  }

  static Future<void> definir(bool ativo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, ativo);
  }
}
