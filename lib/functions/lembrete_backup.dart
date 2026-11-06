import 'package:shared_preferences/shared_preferences.dart';

/// Guarda quando foi o último backup e de quantos em quantos dias o app lembra de salvar outro.
class LembreteBackup {
  /// O intervalo do lembrete pode ser escolhido de 7 a 15 dias.
  static const int minDias = 7;
  static const int maxDias = 15;
  static const int padraoDias = 15;

  static const String _chaveUltimo = 'ultimoBackup';
  static const String _chaveIntervalo = 'lembreteDias';

  /// Anota que o backup foi feito agora.
  static Future<void> marcarFeito() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveUltimo, DateTime.now().millisecondsSinceEpoch);
  }

  /// Quantos dias se passaram desde o último backup.
  /// Na primeira vez não há registro: começa a contar a partir de agora.
  static Future<int> diasSemBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimo = prefs.getInt(_chaveUltimo);

    if (ultimo == null) {
      await prefs.setInt(_chaveUltimo, DateTime.now().millisecondsSinceEpoch);
      return 0;
    }

    return DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ultimo)).inDays;
  }

  /// De quantos em quantos dias o app lembra (sempre entre 7 e 15).
  static Future<int> intervalo() async {
    final prefs = await SharedPreferences.getInstance();
    final dias = prefs.getInt(_chaveIntervalo) ?? padraoDias;
    return dias.clamp(minDias, maxDias).toInt();
  }

  static Future<void> definirIntervalo(int dias) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveIntervalo, dias.clamp(minDias, maxDias).toInt());
  }
}
