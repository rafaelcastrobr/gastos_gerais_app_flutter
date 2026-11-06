import 'dart:convert';

import 'package:gastos_gerais_app_flutter/models/listas_model.dart';

/// Conteúdo de um backup: as três listas do app.
class BackupDados {
  final List<ListasModel> mesAtual;
  final List<ListasModel> proxMes;
  final List<ListasModel> outros;

  const BackupDados({required this.mesAtual, required this.proxMes, required this.outros});

  int get total => mesAtual.length + proxMes.length + outros.length;
}

/// Gera e lê o backup como texto JSON (para copiar e colar).
class Backup {
  static const String _app = 'gastos_gerais';
  static const int _versao = 1;

  static String gerar(BackupDados dados) {
    final mapa = <String, dynamic>{
      'app': _app,
      'versao': _versao,
      'exportadoEm': DateTime.now().toIso8601String(),
      'mesAtual': dados.mesAtual.map((e) => e.toMap()).toList(),
      'proxMes': dados.proxMes.map((e) => e.toMap()).toList(),
      'outros': dados.outros.map((e) => e.toMap()).toList(),
    };
    return jsonEncode(mapa);
  }

  /// Lê o texto de um backup. Lança [FormatException] com uma mensagem
  /// pronta para mostrar ao usuário se o texto não for um backup válido.
  static BackupDados ler(String texto) {
    Object? bruto;
    try {
      bruto = jsonDecode(texto.trim());
    } catch (_) {
      throw const FormatException('O texto colado não é um backup válido.');
    }

    if (bruto is! Map<String, dynamic> || bruto['app'] != _app) {
      throw const FormatException('Esse texto não é um backup do Gastos Gerais.');
    }

    return BackupDados(
      mesAtual: _lerLista(bruto['mesAtual']),
      proxMes: _lerLista(bruto['proxMes']),
      outros: _lerLista(bruto['outros']),
    );
  }

  static List<ListasModel> _lerLista(Object? bruto) {
    if (bruto == null) return [];
    if (bruto is! List) {
      throw const FormatException('O backup tem uma lista inválida.');
    }

    final itens = <ListasModel>[];
    for (final item in bruto) {
      if (item is! Map) {
        throw const FormatException('O backup tem um item inválido.');
      }

      final id = item['id'];
      final titulo = item['titulo'];
      final valor = item['valor'];
      final icone = item['iconEnum'];

      if (id is! String || titulo is! String || valor is! num) {
        throw const FormatException('O backup tem um item inválido.');
      }

      itens.add(ListasModel(id: id, titulo: titulo, valor: valor.toDouble(), iconEnum: icone is int ? icone : 0, recorrente: item['recorrente'] == true));
    }
    return itens;
  }
}
