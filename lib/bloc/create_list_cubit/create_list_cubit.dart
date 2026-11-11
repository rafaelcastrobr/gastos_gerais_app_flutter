import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:gastos_gerais_app_flutter/functions/backup.dart';
import 'package:gastos_gerais_app_flutter/models/categoria_model.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'create_list_state.dart';

/// As três listas do app. O `name` de cada uma é a chave usada no SharedPreferences
/// (mesAtual, proxMes, outros), a mesma de sempre, então os dados salvos continuam valendo.
enum TipoLista { mesAtual, proxMes, outros }

class CreateListCubit extends Cubit<CreateListState> {
  CreateListCubit() : super(CreateListInitial());

  // ---------------------------------------------------------------- helpers

  /// Cópia da lista atual, que pode ser alterada à vontade.
  List<ListasModel> _lista(TipoLista tipo) {
    switch (tipo) {
      case TipoLista.mesAtual:
        return [...?state.mesAtual];
      case TipoLista.proxMes:
        return [...?state.proxMes];
      case TipoLista.outros:
        return [...?state.outros];
    }
  }

  CreateListState _comLista(TipoLista tipo, List<ListasModel> lista) {
    switch (tipo) {
      case TipoLista.mesAtual:
        return state.copyWith(mesAtual: lista);
      case TipoLista.proxMes:
        return state.copyWith(proxMes: lista);
      case TipoLista.outros:
        return state.copyWith(outros: lista);
    }
  }

  Future<void> _salvar(TipoLista tipo, List<ListasModel> lista) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(tipo.name, jsonEncode(lista));
  }

  Future<void> _atualizar(TipoLista tipo, List<ListasModel> lista) async {
    emit(_comLista(tipo, lista));
    await _salvar(tipo, lista);
  }

  // ------------------------------------------------------------------- init

  void initControllerText(TextEditingController controllerText, TextEditingController controllerValor) {
    emit(state.copyWith(mesAtual: state.mesAtual, proxMes: state.proxMes, outros: state.outros, controllerTitulo: controllerText, controllerValor: controllerValor));
  }

  Future<void> initMesAtual(String mesAtual, String proxMes, String outros, [String categorias = '[]']) async {
    List<ListasModel> mesAtualConvert = [];
    List<ListasModel> proxMesConvert = [];
    List<ListasModel> outrosConvert = [];
    List<Categoria> categoriasConvert = [];

    if (mesAtual.isNotEmpty) {
      var decodedListMesAtual = jsonDecode(mesAtual);
      mesAtualConvert = decodedListMesAtual.map<ListasModel>((item) => ListasModel.fromJson(item)).toList();
    }

    if (proxMes.isNotEmpty) {
      var decodedListProxMes = jsonDecode(proxMes);
      proxMesConvert = decodedListProxMes.map<ListasModel>((item) => ListasModel.fromJson(item)).toList();
    }

    if (outros.isNotEmpty) {
      var decodedListOutros = jsonDecode(outros);
      outrosConvert = decodedListOutros.map<ListasModel>((item) => ListasModel.fromJson(item)).toList();
    }

    if (categorias.isNotEmpty) {
      final decodedCategorias = jsonDecode(categorias);
      if (decodedCategorias is List) {
        categoriasConvert = decodedCategorias.map(Categoria.fromMap).whereType<Categoria>().toList();
      }
    }

    emit(CreateListState(mesAtual: mesAtualConvert, proxMes: proxMesConvert, outros: outrosConvert, categorias: categoriasConvert, controllerTitulo: state.controllerTitulo, controllerValor: state.controllerValor));
  }

  // ------------------------------------------------------ itens de uma lista

  Future<void> adicionar(TipoLista tipo, String id, String titulo, double valor, {bool recorrente = false, int parcelaAtual = 0, int parcelasTotal = 0, String categoria = ''}) async {
    final item = ListasModel(id: id, titulo: titulo, valor: valor, recorrente: recorrente, parcelaAtual: parcelaAtual, parcelasTotal: parcelasTotal, categoria: categoria);
    await _atualizar(tipo, [item, ..._lista(tipo)]);

    if (recorrente && tipo == TipoLista.mesAtual) await _garantirNoProxMes(item);
  }

  /// Edita o item no lugar, mantendo a posição e o id.
  Future<void> editar(TipoLista tipo, String id, String titulo, double valor, {bool recorrente = false, int parcelaAtual = 0, int parcelasTotal = 0, String categoria = ''}) async {
    final lista = _lista(tipo).map((e) => e.id == id ? e.copyWith(titulo: titulo, valor: valor, recorrente: recorrente, parcelaAtual: parcelaAtual, parcelasTotal: parcelasTotal, categoria: categoria) : e).toList();
    await _atualizar(tipo, lista);

    if (recorrente && tipo == TipoLista.mesAtual) {
      await _garantirNoProxMes(lista.firstWhere((e) => e.id == id));
    }
  }

  /// Um item recorrente do mês atual também precisa estar no próximo mês.
  /// Só cria a cópia se ainda não houver um recorrente com o mesmo título lá.
  Future<void> _garantirNoProxMes(ListasModel item) {
    final prox = _lista(TipoLista.proxMes);
    final titulo = item.titulo.trim().toLowerCase();

    final jaTem = prox.any((e) => e.recorrente && e.titulo.trim().toLowerCase() == titulo);
    if (jaTem) return Future.value();

    final copia = item.proximoMes(Guid.generate().value);
    if (copia == null) return Future.value();

    return _atualizar(TipoLista.proxMes, [copia, ...prox]);
  }

  /// Destaca o item (vai para o topo da lista) ou tira o destaque.
  Future<void> alternarDestaque(TipoLista tipo, String id) {
    final lista = _lista(tipo).map((e) => e.id == id ? e.copyWith(destaque: !e.destaque) : e).toList();
    return _atualizar(tipo, lista);
  }

  Future<void> remover(TipoLista tipo, String id) {
    final lista = _lista(tipo)..removeWhere((e) => e.id == id);
    return _atualizar(tipo, lista);
  }

  /// Desfaz um `remover`: devolve o item para a posição em que estava.
  Future<void> restaurar(TipoLista tipo, ListasModel item, int indice) {
    final lista = _lista(tipo);
    if (lista.any((e) => e.id == item.id)) return Future.value();

    final posicao = indice < 0 ? 0 : (indice > lista.length ? lista.length : indice);
    lista.insert(posicao, item);
    return _atualizar(tipo, lista);
  }

  /// Passa tudo do próximo mês para o mês atual.
  /// Os itens recorrentes continuam no próximo mês, como uma cópia nova
  /// (com a parcela seguinte, até chegar na última).
  Future<void> sendMesAtual() async {
    final prox = [...?state.proxMes];
    final mesAtual = [...?state.mesAtual, ...prox];
    final proxMes = <ListasModel>[];
    for (final e in prox) {
      final proximo = e.proximoMes(Guid.generate().value);
      if (proximo != null) proxMes.add(proximo);
    }

    emit(state.copyWith(mesAtual: mesAtual, proxMes: proxMes));

    await _salvar(TipoLista.mesAtual, mesAtual);
    await _salvar(TipoLista.proxMes, proxMes);
  }

  // ----------------------------------------------------------------- backup

  // -------------------------------------------------------------- categorias

  Future<void> _salvarCategorias(List<Categoria> categorias) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('categorias', jsonEncode(categorias.map((c) => c.toMap()).toList()));
  }

  /// Cria uma categoria (sem repetir o nome, ignorando maiúsculas).
  /// Devolve a categoria que ficou valendo, ou null se o nome estiver vazio.
  Future<Categoria?> criarCategoria(String nome, String icone) async {
    final limpo = nome.trim();
    if (limpo.isEmpty) return null;

    final categorias = [...?state.categorias];
    final existentes = categorias.where((c) => c.nome.toLowerCase() == limpo.toLowerCase());
    if (existentes.isNotEmpty) return existentes.first;

    final nova = Categoria(nome: limpo, icone: icone.trim());
    categorias.add(nova);

    emit(state.copyWith(categorias: categorias));
    await _salvarCategorias(categorias);
    return nova;
  }

  /// Troca o nome e/ou o ícone de uma categoria. Os itens que usam a categoria
  /// passam para o novo nome. Devolve uma mensagem de erro, ou null se deu certo.
  Future<String?> editarCategoria(String nomeAntigo, String novoNome, String novoIcone) async {
    final nome = novoNome.trim();
    if (nome.isEmpty) return 'O nome não pode ficar vazio.';

    final categorias = [...?state.categorias];
    final jaExiste = categorias.any((c) => c.nome != nomeAntigo && c.nome.toLowerCase() == nome.toLowerCase());
    if (jaExiste) return 'Já existe uma categoria com esse nome.';

    final novas = categorias.map((c) => c.nome == nomeAntigo ? Categoria(nome: nome, icone: novoIcone.trim()) : c).toList();

    List<ListasModel> troca(List<ListasModel>? lista) {
      return (lista ?? []).map((e) => e.categoria == nomeAntigo ? e.copyWith(categoria: nome) : e).toList();
    }

    final mesAtual = troca(state.mesAtual);
    final proxMes = troca(state.proxMes);
    final outros = troca(state.outros);

    emit(state.copyWith(mesAtual: mesAtual, proxMes: proxMes, outros: outros, categorias: novas));
    await _salvar(TipoLista.mesAtual, mesAtual);
    await _salvar(TipoLista.proxMes, proxMes);
    await _salvar(TipoLista.outros, outros);
    await _salvarCategorias(novas);
    return null;
  }

  /// Apaga a categoria. Os itens que usavam ela ficam sem categoria.
  Future<void> apagarCategoria(String nome) async {
    final novas = (state.categorias ?? []).where((c) => c.nome != nome).toList();

    List<ListasModel> limpa(List<ListasModel>? lista) {
      return (lista ?? []).map((e) => e.categoria == nome ? e.copyWith(categoria: '') : e).toList();
    }

    final mesAtual = limpa(state.mesAtual);
    final proxMes = limpa(state.proxMes);
    final outros = limpa(state.outros);

    emit(state.copyWith(mesAtual: mesAtual, proxMes: proxMes, outros: outros, categorias: novas));
    await _salvar(TipoLista.mesAtual, mesAtual);
    await _salvar(TipoLista.proxMes, proxMes);
    await _salvar(TipoLista.outros, outros);
    await _salvarCategorias(novas);
  }

  // ----------------------------------------------------------------- backup

  String gerarBackup() {
    return Backup.gerar(BackupDados(mesAtual: state.mesAtual ?? [], proxMes: state.proxMes ?? [], outros: state.outros ?? [], categorias: state.categorias ?? []));
  }

  /// Troca os dados atuais pelos do backup.
  Future<void> restaurarBackup(BackupDados dados) async {
    // categorias: junta as atuais com as do backup (o backup vence se o nome for igual)
    final categorias = {for (final c in [...?state.categorias, ...dados.categorias]) c.nome.toLowerCase(): c}.values.toList();

    emit(state.copyWith(mesAtual: dados.mesAtual, proxMes: dados.proxMes, outros: dados.outros, categorias: categorias));

    await _salvar(TipoLista.mesAtual, dados.mesAtual);
    await _salvar(TipoLista.proxMes, dados.proxMes);
    await _salvar(TipoLista.outros, dados.outros);
    await _salvarCategorias(categorias);
  }
}
