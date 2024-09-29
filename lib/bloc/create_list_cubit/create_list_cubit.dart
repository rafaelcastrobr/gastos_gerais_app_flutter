import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'create_list_state.dart';

class CreateListCubit extends Cubit<CreateListState> {
  CreateListCubit() : super(CreateListInitial());

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

  void addTaskMesAtual(String id, String text, double value) async {
    final mesAtual = [...?state.mesAtual, ListasModel(id: id, titulo: text, valor: value)];

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listConvert = jsonEncode(mesAtual);
    prefs.setString('mesAtual', listConvert);

    emit(CreateListState(mesAtual: mesAtual, proxMes: state.proxMes, outros: state.outros, controllerTitulo: state.controllerTitulo, controllerValor: state.controllerValor));
  }

  void addTaskProxMes(String id, String text, double value) async {
    final proxMes = [...?state.proxMes, ListasModel(id: id, titulo: text, valor: value)];

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listConvert = jsonEncode(proxMes);
    prefs.setString('proxMes', listConvert);

    emit(CreateListState(proxMes: proxMes, mesAtual: state.mesAtual, outros: state.outros, controllerTitulo: state.controllerTitulo, controllerValor: state.controllerValor));
  }

  void addTaskOutros(String id, String text, double value) async {
    final outros = [...?state.outros, ListasModel(id: id, titulo: text, valor: value)];

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listConvert = jsonEncode(outros);
    prefs.setString('outros', listConvert);

    emit(CreateListState(outros: outros, mesAtual: state.mesAtual, proxMes: state.proxMes, controllerTitulo: state.controllerTitulo, controllerValor: state.controllerValor));
  }

  void editTaskMesAtual(String id, String titulo, double value) {
    var newListMesAtual = [...?state.mesAtual];

    var editItem = newListMesAtual.where((element) => element.id == id).first;

    editItem.titulo = titulo;
    editItem.valor = value;

    final mesAtual = state.copyWith(mesAtual: newListMesAtual);

    emit(mesAtual);
  }

  void editTaskProxAtual(String id, String titulo, double value) {
    var newListProxMes = [...?state.proxMes];

    var editItem = newListProxMes.where((element) => element.id == id).first;

    editItem.titulo = titulo;
    editItem.valor = value;

    final proxMes = state.copyWith(proxMes: newListProxMes);

    emit(proxMes);
  }

  void editTaskOutros(String id, String titulo, double value) {
    var newListOutros = [...?state.mesAtual];

    var editItem = newListOutros.where((element) => element.id == id).first;

    editItem.titulo = titulo;
    editItem.valor = value;

    final outros = state.copyWith(mesAtual: newListOutros);

    emit(outros);
  }

  void deleteTaskMesAtual(String id) async {
    var newListMesAtual = [...?state.mesAtual];

    var listaAtualizada = newListMesAtual
      ..removeWhere(
        (element) => element.id == id,
      );

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listConvert = jsonEncode(listaAtualizada);
    prefs.setString('mesAtual', listConvert);

    emit(state.copyWith(mesAtual: listaAtualizada, proxMes: state.proxMes, outros: state.outros,controllerTitulo: state.controllerTitulo, controllerValor: state.controllerValor));
  }

  void deleteTaskProxMes(String id) async {
    var newListProxMes = [...?state.proxMes];

    var listaAtualizada = newListProxMes
      ..removeWhere(
        (element) => element.id == id,
      );

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listConvert = jsonEncode(listaAtualizada);
    prefs.setString('proxMes', listConvert);

    emit(state.copyWith(mesAtual: state.mesAtual, proxMes: listaAtualizada, outros: state.outros,controllerTitulo: state.controllerTitulo, controllerValor: state.controllerValor));
  }

  void deleteTaskOutros(String id) async {
    var newListOutros = [...?state.outros];

    var listaAtualizada = newListOutros
      ..removeWhere(
        (element) => element.id == id,
      );

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listConvert = jsonEncode(listaAtualizada);
    prefs.setString('outros', listConvert);

    emit(state.copyWith(mesAtual: state.mesAtual, proxMes: state.proxMes, outros: listaAtualizada,controllerTitulo: state.controllerTitulo, controllerValor: state.controllerValor));
  }

  @override
  CreateListState? fromJson(Map<String, dynamic> json) {
    final initialData = CreateListState.fromMap(json);
    emit(initialData);
    return CreateListState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(CreateListState state) {
    return state.toMap();
  }
}
