part of 'create_list_cubit.dart';

@immutable
class CreateListState extends Equatable {
  final List<ListasModel>? mesAtual;
  final List<ListasModel>? proxMes;
  final List<ListasModel>? outros;
  final TextEditingController? controllerTitulo;
  final TextEditingController? controllerValor;

  const CreateListState({this.controllerTitulo, this.controllerValor, this.mesAtual, this.proxMes, this.outros});

  CreateListState copyWith({
    List<ListasModel>? mesAtual,
    List<ListasModel>? proxMes,
    List<ListasModel>? outros,
    TextEditingController? controllerTitulo,
    TextEditingController? controllerValor,
  }) {
    return CreateListState(
      mesAtual: mesAtual ?? this.mesAtual,
      outros: outros ?? this.outros,
      proxMes: proxMes ?? this.proxMes,
      controllerTitulo: controllerTitulo ?? this.controllerTitulo,
      controllerValor: controllerValor ?? this.controllerValor,
    );
  }

  Map<String, dynamic> toMap() {
    var mesAtualjson = jsonEncode(mesAtual?.map((e) => e.toJson()).toList());
    var outrosjson = jsonEncode(outros?.map((e) => e.toJson()).toList());
    var proxMesjson = jsonEncode(proxMes?.map((e) => e.toJson()).toList());
    return {
      'mesAtual': mesAtualjson,
      'outros': outrosjson,
      'proxMes': proxMesjson,
      'controllerTitulo': controllerTitulo,
      'controllerValor': controllerValor,
    };
  }

  factory CreateListState.fromMap(Map<String, dynamic> map) {
    final List<ListasModel> mesAtual = (map['mesAtual'] == null ? [] : jsonDecode(map['mesAtual'])).map((task) => ListasModel.fromJson(task)).toList();
    final List<ListasModel> proxMes = (map['proxMes'] == null ? [] : jsonDecode(map['proxMes'])).map((task) => ListasModel.fromJson(task)).toList();
    final List<ListasModel> outros = (map['outros'] == null ? [] : jsonDecode(map['outros'])).map((task) => ListasModel.fromJson(task)).toList();

    return CreateListState(
      mesAtual: mesAtual,
      outros: outros,
      proxMes: proxMes,
      controllerValor: map['controllerValor'],
      controllerTitulo: map['controllerTitulo'],
    );
  }

  @override
  List<Object?> get props => [mesAtual, proxMes, outros, controllerTitulo, controllerValor];
}

final class CreateListInitial extends CreateListState {}
