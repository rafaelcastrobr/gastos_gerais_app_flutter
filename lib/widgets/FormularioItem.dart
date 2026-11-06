import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:gastos_gerais_app_flutter/functions/parcelas.dart';
import 'package:gastos_gerais_app_flutter/models/categoria_model.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:gastos_gerais_app_flutter/utils/cores.dart';
import 'package:gastos_gerais_app_flutter/utils/formtaterTexts.dart';
import 'package:gastos_gerais_app_flutter/widgets/CategoriaField.dart';
import 'package:google_fonts/google_fonts.dart';

/// Abre o formulário de novo item numa folha que sobe por cima da tela inicial.
/// Com [copiaDe], o formulário já vem preenchido com os dados desse item.
Future<void> abrirFormulario(BuildContext context, CreateListCubit cubit, {ListasModel? copiaDe}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppCores.of(context).cartao,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FormularioItem(cubit: cubit, copiaDe: copiaDe),
        ),
      );
    },
  );
}

enum _Sinal { entrada, saida }

class FormularioItem extends StatefulWidget {
  final CreateListCubit cubit;
  final ListasModel? copiaDe;

  const FormularioItem({super.key, required this.cubit, this.copiaDe});

  @override
  State<FormularioItem> createState() => _FormularioItemState();
}

class _FormularioItemState extends State<FormularioItem> {
  late final TextEditingController _titulo;
  late final TextEditingController _valor;
  final TextEditingController _parcelaAtual = TextEditingController();
  final TextEditingController _parcelasTotal = TextEditingController();

  _Sinal? _sinal;
  TipoLista? _lista;
  bool _recorrente = false;
  String _categoria = '';
  String? _erro;

  @override
  void initState() {
    super.initState();
    final copia = widget.copiaDe;
    _titulo = TextEditingController(text: copia?.titulo ?? '');
    _valor = TextEditingController(text: copia == null ? '' : Formatervalor.paraCampo(copia.valor));
    if (copia != null) {
      _sinal = copia.valor < 0 ? _Sinal.saida : _Sinal.entrada;
      _categoria = copia.categoria;
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _valor.dispose();
    _parcelaAtual.dispose();
    _parcelasTotal.dispose();
    super.dispose();
  }

  bool get _listaPermiteRecorrente => _lista == TipoLista.mesAtual || _lista == TipoLista.proxMes;

  bool get _recorrenteAtivo => _recorrente && _listaPermiteRecorrente;

  String _nomeLista(TipoLista tipo) {
    switch (tipo) {
      case TipoLista.mesAtual:
        return 'Mês Atual';
      case TipoLista.proxMes:
        return 'Próx. Mês';
      case TipoLista.outros:
        return 'Outros';
    }
  }

  void _adicionar() {
    final titulo = _titulo.text.trim();

    double valor;
    try {
      valor = Formatervalor.limparString(_valor.text, _sinal == _Sinal.entrada, _sinal == _Sinal.saida);
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
    if (_sinal == null) {
      setState(() => _erro = 'É preciso dizer se é entrada ou saída');
      return;
    }
    final lista = _lista;
    if (lista == null) {
      setState(() => _erro = 'É preciso dizer para qual lista deve ir');
      return;
    }

    final parcelas = _recorrenteAtivo ? lerParcelas(_parcelaAtual.text, _parcelasTotal.text) : const ParcelasLidas();
    if (parcelas.erro != null) {
      setState(() => _erro = parcelas.erro);
      return;
    }

    widget.cubit.adicionar(lista, Guid.generate().value, titulo, valor, recorrente: _recorrenteAtivo, parcelaAtual: parcelas.atual, parcelasTotal: parcelas.total, categoria: _categoria);

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text('Adicionado em ${_nomeLista(lista)}: $titulo'), duration: const Duration(seconds: 3)));
  }

  @override
  Widget build(BuildContext context) {
    final cores = AppCores.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.copiaDe == null ? 'Novo item' : 'Novo item (cópia)', style: GoogleFonts.lato(fontSize: 20, color: cores.texto)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _titulo,
                autofocus: widget.copiaDe == null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(labelText: 'Título'),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 130,
              child: TextField(
                controller: _valor,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(labelText: 'Valor'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<CreateListCubit, CreateListState>(
          bloc: widget.cubit,
          builder: (context, state) => CategoriaField(
            valor: _categoria,
            categorias: state.categorias ?? const <Categoria>[],
            onChanged: (nome) => setState(() => _categoria = nome),
            onCriar: widget.cubit.criarCategoria,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<_Sinal>(
            segments: [
              ButtonSegment<_Sinal>(value: _Sinal.entrada, label: Text('Entrada', style: TextStyle(color: cores.positivo))),
              ButtonSegment<_Sinal>(value: _Sinal.saida, label: Text('Saída', style: TextStyle(color: cores.negativo))),
            ],
            selected: _sinal == null ? <_Sinal>{} : <_Sinal>{_sinal!},
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            onSelectionChanged: (escolha) => setState(() => _sinal = escolha.isEmpty ? null : escolha.first),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<TipoLista>(
            segments: const [
              ButtonSegment<TipoLista>(value: TipoLista.mesAtual, label: Text('Mês Atual')),
              ButtonSegment<TipoLista>(value: TipoLista.proxMes, label: Text('Próx. Mês')),
              ButtonSegment<TipoLista>(value: TipoLista.outros, label: Text('Outros')),
            ],
            selected: _lista == null ? <TipoLista>{} : <TipoLista>{_lista!},
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            onSelectionChanged: (escolha) => setState(() => _lista = escolha.isEmpty ? null : escolha.first),
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _recorrenteAtivo,
          onChanged: _listaPermiteRecorrente ? (valor) => setState(() => _recorrente = valor ?? false) : null,
          title: const Text('Recorrente (volta todo mês)'),
        ),
        if (_recorrenteAtivo) ...[
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
          Text('Sem total, repete todo mês sem fim.', style: TextStyle(fontSize: 12, color: cores.mudo)),
        ],
        if (_erro != null) ...[
          const SizedBox(height: 12),
          Text(_erro!, style: TextStyle(fontSize: 14, color: cores.negativo)),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cores.botao, foregroundColor: cores.botaoTexto, padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: _adicionar,
            child: const Text('Adicionar'),
          ),
        ),
      ],
    );
  }
}
