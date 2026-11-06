import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:gastos_gerais_app_flutter/widgets/ItemListaDialogs.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uma das três listas do app (Mês Atual, Próx. Mês ou Outros).
class ListaWidget extends StatefulWidget {
  final TipoLista tipo;
  final Function funcOnTop;

  const ListaWidget({super.key, required this.tipo, required this.funcOnTop});

  @override
  State<ListaWidget> createState() => _ListaWidgetState();
}

class _ListaWidgetState extends State<ListaWidget> {
  /// Itens marcados para a soma temporária. Guarda só os ids, então
  /// editar ou apagar um item não deixa a soma com valor velho.
  final Set<String> _somaIds = {};

  String get _titulo {
    switch (widget.tipo) {
      case TipoLista.mesAtual:
        return 'Mês Atual';
      case TipoLista.proxMes:
        return 'Próx. Mês';
      case TipoLista.outros:
        return 'Outros';
    }
  }

  List<ListasModel> _itens(CreateListState state) {
    switch (widget.tipo) {
      case TipoLista.mesAtual:
        return state.mesAtual ?? [];
      case TipoLista.proxMes:
        return state.proxMes ?? [];
      case TipoLista.outros:
        return state.outros ?? [];
    }
  }

  void _alternarSoma(String id) {
    setState(() {
      if (!_somaIds.add(id)) _somaIds.remove(id);
    });
  }

  /// Leva título e valor do item para o formulário do topo.
  void _copiarParaFormulario(CreateListCubit cubit, ListasModel item) {
    final contTitulo = TextEditingController(text: item.titulo);
    final contValor = TextEditingController(text: Formatervalor.paraCampo(item.valor));

    cubit.initControllerText(contTitulo, contValor);
    widget.funcOnTop.call();
  }

  void _confirmarPassarParaMesAtual(BuildContext context, CreateListCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Passar o Próx. Mês para o Mês Atual?'),
          content: const Text('Os itens recorrentes continuam no Próx. Mês.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                cubit.sendMesAtual();
                Navigator.of(ctx).pop();
              },
              child: const Text('Sim'),
            ),
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Não')),
          ],
        );
      },
    );
  }

  Widget _resumo(String rotulo, String valor, Color corRotulo) {
    return RichText(
      text: TextSpan(
        text: '$rotulo: ',
        style: TextStyle(fontSize: 16, color: corRotulo),
        children: <TextSpan>[
          TextSpan(text: valor, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Formatervalor.verificaSeENegativo(valor))),
        ],
      ),
    );
  }

  Widget _linha(BuildContext context, CreateListCubit cubit, List<ListasModel> itens, int index) {
    final item = itens[index];
    final valor = Formatervalor.formaterForReal(item.valor);
    final marcado = _somaIds.contains(item.id);

    return InkWell(
      onTap: () => _alternarSoma(item.id),
      child: Container(
        decoration: BoxDecoration(
          color: marcado ? Colors.orange.shade100 : null,
          border: const Border(bottom: BorderSide(color: Colors.black12)),
        ),
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            Icon(marcado ? Icons.check_circle : Icons.radio_button_unchecked, size: 22, color: marcado ? Colors.orange : Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      item.titulo.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  if (item.recorrente) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.autorenew, size: 16, color: Colors.grey),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(valor, maxLines: 1, style: GoogleFonts.lato(fontSize: 16, color: Formatervalor.verificaSeENegativo(valor))),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Ações',
              onSelected: (acao) {
                if (acao == 'editar') editarItem(context, cubit, widget.tipo, item);
                if (acao == 'copiar') _copiarParaFormulario(cubit, item);
                if (acao == 'apagar') confirmarApagar(context, cubit, widget.tipo, item, index);
              },
              itemBuilder: (_) => const [
                PopupMenuItem<String>(value: 'editar', child: Row(children: [Icon(Icons.edit, color: Colors.green), SizedBox(width: 12), Text('Editar')])),
                PopupMenuItem<String>(value: 'copiar', child: Row(children: [Icon(Icons.copy, color: Colors.blue), SizedBox(width: 12), Text('Copiar')])),
                PopupMenuItem<String>(value: 'apagar', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 12), Text('Apagar')])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateListCubit>();

    return BlocBuilder<CreateListCubit, CreateListState>(
      bloc: cubit,
      builder: (context, state) {
        final itens = _itens(state);
        final itensSoma = itens.where((e) => _somaIds.contains(e.id)).toList();

        final total = Formatervalor.formaterForReal(itens.fold(0.0, (soma, e) => soma + e.valor));
        final totalSoma = Formatervalor.formaterForReal(itensSoma.fold(0.0, (soma, e) => soma + e.valor));

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_titulo, style: GoogleFonts.lato(fontSize: 25, color: Colors.grey)),
                if (widget.tipo == TipoLista.proxMes && itens.isNotEmpty)
                  TextButton(
                    onPressed: () => _confirmarPassarParaMesAtual(context, cubit),
                    child: const Row(
                      children: [Text('Mês Atual'), SizedBox(width: 10), Icon(Icons.send)],
                    ),
                  ),
                if (itensSoma.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(_somaIds.clear),
                    child: Text('Limpar Soma', style: GoogleFonts.lato(fontSize: 15)),
                  ),
              ],
            ),
            const Divider(),
            if (itens.isEmpty) Text('Adicione valores', style: GoogleFonts.lato(fontSize: 20)),
            if (itens.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _resumo('TOTAL', total, Colors.black),
                  if (itensSoma.isNotEmpty) _resumo('SOMA', totalSoma, Colors.orange),
                ],
              ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itens.length,
              itemBuilder: (context, index) => _linha(context, cubit, itens, index),
            ),
          ],
        );
      },
    );
  }
}
