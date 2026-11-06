// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ListasModel extends Equatable {
  String id;
  String titulo;
  double valor;
  int iconEnum;
  bool recorrente;

  ListasModel({required this.id, required this.titulo, required this.valor, this.iconEnum = 0, this.recorrente = false});

  @override
  List<Object> get props => [id, titulo, valor, iconEnum, recorrente];

  ListasModel copyWith({
    String? titulo,
    String? id,
    double? valor,
    int? iconEnum,
    bool? recorrente,
  }) {
    return ListasModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      valor: valor ?? this.valor,
      iconEnum: iconEnum ?? this.iconEnum,
      recorrente: recorrente ?? this.recorrente,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'valor': valor,
      'iconEnum': iconEnum,
      'recorrente': recorrente,
    };
  }

  factory ListasModel.fromMap(Map<String, dynamic> map) {
    return ListasModel(
      id: map['id'] ?? Guid.generate(),
      titulo: map['titulo'] ?? '',
      valor: map['valor'] ?? 0,
      iconEnum: map['iconEnum'] ?? 0,
      recorrente: map['recorrente'] == true,
    );
  }

  String toJson() => json.encode(toMap());

  factory ListasModel.fromJson(String source) => ListasModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
