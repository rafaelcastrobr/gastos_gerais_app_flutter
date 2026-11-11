import 'package:flutter/services.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';

/// Avisa o widget da tela inicial (Android) do saldo atual.
class WidgetSaldo {
  static const MethodChannel _canal = MethodChannel('gastos_gerais/widget');

  /// Nunca lança erro: sem widget ou fora do Android, simplesmente não faz nada.
  static Future<void> atualizar({required double saldo, required bool ocultar}) async {
    try {
      await _canal.invokeMethod<void>('atualizar', <String, dynamic>{
        'saldo': Formatervalor.formaterForReal(saldo),
        'negativo': saldo < 0,
        'oculto': ocultar,
      });
    } catch (_) {
      // o widget é um extra; o app segue funcionando sem ele
    }
  }
}
