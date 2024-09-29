import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:meta/meta.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'create_list_state.dart';

class CreateListCubit extends Cubit<CreateListState> {
  CreateListCubit() : super(CreateListInitial());

  void initMesAtual(List<ListasModel> mesAtual, List<ListasModel> proxMes, List<ListasModel> outros) async {
    
    emit(CreateListState(mesAtual: mesAtual, proxMes: proxMes, outros: outros));
  }

  void addTaskMesAtual(String id, String text, int value) async {
    final mesAtual = [...?state.mesAtual, ListasModel(id: id, titulo: text, valor: value)];
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listConvert = jsonEncode(mesAtual);
    prefs.setString('mesAtual', listConvert);


    emit(CreateListState(mesAtual: mesAtual));
  }

  void addTaskProxMes(String id, String text, int value) {
    final proxMes = [...?state.proxMes, ListasModel(id: id, titulo: text, valor: value)];
    emit(CreateListState(proxMes: proxMes));
  }

  void addTaskOutros(String id, String text, int value) {
    final outros = [...?state.outros, ListasModel(id: id, titulo: text, valor: value)];
    emit(CreateListState(outros: outros));
  }

  void editTaskMesAtual(String id, String titulo, int value) {
    var newListMesAtual = [...?state.mesAtual];

    var editItem = newListMesAtual.where((element) => element.id == id).first;

    editItem.titulo = titulo;
    editItem.valor = value;

    final mesAtual = state.copyWith(mesAtual: newListMesAtual);

    emit(mesAtual);
  }

  void editTaskProxAtual(String id, String titulo, int value) {
     var newListProxMes = [...?state.proxMes];

    var editItem = newListProxMes.where((element) => element.id == id).first;

    editItem.titulo = titulo;
    editItem.valor = value;

    final proxMes = state.copyWith(proxMes: newListProxMes);

    emit(proxMes);
  }

  void editTaskOutros(String id, String titulo, int value) {
    var newListOutros = [...?state.mesAtual];

    var editItem = newListOutros.where((element) => element.id == id).first;

    editItem.titulo = titulo;
    editItem.valor = value;

    final outros = state.copyWith(mesAtual: newListOutros);

    emit(outros);
  }


  void deleteTaskMesAtual(String id) async{
    var newListMesAtual = [...?state.mesAtual];

    var listaAtualizada = newListMesAtual
          ..removeWhere(
            (element) => element.id == id,
          );

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listConvert = jsonEncode(listaAtualizada);
    prefs.setString('mesAtual', listConvert);

    emit(state.copyWith(mesAtual: listaAtualizada));
  }

  void deleteTaskProxAtual(String id) {
    var newListProxMes = [...?state.proxMes];
    final proxMes = state.copyWith(
        mesAtual: newListProxMes
          ..removeWhere(
            (element) => element.id == id,
          ));

    emit(proxMes);
  }

  void deleteTaskOutros(String id) {
    var newListOutros = [...?state.outros];
    final outros = state.copyWith(
        mesAtual: newListOutros
          ..removeWhere(
            (element) => element.id == id,
          ));

    emit(outros);
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
