import 'package:equatable/equatable.dart';

/// Categoria de um item: um nome e um ícone (emoji) que aparece na frente do título.
class Categoria extends Equatable {
  final String nome;
  final String icone;

  const Categoria({required this.nome, this.icone = ''});

  @override
  List<Object> get props => [nome, icone];

  /// "🟠 Assinaturas", ou só o nome quando não há ícone.
  String get rotulo => icone.isEmpty ? nome : '$icone $nome';

  Map<String, dynamic> toMap() => <String, dynamic>{'nome': nome, 'icone': icone};

  /// Lê uma categoria salva. Devolve null se o dado for inválido.
  static Categoria? fromMap(Object? bruto) {
    if (bruto is! Map) return null;

    final nome = bruto['nome'];
    if (nome is! String || nome.trim().isEmpty) return null;

    final icone = bruto['icone'];
    return Categoria(nome: nome, icone: icone is String ? icone : '');
  }
}
