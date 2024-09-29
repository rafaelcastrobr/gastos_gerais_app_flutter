import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';

class ProxMesWidget extends StatefulWidget {
  const ProxMesWidget({super.key});

  @override
  State<ProxMesWidget> createState() => _ProxMesWidgetState();
}

class _ProxMesWidgetState extends State<ProxMesWidget> {
  @override
  Widget build(BuildContext context) {
    var createListCubit = context.read<CreateListCubit>();

    return BlocBuilder<CreateListCubit, CreateListState>(
      bloc: createListCubit,
      builder: (context, state) {
        final listaProxMes = state.proxMes ?? [];

        var total = listaProxMes.fold(0.0, (previousValue, element) => previousValue + element.valor);

        return Column(
          children: [
            Align(alignment: Alignment.centerLeft, child: Text('Próx Mês', style: TextStyle(fontSize: 30, color: Colors.green[400]))),
            Divider(),
            if (listaProxMes.isEmpty) const Text('Adicione valores', style: TextStyle(fontSize: 15)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaProxMes.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          createListCubit.deleteTaskProxMes(listaProxMes[index].id);
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
                    Text('${listaProxMes[index].titulo.toUpperCase()} * ${listaProxMes[index].valor}', style: TextStyle(fontSize: 25)),
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
                  TextSpan(
                      text: '$total',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
