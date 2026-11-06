import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/models/categoria_model.dart';
import 'package:gastos_gerais_app_flutter/utils/cores.dart';
import 'package:gastos_gerais_app_flutter/widgets/CategoriaField.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tela para criar, editar (nome e ícone) e apagar categorias.
class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  int _usos(CreateListState state, String nome) {
    return [...?state.mesAtual, ...?state.proxMes, ...?state.outros].where((e) => e.categoria == nome).length;
  }

  String _textoUsos(int n) {
    if (n == 0) return 'Nenhum item';
    if (n == 1) return '1 item';
    return '$n itens';
  }

  Future<void> _nova(BuildContext context, CreateListCubit cubit) async {
    final messenger = ScaffoldMessenger.of(context);

    final nova = await pedirNovaCategoria(context);
    if (nova == null) return;

    final jaExiste = (cubit.state.categorias ?? []).any((c) => c.nome.toLowerCase() == nova.nome.trim().toLowerCase());
    if (jaExiste) {
      messenger.showSnackBar(const SnackBar(content: Text('Já existe uma categoria com esse nome.')));
      return;
    }

    await cubit.criarCategoria(nova.nome, nova.icone);
  }

  Future<void> _editar(BuildContext context, CreateListCubit cubit, Categoria categoria) async {
    final messenger = ScaffoldMessenger.of(context);

    final nova = await pedirNovaCategoria(context, editar: categoria);
    if (nova == null) return;

    final erro = await cubit.editarCategoria(categoria.nome, nova.nome, nova.icone);
    if (erro != null) {
      messenger.showSnackBar(SnackBar(content: Text(erro)));
    }
  }

  Future<void> _apagar(BuildContext context, CreateListCubit cubit, Categoria categoria, int usos) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Apagar ${categoria.nome}?'),
          content: Text(usos == 0
              ? 'Essa categoria não está em nenhum item.'
              : usos == 1
                  ? '1 item fica sem categoria.'
                  : '$usos itens ficam sem categoria.'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Apagar')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ],
        );
      },
    );

    if (confirmou == true) {
      await cubit.apagarCategoria(categoria.nome);
    }
  }

  Widget _linha(BuildContext context, CreateListCubit cubit, CreateListState state, Categoria categoria, bool ultima) {
    final cores = AppCores.of(context);
    final usos = _usos(state, categoria.nome);

    return Material(
      color: cores.cartao,
      child: InkWell(
        onTap: () => _editar(context, cubit, categoria),
        child: Container(
          decoration: BoxDecoration(
            border: ultima ? null : Border(bottom: BorderSide(color: cores.borda, width: 0.5)),
          ),
          padding: const EdgeInsets.only(left: 14, right: 4, top: 6, bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Center(
                  child: categoria.icone.isEmpty ? Icon(Icons.label_outline, color: cores.mudo) : Text(categoria.icone, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(categoria.nome, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(fontSize: 15, color: cores.texto)),
                    Text(_textoUsos(usos), style: GoogleFonts.lato(fontSize: 12, color: cores.mudo)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                icon: Icon(Icons.edit_outlined, color: cores.textoSecundario),
                onPressed: () => _editar(context, cubit, categoria),
              ),
              IconButton(
                tooltip: 'Apagar',
                icon: Icon(Icons.delete_outline, color: cores.negativo),
                onPressed: () => _apagar(context, cubit, categoria, usos),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = AppCores.of(context);
    final cubit = context.read<CreateListCubit>();

    return Scaffold(
      backgroundColor: cores.fundo,
      appBar: AppBar(
        title: const Text('Categorias'),
        backgroundColor: cores.fundo,
        foregroundColor: cores.texto,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _nova(context, cubit),
        backgroundColor: cores.botao,
        foregroundColor: cores.botaoTexto,
        icon: const Icon(Icons.add),
        label: const Text('Nova categoria'),
      ),
      body: BlocBuilder<CreateListCubit, CreateListState>(
        bloc: cubit,
        builder: (context, state) {
          final categorias = state.categorias ?? const <Categoria>[];

          if (categorias.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nenhuma categoria ainda.\nToque em "Nova categoria" para criar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(fontSize: 16, color: cores.mudo),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 100),
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cores.borda, width: 0.5),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < categorias.length; i++) _linha(context, cubit, state, categorias[i], i == categorias.length - 1),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
