import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';

class MesAtualWidgets extends StatefulWidget {
  const MesAtualWidgets({super.key});

  @override
  State<MesAtualWidgets> createState() => _MesAtualWidgetsState();
}

class _MesAtualWidgetsState extends State<MesAtualWidgets> {
  @override
  Widget build(BuildContext context) {
    var createListCubit = context.read<CreateListCubit>();

    return BlocBuilder<CreateListCubit, CreateListState>(
      bloc: createListCubit,
      builder: (context, state) {
        final listaMesAtual = state.mesAtual ?? [];

        var total = listaMesAtual.fold(0.0, (previousValue, element) => previousValue + element.valor);

        return Column(
          children: [
            Align(alignment: Alignment.centerLeft, child: Text('Mês Atual', style: TextStyle(fontSize: 30, color: Colors.green[400]))),
            Divider(),
            if (listaMesAtual.isEmpty) const Text('Adicione valores', style: TextStyle(fontSize: 20)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaMesAtual.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          createListCubit.deleteTaskMesAtual(listaMesAtual[index].id);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red)),
                    IconButton(
                        onPressed: () {
                          //createListCubit.deleteTaskMesAtual(listaMesAtual[index].id);
                        },
                        icon: const Icon(Icons.copy, color: Colors.blue)),
                    IconButton(
                        onPressed: () {
                          //createListCubit.editTaskMesAtual(listaMesAtual[index].id);
                        },
                        icon: const Icon(Icons.edit, color: Colors.green)),
                    Text('${listaMesAtual[index].titulo.toUpperCase()} * ${Formatervalor.formaterForReal(listaMesAtual[index].valor)}', style: TextStyle(fontSize: 25)),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'TOTAL: ',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: Formatervalor.formaterForReal(total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
