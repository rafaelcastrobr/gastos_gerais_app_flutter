import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/filtro.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:gastos_gerais_app_flutter/functions/privacidade.dart';
import 'package:gastos_gerais_app_flutter/models/categoria_model.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:gastos_gerais_app_flutter/utils/cores.dart';
import 'package:gastos_gerais_app_flutter/widgets/ItemListaDialogs.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uma das três listas do app (Mês Atual, Próx. Mês ou Outros).
class ListaWidget extends StatefulWidget {
  final TipoLista tipo;
  /// Chamado ao escolher "Copiar" no menu do item (abre o formulário já preenchido).
  final ValueChanged<ListasModel> aoCopiar;

  /// Nomes das categorias escolhidas no filtro ('' = sem categoria). Vazio = mostra tudo.
  final Set<String> filtro;

  /// Esconde os valores (e as cores que revelariam o sinal).
  final bool ocultar;

  const ListaWidget({super.key, required this.tipo, required this.aoCopiar, this.filtro = const <String>{}, this.ocultar = false});

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

  void _confirmarPassarParaMesAtual(BuildContext context, CreateListCubit cubit, bool filtroAtivo) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Passar o Próx. Mês para o Mês Atual?'),
          content: Text(filtroAtivo
              ? 'Passa todos os itens, até os escondidos pelo filtro. Os itens recorrentes continuam no Próx. Mês.'
              : 'Os itens recorrentes continuam no Próx. Mês.'),
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

  Widget _resumo(String rotulo, String valor, Color corRotulo, AppCores cores) {
    return RichText(
      text: TextSpan(
        text: '$rotulo: ',
        style: TextStyle(fontSize: 16, color: corRotulo),
        children: <TextSpan>[
          TextSpan(text: widget.ocultar ? valorOculto : valor, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: widget.ocultar ? cores.textoSecundario : cores.valor(valor))),
        ],
      ),
    );
  }

  Widget _linha(BuildContext context, CreateListCubit cubit, List<ListasModel> itens, int index, List<Categoria> categorias, List<ListasModel> todos) {
    final cores = AppCores.of(context);
    final item = itens[index];
    final valor = Formatervalor.formaterForReal(item.valor);
    final marcado = _somaIds.contains(item.id);
    final ultima = index == itens.length - 1;

    // O ícone da categoria aparece na frente do título. Sem ícone, mostra o nome embaixo.
    final categoria = categorias.where((c) => c.nome == item.categoria).firstOrNull;
    final icone = categoria?.icone ?? '';
    final nomeEmbaixo = item.categoria.isNotEmpty && icone.isEmpty;

    final linha = Material(
      color: marcado ? cores.somaFundo : (item.destaque ? cores.destaqueFundo : cores.cartao),
      child: InkWell(
        onTap: () => _alternarSoma(item.id),
        child: Container(
          decoration: BoxDecoration(
            // faixa colorida na esquerda só nos destacados (nos outros fica transparente, para alinhar)
            border: Border(
              left: BorderSide(color: item.destaque ? cores.destaque : Colors.transparent, width: 4),
              bottom: ultima ? BorderSide.none : BorderSide(color: cores.borda, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Icon(
                marcado ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                size: 20,
                color: marcado ? cores.somaIcone : cores.mudo,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (item.destaque) ...[
                          Icon(Icons.star_rounded, size: 16, color: cores.destaque),
                          const SizedBox(width: 4),
                        ],
                        if (icone.isNotEmpty) ...[
                          Text(icone, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            item.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(fontSize: 14, color: cores.texto),
                          ),
                        ),
                        if (item.temParcelas) ...[
                          const SizedBox(width: 6),
                          Text('${item.parcelaAtual}/${item.parcelasTotal}', style: GoogleFonts.lato(fontSize: 12, color: cores.mudo)),
                        ],
                        if (item.recorrente) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.repeat, size: 16, color: cores.mudo),
                        ],
                      ],
                    ),
                    if (nomeEmbaixo)
                      Text(item.categoria, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(fontSize: 12, color: cores.mudo)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(widget.ocultar ? valorOculto : valor, maxLines: 1, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w500, color: widget.ocultar ? cores.textoSecundario : cores.valor(valor))),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 20, color: cores.textoSecundario),
                tooltip: 'Ações',
                onSelected: (acao) {
                  if (acao == 'destacar') cubit.alternarDestaque(widget.tipo, item.id);
                  if (acao == 'editar') editarItem(context, cubit, widget.tipo, item);
                  if (acao == 'copiar') widget.aoCopiar(item);
                  if (acao == 'apagar') confirmarApagar(context, cubit, widget.tipo, item, todos.indexWhere((e) => e.id == item.id));
                },
                itemBuilder: (_) => [
                  PopupMenuItem<String>(
                    value: 'destacar',
                    child: Row(children: [
                      Icon(item.destaque ? Icons.star_border_rounded : Icons.star_rounded, color: Colors.amber),
                      const SizedBox(width: 12),
                      Text(item.destaque ? 'Tirar destaque' : 'Destacar'),
                    ]),
                  ),
                  const PopupMenuItem<String>(value: 'editar', child: Row(children: [Icon(Icons.edit, color: Colors.green), SizedBox(width: 12), Text('Editar')])),
                  const PopupMenuItem<String>(value: 'copiar', child: Row(children: [Icon(Icons.copy, color: Colors.blue), SizedBox(width: 12), Text('Copiar')])),
                  const PopupMenuItem<String>(value: 'apagar', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 12), Text('Apagar')])),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Deslizar para o lado apaga (a conta foi paga). Sem pergunta: o aviso tem "Desfazer".
    Widget fundoApagar(Alignment alinhamento) {
      return Container(
        color: cores.negativo,
        alignment: alinhamento,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      );
    }

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      dismissThresholds: const {DismissDirection.startToEnd: 0.5, DismissDirection.endToStart: 0.5},
      background: fundoApagar(Alignment.centerLeft),
      secondaryBackground: fundoApagar(Alignment.centerRight),
      onDismissed: (_) {
        final indice = todos.indexWhere((e) => e.id == item.id);
        apagarComDesfazer(ScaffoldMessenger.of(context), cubit, widget.tipo, item, indice);
      },
      child: linha,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateListCubit>();

    return BlocBuilder<CreateListCubit, CreateListState>(
      bloc: cubit,
      builder: (context, state) {
        final cores = AppCores.of(context);
        final todos = _itens(state);
        final filtroAtivo = widget.filtro.isNotEmpty;
        final itens = destaquesNoTopo(aplicarFiltro(todos, widget.filtro));
        final categorias = state.categorias ?? const <Categoria>[];
        final itensSoma = itens.where((e) => _somaIds.contains(e.id)).toList();

        final total = Formatervalor.formaterForReal(itens.fold(0.0, (soma, e) => soma + e.valor));
        final totalSoma = Formatervalor.formaterForReal(itensSoma.fold(0.0, (soma, e) => soma + e.valor));

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_titulo, style: GoogleFonts.lato(fontSize: 25, color: Colors.grey)),
                if (widget.tipo == TipoLista.proxMes && todos.isNotEmpty)
                  TextButton(
                    onPressed: () => _confirmarPassarParaMesAtual(context, cubit, filtroAtivo),
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
            if (todos.isEmpty) Text('Adicione valores', style: GoogleFonts.lato(fontSize: 20)),
            if (todos.isNotEmpty && itens.isEmpty) Text('Nenhum item nas categorias escolhidas', style: GoogleFonts.lato(fontSize: 16)),
            if (itens.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _resumo('TOTAL', total, cores.texto, cores),
                  if (itensSoma.isNotEmpty) _resumo('SOMA', totalSoma, Colors.orange, cores),
                ],
              ),
            const SizedBox(height: 12),
            if (itens.isNotEmpty)
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: cores.cartao,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cores.borda, width: 0.5),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itens.length,
                  itemBuilder: (context, index) => _linha(context, cubit, itens, index, categorias, todos),
                ),
              ),
          ],
        );
      },
    );
  }
}
