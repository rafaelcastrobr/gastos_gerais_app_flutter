import 'package:gastos_gerais_app_flutter/models/listas_model.dart';

/// Itens que passam pelo filtro de categorias ('' = sem categoria).
/// Filtro vazio = todos os itens.
List<ListasModel> aplicarFiltro(List<ListasModel> itens, Set<String> filtro) {
  if (filtro.isEmpty) return itens;
  return itens.where((e) => filtro.contains(e.categoria)).toList();
}
