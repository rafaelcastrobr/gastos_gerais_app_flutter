import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/MesAtualWidgets.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/OutrosWidgets.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/ProxMesWidgets.dart';
import 'package:gastos_gerais_app_flutter/widgets/TextInputWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controllerTitulo = TextEditingController();
  final TextEditingController _controllerValor = TextEditingController();
  late final CreateListCubit createListCubit;

  bool mesAtualCheck = false;
  bool proxMesCheck = false;
  bool outrosCheck = false;

  @override
  void initState() {
    // TODO: implement initState

    createListCubit = context.read<CreateListCubit>();

    listShared();

    super.initState();
  }

  listShared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();


var listConvertMesAtual = prefs.getString('mesAtual') ?? '[]';
var listConvertProxMes = prefs.getString('proxMes') ?? '[]';
var listConvertOutros = prefs.getString('outros') ?? '[]';

List<ListasModel> mesAtualConvert = [];
List<ListasModel> proxMesConvert = [];
List<ListasModel> outrosConvert = [];

if (listConvertMesAtual.isNotEmpty) {
  var decodedListMesAtual = jsonDecode(listConvertMesAtual);
  mesAtualConvert = decodedListMesAtual.map<ListasModel>((item) => ListasModel.fromJson(item)).toList();
}

if (listConvertProxMes.isNotEmpty) {
  var decodedListProxMes = jsonDecode(listConvertProxMes);
  proxMesConvert = decodedListProxMes.map<ListasModel>((item) => ListasModel.fromJson(item)).toList();
}

if (listConvertOutros.isNotEmpty) {
  var decodedListOutros = jsonDecode(listConvertOutros);
  outrosConvert = decodedListOutros.map<ListasModel>((item) => ListasModel.fromJson(item)).toList();
}








    // var listConvertMesAtual = prefs.getString('mesAtual') ?? '';
    // var listConvertProxMes = prefs.getString('proxMes') ?? '';
    // var listConvertOutros = prefs.getString('outros') ?? '';

    // var decodedListMesAtual = jsonDecode(listConvertMesAtual);
    // var decodedListProxMes = jsonDecode(listConvertProxMes);
    // var decodedListOutros = jsonDecode(listConvertOutros);

   
    // List<ListasModel> mesAtualConvert = decodedListMesAtual.map<ListasModel>((item) => ListasModel.fromJson(item)).toList();
    // List<ListasModel> proxMesConvert = decodedListProxMes.map<ListasModel>((item) => ListasModel.fromJson(item)).toList();
    // List<ListasModel> outrosConvert = decodedListOutros.map<ListasModel>((item) => ListasModel.fromJson(item)).toList();

    createListCubit.initMesAtual(mesAtualConvert, proxMesConvert, outrosConvert);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.account_balance, color: Colors.black),
                  TextInputWidget(controller: _controllerTitulo, titulo: "Titulo", typeInput: TextInputType.text),
                  TextInputWidget(controller: _controllerValor, titulo: "Valor", typeInput: TextInputType.number),
                  Row(children: [
                    const Text('Mês Atual'),
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
                    const Text('Prox Mês'),
                    Checkbox(
                      value: proxMesCheck,
                      onChanged: (value) {
                        setState(() {
                          proxMesCheck = !proxMesCheck;
                          mesAtualCheck = false;
                          outrosCheck = false;
                        });
                      },
                    ),
                    const Text('Outros'),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      onPressed: () {
                        Guid id = Guid.generate();
                        createListCubit.addTaskMesAtual(id.value, _controllerTitulo.text, int.parse(_controllerValor.text));
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const MesAtualWidgets(),
                  const SizedBox(height: 20),
                  const ProxMesWidget(),
                  const SizedBox(height: 20),
                  const OutrosWidgets()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
