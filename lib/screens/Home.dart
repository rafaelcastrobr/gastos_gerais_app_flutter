import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:gastos_gerais_app_flutter/functions/parcelas.dart';
import 'package:gastos_gerais_app_flutter/models/categoria_model.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/BackupMenu.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/ListaWidget.dart';
import 'package:gastos_gerais_app_flutter/utils/cores.dart';
import 'package:gastos_gerais_app_flutter/widgets/CategoriaField.dart';
import 'package:gastos_gerais_app_flutter/widgets/TextInputWidget.dart';
import 'package:gastos_gerais_app_flutter/widgets/VersionWidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final TextEditingController _controllerTitulo;
  late final TextEditingController _controllerValor;
  late final CreateListCubit createListCubit;
  final ValueNotifier valueNotifier = ValueNotifier("");
  late final FocusNode focusTitulo;
  late final FocusNode focusValor;

  bool mesAtualCheck = false;
  bool proxMesCheck = false;
  bool outrosCheck = false;
  bool recorrenteCheck = false;
  String _categoria = '';
  final TextEditingController _controllerParcelaAtual = TextEditingController();
  final TextEditingController _controllerParcelasTotal = TextEditingController();

  bool entradaCheck = false;
  bool saidaCheck = false;

  bool error = false;
  String errorText = '';

  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    _controllerTitulo = TextEditingController();
    _controllerValor = TextEditingController();
    createListCubit = context.read<CreateListCubit>();
    focusTitulo = FocusNode();
    focusValor = FocusNode();
    listShared();

    createListCubit.initControllerText(_controllerTitulo, _controllerValor);
    super.initState();
  }

  @override
  void dispose() {
    _controllerParcelaAtual.dispose();
    _controllerParcelasTotal.dispose();
    super.dispose();
  }

  bool get _recorrenteAtivo => recorrenteCheck && (mesAtualCheck || proxMesCheck);

  ParcelasLidas _parcelas() => lerParcelas(_controllerParcelaAtual.text, _controllerParcelasTotal.text);

  bool validarEntrada() {
    var valorNumerico = Formatervalor.limparString(createListCubit.state.controllerValor!.text, entradaCheck, saidaCheck);

    if (createListCubit.state.controllerTitulo!.text.isEmpty) {
      valueNotifier.value = 'Título não pode ficar vazio';
      return false;
    } else if (valorNumerico == 0) {
      valueNotifier.value = 'Valor não pode ficar vazio';
      return false;
    } else if (!entradaCheck && !saidaCheck) {
      valueNotifier.value = 'É preciso dizer se é entrada ou saída';
      return false;
    } else if (!mesAtualCheck && !proxMesCheck && !outrosCheck) {
      valueNotifier.value = 'É preciso dizer para qual lista deve ir';
      return false;
    } else if (_recorrenteAtivo && _parcelas().erro != null) {
      valueNotifier.value = _parcelas().erro!;
      return false;
    } else {
      return true;
    }
  }

  void listShared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // prefs.remove('mesAtual');
    // prefs.remove('proxMes');
    // prefs.remove('outros');
    var listConvertMesAtual = prefs.getString('mesAtual') ?? '[]';
    var listConvertProxMes = prefs.getString('proxMes') ?? '[]';
    var listConvertOutros = prefs.getString('outros') ?? '[]';
    var listConvertCategorias = prefs.getString('categorias') ?? '[]';

    createListCubit.initMesAtual(listConvertMesAtual, listConvertProxMes, listConvertOutros, listConvertCategorias);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          backgroundColor: AppCores.of(context).fundo,
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: BlocBuilder<CreateListCubit, CreateListState>(
                bloc: createListCubit,
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Align(alignment: Alignment.centerRight, child: BackupMenu()),
                      Icon(Icons.account_balance, color: AppCores.of(context).texto),
                      Text('Gastos Gerais', style: GoogleFonts.lato(fontSize: 20)),
                      const VersionWidget(),
                      Row(children: [
                        TextInputWidget(focusNode: focusTitulo, controller: state.controllerTitulo ?? _controllerTitulo, largura: 180, isValor: false, titulo: "Titulo", typeInput: TextInputType.text),
                        const SizedBox(width: 40),
                        TextInputWidget(focusNode: focusValor, controller: state.controllerValor ?? _controllerValor, largura: 100, isValor: true, titulo: "Valor", typeInput: TextInputType.number),
                      ]),
                      const SizedBox(height: 8),
                      CategoriaField(
                        valor: _categoria,
                        categorias: state.categorias ?? const <Categoria>[],
                        onChanged: (nome) => setState(() => _categoria = nome),
                        onCriar: createListCubit.criarCategoria,
                      ),
                      const SizedBox(height: 12),
                      Wrap(children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(
                            value: entradaCheck,
                            onChanged: (value) {
                              setState(() {
                                entradaCheck = !entradaCheck;
                                saidaCheck = false;
                              });
                            },
                          ),
                          Text('ENTRADA', style: GoogleFonts.lato(fontSize: 13, color: AppCores.of(context).positivo)),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(
                            value: saidaCheck,
                            onChanged: (value) {
                              setState(() {
                                saidaCheck = !saidaCheck;
                                entradaCheck = false;
                              });
                            },
                          ),
                          Text('SAÍDA', style: GoogleFonts.lato(fontSize: 13, color: AppCores.of(context).negativo)),
                        ]),
                        const Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [],
                        ),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(
                            value: mesAtualCheck,
                            onChanged: (value) {
                              setState(() {
                                mesAtualCheck = !mesAtualCheck;
                                proxMesCheck = false;
                                outrosCheck = false;
                              });
                            },
                          ),
                          Text('MÊS ATUAL', style: GoogleFonts.lato(fontSize: 13)),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(
                            value: proxMesCheck,
                            onChanged: (value) {
                              setState(() {
                                mesAtualCheck = false;
                                proxMesCheck = !proxMesCheck;
                                outrosCheck = false;
                              });
                            },
                          ),
                          Text('PROX. MÊS', style: GoogleFonts.lato(fontSize: 13)),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(
                            value: outrosCheck,
                            onChanged: (value) {
                              setState(() {
                                outrosCheck = !outrosCheck;
                                proxMesCheck = false;
                                mesAtualCheck = false;
                                recorrenteCheck = false;
                              });
                            },
                          ),
                          Text('OUTROS', style: GoogleFonts.lato()),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(
                            value: recorrenteCheck && (mesAtualCheck || proxMesCheck),
                            onChanged: (mesAtualCheck || proxMesCheck) ? (value) => setState(() => recorrenteCheck = !recorrenteCheck) : null,
                          ),
                          Text('RECORRENTE', style: GoogleFonts.lato(fontSize: 13)),
                        ]),
                      ]),
                      if (_recorrenteAtivo) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 140,
                                child: TextField(
                                  controller: _controllerParcelaAtual,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: const InputDecoration(labelText: 'Parcela atual'),
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 140,
                                child: TextField(
                                  controller: _controllerParcelasTotal,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: const InputDecoration(labelText: 'Total de parcelas'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Sem total, repete todo mês sem fim.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ],
                      if (error)
                        ValueListenableBuilder(
                          valueListenable: valueNotifier,
                          builder: (context, value, child) {
                            return Text(
                              '$value',
                              style: const TextStyle(fontSize: 14, color: Colors.red),
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppCores.of(context).botao, foregroundColor: AppCores.of(context).botaoTexto),
                          onPressed: () {
                            if (!validarEntrada()) {
                              setState(() => error = true);
                              return;
                            } else {
                              setState(() => error = false);
                            }

                            var valorNumerico = Formatervalor.limparString(state.controllerValor!.text, entradaCheck, saidaCheck);

                            Guid id = Guid.generate();
                            final parcelas = _recorrenteAtivo ? _parcelas() : const ParcelasLidas();

                            if (mesAtualCheck) {
                              createListCubit.adicionar(TipoLista.mesAtual, id.value, state.controllerTitulo!.text, valorNumerico, recorrente: recorrenteCheck, parcelaAtual: parcelas.atual, parcelasTotal: parcelas.total, categoria: _categoria);
                            }

                            if (proxMesCheck) {
                              createListCubit.adicionar(TipoLista.proxMes, id.value, state.controllerTitulo!.text, valorNumerico, recorrente: recorrenteCheck, parcelaAtual: parcelas.atual, parcelasTotal: parcelas.total, categoria: _categoria);
                            }

                            if (outrosCheck) {
                              createListCubit.adicionar(TipoLista.outros, id.value, state.controllerTitulo!.text, valorNumerico, categoria: _categoria);
                            }
                            FocusScope.of(context).requestFocus(FocusNode());
                            state.controllerTitulo!.clear();
                            state.controllerValor!.clear();
                            _controllerParcelaAtual.clear();
                            _controllerParcelasTotal.clear();
                            setState(() {
                              entradaCheck = false;
                              saidaCheck = false;
                              mesAtualCheck = false;
                              proxMesCheck = false;
                              outrosCheck = false;
                              recorrenteCheck = false;
                              _categoria = '';
                            });
                          },
                          child: const Icon(Icons.add),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListaWidget(tipo: TipoLista.mesAtual, funcOnTop: _scrollToTop),
                      const SizedBox(height: 20),
                      ListaWidget(tipo: TipoLista.proxMes, funcOnTop: _scrollToTop),
                      const SizedBox(height: 20),
                      ListaWidget(tipo: TipoLista.outros, funcOnTop: _scrollToTop),
                      const SizedBox(height: 40),
                      const Center(
                        child: Row(
                          children: [Icon(Icons.add, size: 20), Text('calcular itens de forma mais rápida')],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
