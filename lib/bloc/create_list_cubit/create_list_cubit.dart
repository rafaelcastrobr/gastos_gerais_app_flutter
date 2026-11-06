import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gastos_gerais_app_flutter/functions/backup.dart';
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

  void initMesAtual(String mesAtual, String proxMes, String outros) async {
    List<ListasModel> mesAtualConvert = [];
    List<ListasModel> proxMesConvert = [];
    List<ListasModel> outrosConvert = [];

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

    emit(CreateListState(mesAtual: mesAtualConvert, proxMes: proxMesConvert, outros: outrosConvert, controllerTitulo: state.controllerTitulo, controllerValor: state.controllerValor));
  }

  // ------------------------------------------------------ itens de uma lista

  Future<void> adicionar(TipoLista tipo, String id, String titulo, double valor) {
    final lista = [ListasModel(id: id, titulo: titulo, valor: valor), ..._lista(tipo)];
    return _atualizar(tipo, lista);
  }

  /// Edita o item no lugar, mantendo a posição e o id.
  Future<void> editar(TipoLista tipo, String id, String titulo, double valor) {
    final lista = _lista(tipo).map((e) => e.id == id ? e.copyWith(titulo: titulo, valor: valor) : e).toList();
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
  Future<void> sendMesAtual() async {
    final mesAtual = [...?state.mesAtual, ...?state.proxMes];
    final proxMes = <ListasModel>[];

    emit(state.copyWith(mesAtual: mesAtual, proxMes: proxMes));

    await _salvar(TipoLista.mesAtual, mesAtual);
    await _salvar(TipoLista.proxMes, proxMes);
  }

  // ----------------------------------------------------------------- backup

  String gerarBackup() {
    return Backup.gerar(BackupDados(mesAtual: state.mesAtual ?? [], proxMes: state.proxMes ?? [], outros: state.outros ?? []));
  }

  /// Troca os dados atuais pelos do backup.
  Future<void> restaurarBackup(BackupDados dados) async {
    emit(state.copyWith(mesAtual: dados.mesAtual, proxMes: dados.proxMes, outros: dados.outros));

    await _salvar(TipoLista.mesAtual, dados.mesAtual);
    await _salvar(TipoLista.proxMes, dados.proxMes);
    await _salvar(TipoLista.outros, dados.outros);
  }
}
