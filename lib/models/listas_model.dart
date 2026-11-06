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
  int parcelaAtual;
  int parcelasTotal;

  ListasModel({required this.id, required this.titulo, required this.valor, this.iconEnum = 0, this.recorrente = false, this.parcelaAtual = 0, this.parcelasTotal = 0});

  bool get temParcelas => parcelasTotal > 0;

  /// O item que entra no mês seguinte, ou null se não há mais o que repetir
  /// (não é recorrente, ou esta era a última parcela).
  ListasModel? proximoMes(String novoId) {
    if (!recorrente) return null;
    if (!temParcelas) return copyWith(id: novoId);
    if (parcelaAtual >= parcelasTotal) return null;
    return copyWith(id: novoId, parcelaAtual: parcelaAtual + 1);
  }

  @override
  List<Object> get props => [id, titulo, valor, iconEnum, recorrente, parcelaAtual, parcelasTotal];

  ListasModel copyWith({
    String? titulo,
    String? id,
    double? valor,
    int? iconEnum,
    bool? recorrente,
    int? parcelaAtual,
    int? parcelasTotal,
  }) {
    return ListasModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      valor: valor ?? this.valor,
      iconEnum: iconEnum ?? this.iconEnum,
      recorrente: recorrente ?? this.recorrente,
      parcelaAtual: parcelaAtual ?? this.parcelaAtual,
      parcelasTotal: parcelasTotal ?? this.parcelasTotal,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'valor': valor,
      'iconEnum': iconEnum,
      'recorrente': recorrente,
      'parcelaAtual': parcelaAtual,
      'parcelasTotal': parcelasTotal,
    };
  }

  factory ListasModel.fromMap(Map<String, dynamic> map) {
    return ListasModel(
      id: map['id'] ?? Guid.generate(),
      titulo: map['titulo'] ?? '',
      valor: map['valor'] ?? 0,
      iconEnum: map['iconEnum'] ?? 0,
      recorrente: map['recorrente'] == true,
      parcelaAtual: map['parcelaAtual'] ?? 0,
      parcelasTotal: map['parcelasTotal'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ListasModel.fromJson(String source) => ListasModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
