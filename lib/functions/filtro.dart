import 'package:gastos_gerais_app_flutter/models/listas_model.dart';

/// Itens que passam pelo filtro de categorias ('' = sem categoria).
/// Filtro vazio = todos os itens.
List<ListasModel> aplicarFiltro(List<ListasModel> itens, Set<String> filtro) {
  if (filtro.isEmpty) return itens;
  return itens.where((e) => filtro.contains(e.categoria)).toList();
}

/// Os itens destacados primeiro. Só muda a ordem de exibição: a ordem salva
/// não muda, então tirar o destaque devolve o item ao lugar de antes.
List<ListasModel> destaquesNoTopo(List<ListasModel> itens) {
  if (!itens.any((e) => e.destaque)) return itens;
  return [...itens.where((e) => e.destaque), ...itens.where((e) => !e.destaque)];
}
