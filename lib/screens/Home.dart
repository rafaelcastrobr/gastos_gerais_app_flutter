import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/widgets/TextInputWidget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controllerTitulo = TextEditingController();
  final TextEditingController _controllerValor = TextEditingController();
  late final CreateListCubit createListCubit;

  @override
  void initState() {
    // TODO: implement initState
    createListCubit = CreateListCubit();
    super.initState();
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      onPressed: () {
                        Guid id = Guid.generate();
                        createListCubit.addTaskMesAtual(id.toString(), _controllerTitulo.text, int.parse(_controllerValor.text));
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                  BlocBuilder<CreateListCubit, CreateListState>(
                    bloc: createListCubit,
                    builder: (context, state) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.mesAtual?.length,
                        itemBuilder: (context, index) {
                          Container(
                            child: Text('${state.mesAtual![index].titulo}'),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
