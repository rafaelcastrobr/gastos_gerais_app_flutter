import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/MesAtualWidgets.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/OutrosWidgets.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/ProxMesWidgets.dart';
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

  bool mesAtualCheck = false;
  bool proxMesCheck = false;
  bool outrosCheck = false;

  bool entradaCheck = false;
  bool saidaCheck = false;

  bool error = false;
  String errorText = '';

  @override
  void initState() {
    // TODO: implement initState
    _controllerTitulo = TextEditingController();
    _controllerValor = TextEditingController();
    createListCubit = context.read<CreateListCubit>();

    listShared();

    createListCubit.initControllerText(_controllerTitulo, _controllerValor);
    super.initState();
  }

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

    createListCubit.initMesAtual(listConvertMesAtual, listConvertProxMes, listConvertOutros);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          backgroundColor: Colors.deepOrange[50],
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: BlocBuilder<CreateListCubit, CreateListState>(
                bloc: createListCubit,
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.account_balance, color: Colors.black),
                      Text('Gastos Gerais', style: GoogleFonts.lato(fontSize: 20)),
                      const VersionWidget(),
                      Row(children: [
                        TextInputWidget(controller: state.controllerTitulo ?? _controllerTitulo, largura: 200, isValor: false, titulo: "Titulo", typeInput: TextInputType.text),
                        const SizedBox(width: 40),
                        TextInputWidget(controller: state.controllerValor ?? _controllerValor, largura: 100, isValor: true, titulo: "Valor", typeInput: TextInputType.number),
                      ]),
                      const SizedBox(height: 20),
                      Row(children: [
                        Text('ENTRADA', style: GoogleFonts.lato()),
                        Checkbox(
                          value: entradaCheck,
                          onChanged: (value) {
                            setState(() {
                              entradaCheck = !entradaCheck;
                              saidaCheck = false;
                            });
                          },
                        ),
                        Text('SAÍDA', style: GoogleFonts.lato()),
                        Checkbox(
                          value: saidaCheck,
                          onChanged: (value) {
                            setState(() {
                              saidaCheck = !saidaCheck;
                              entradaCheck = false;
                            });
                          },
                        ),
                      ]),
                      Row(children: [
                        Text('MÊS ATUAL', style: GoogleFonts.lato()),
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
                        Text('PROX. MÊS', style: GoogleFonts.lato()),
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
                        Text('OUTROS', style: GoogleFonts.lato()),
                        Checkbox(
                          value: outrosCheck,
                          onChanged: (value) {
                            setState(() {
                              outrosCheck = !outrosCheck;
                              proxMesCheck = false;
                              mesAtualCheck = false;
                            });
                          },
                        ),
                      ]),
                      if (error)
                        ValueListenableBuilder(
                          valueListenable: valueNotifier,
                          builder: (context, value, child) {
                            return Text(
                              '$value',
                              style: const TextStyle(fontSize: 15, color: Colors.red),
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                          onPressed: () {
                            if (!validarEntrada()) {
                              setState(() => error = true);
                              return;
                            } else {
                              setState(() => error = false);
                            }

                            var valorNumerico = Formatervalor.limparString(state.controllerValor!.text, entradaCheck, saidaCheck);

                            Guid id = Guid.generate();

                            if (mesAtualCheck) {
                              createListCubit.addTaskMesAtual(id.value, state.controllerTitulo!.text, valorNumerico);
                            }

                            if (proxMesCheck) {
                              createListCubit.addTaskProxMes(id.value, state.controllerTitulo!.text, valorNumerico);
                            }

                            if (outrosCheck) {
                              createListCubit.addTaskOutros(id.value, state.controllerTitulo!.text, valorNumerico);
                            }
                            FocusScope.of(context).requestFocus(FocusNode());
                            state.controllerTitulo!.clear();
                            state.controllerValor!.clear();
                            setState(() {
                              entradaCheck = false;
                              saidaCheck = false;
                              mesAtualCheck = false;
                              proxMesCheck = false;
                              outrosCheck = false;
                            });
                          },
                          child: const Icon(Icons.add),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const MesAtualWidgets(),
                      const SizedBox(height: 20),
                      const ProxMesWidget(),
                      const SizedBox(height: 20),
                      const OutrosWidgets(),
                      const SizedBox(height: 20),
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
