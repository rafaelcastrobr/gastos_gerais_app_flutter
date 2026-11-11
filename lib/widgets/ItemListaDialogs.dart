import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:gastos_gerais_app_flutter/functions/parcelas.dart';
import 'package:gastos_gerais_app_flutter/models/categoria_model.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:gastos_gerais_app_flutter/utils/formtaterTexts.dart';
import 'package:gastos_gerais_app_flutter/widgets/CategoriaField.dart';

/// Pergunta se quer apagar o item. Depois de apagar, mostra "Desfazer".
Future<void> confirmarApagar(BuildContext context, CreateListCubit cubit, TipoLista tipo, ListasModel model, int indice) async {
  final messenger = ScaffoldMessenger.of(context);

  final confirmou = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('Apagar ${model.titulo} ?'),
        content: Text('Valor ${Formatervalor.formaterForReal(model.valor)}'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sim')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Não')),
        ],
      );
    },
  );

  if (confirmou != true) return;

  await apagarComDesfazer(messenger, cubit, tipo, model, indice);
}

/// Apaga o item e mostra o aviso com "Desfazer", que devolve o item ao mesmo lugar.
/// Usado pelo menu (depois de confirmar) e pelo deslizar da linha (sem confirmar).
Future<void> apagarComDesfazer(ScaffoldMessengerState messenger, CreateListCubit cubit, TipoLista tipo, ListasModel model, int indice) async {
  await cubit.remover(tipo, model.id);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('${model.titulo} apagado'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () => cubit.restaurar(tipo, model, indice),
        ),
      ),
    );
}

/// Abre o diálogo para editar o item no lugar (título, valor e entrada/saída).
Future<void> editarItem(BuildContext context, CreateListCubit cubit, TipoLista tipo, ListasModel model) async {
  final novo = await showDialog<ListasModel>(
    context: context,
    builder: (_) => _EditarItemDialog(model: model, mostrarRecorrente: tipo != TipoLista.outros, cubit: cubit),
  );

  if (novo == null) return;

  await cubit.editar(tipo, model.id, novo.titulo, novo.valor, recorrente: novo.recorrente, parcelaAtual: novo.parcelaAtual, parcelasTotal: novo.parcelasTotal, categoria: novo.categoria);
}

class _EditarItemDialog extends StatefulWidget {
  final ListasModel model;
  final bool mostrarRecorrente;
  final CreateListCubit cubit;

  const _EditarItemDialog({required this.model, required this.mostrarRecorrente, required this.cubit});

  @override
  State<_EditarItemDialog> createState() => _EditarItemDialogState();
}

class _EditarItemDialogState extends State<_EditarItemDialog> {
  late final TextEditingController _titulo;
  late final TextEditingController _valor;
  late final TextEditingController _parcelaAtual;
  late final TextEditingController _parcelasTotal;
  late bool _saida;
  late bool _recorrente;
  late String _categoria;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _titulo = TextEditingController(text: widget.model.titulo);
    _valor = TextEditingController(text: Formatervalor.paraCampo(widget.model.valor));
    _saida = widget.model.valor < 0;
    _recorrente = widget.model.recorrente;
    _categoria = widget.model.categoria;
    _parcelaAtual = TextEditingController(text: widget.model.temParcelas ? '${widget.model.parcelaAtual}' : '');
    _parcelasTotal = TextEditingController(text: widget.model.temParcelas ? '${widget.model.parcelasTotal}' : '');
  }

  @override
  void dispose() {
    _titulo.dispose();
    _valor.dispose();
    _parcelaAtual.dispose();
    _parcelasTotal.dispose();
    super.dispose();
  }

  void _salvar() {
    final titulo = _titulo.text.trim();

    double valor;
    try {
      valor = Formatervalor.limparString(_valor.text, !_saida, _saida);
    } catch (_) {
      setState(() => _erro = 'Valor inválido');
      return;
    }

    if (titulo.isEmpty) {
      setState(() => _erro = 'Título não pode ficar vazio');
      return;
    }
    if (valor == 0) {
      setState(() => _erro = 'Valor não pode ficar vazio');
      return;
    }

    final recorrente = widget.mostrarRecorrente && _recorrente;
    final parcelas = recorrente ? lerParcelas(_parcelaAtual.text, _parcelasTotal.text) : const ParcelasLidas();
    if (parcelas.erro != null) {
      setState(() => _erro = parcelas.erro);
      return;
    }

    Navigator.of(context).pop(widget.model.copyWith(titulo: titulo, valor: valor, recorrente: recorrente, parcelaAtual: parcelas.atual, parcelasTotal: parcelas.total, categoria: _categoria));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titulo,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            BlocBuilder<CreateListCubit, CreateListState>(
              bloc: widget.cubit,
              builder: (context, state) => CategoriaField(
                valor: _categoria,
                categorias: state.categorias ?? const <Categoria>[],
                onChanged: (nome) => setState(() => _categoria = nome),
                onCriar: widget.cubit.criarCategoria,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valor,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: const InputDecoration(labelText: 'Valor'),
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: false, label: Text('Entrada')),
                ButtonSegment<bool>(value: true, label: Text('Saída')),
              ],
              selected: {_saida},
              onSelectionChanged: (selecionado) => setState(() => _saida = selecionado.first),
            ),
            if (widget.mostrarRecorrente)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _recorrente,
                onChanged: (valor) => setState(() => _recorrente = valor ?? false),
                title: const Text('Recorrente (volta todo mês)'),
              ),
            if (widget.mostrarRecorrente && _recorrente) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _parcelaAtual,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Parcela atual'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _parcelasTotal,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Total de parcelas'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Sem total, repete todo mês sem fim.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            if (_erro != null) ...[
              const SizedBox(height: 12),
              Text(_erro!, style: const TextStyle(fontSize: 14, color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        TextButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
