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
        var total = Formatervalor.formaterForReal(listaMesAtual.fold(0.0, (previousValue, element) => previousValue + element.valor));

        return Column(
          children: [
            const Align(alignment: Alignment.centerLeft, child: Text('Mês Atual', style: TextStyle(fontSize: 30, color: Colors.grey))),
            const Divider(),
            if (listaMesAtual.isEmpty) const Text('Adicione valores', style: TextStyle(fontSize: 20)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaMesAtual.length,
              itemBuilder: (context, index) {
                String valor = Formatervalor.formaterForReal(listaMesAtual[index].valor);
                return Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          createListCubit.deleteTaskMesAtual(listaMesAtual[index].id);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red)),
                    IconButton(
                        onPressed: () {
                          TextEditingController contText = TextEditingController();
                          TextEditingController contValor = TextEditingController();
                          contText.text = listaMesAtual[index].titulo;
                          contValor.text = listaMesAtual[index].valor.toString();

                          createListCubit.initControllerText(contText, contValor);
                        },
                        icon: const Icon(Icons.copy, color: Colors.blue)),
                    IconButton(
                        onPressed: () {
                          TextEditingController contText = TextEditingController();
                          TextEditingController contValor = TextEditingController();
                          contText.text = listaMesAtual[index].titulo;
                          contValor.text = listaMesAtual[index].valor.toString();

                          createListCubit.initControllerText(contText, contValor);
                          createListCubit.deleteTaskMesAtual(listaMesAtual[index].id);
                        },
                        icon: const Icon(Icons.edit, color: Colors.green)),
                    Row(
                      children: [
                        Text('${listaMesAtual[index].titulo.toUpperCase()} * ', style: const TextStyle(fontSize: 20)),
                        Text(valor, style: TextStyle(fontSize: 20, color: Formatervalor.verificaSeENegativo(valor))),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: 'TOTAL: ',
                style: const TextStyle(fontSize: 20, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: total, style: TextStyle(fontWeight: FontWeight.bold, color: Formatervalor.verificaSeENegativo(total))),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
