import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';

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

        return Column(
          children: [
            const Text('Mês Atual', style: TextStyle(fontSize: 25)),
            if (listaMesAtual.isEmpty) const Text('Adicione valores', style: TextStyle(fontSize: 15)),
            ListView.builder(
              shrinkWrap: true,
              itemCount: listaMesAtual.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Text(listaMesAtual[index].titulo),
                    const SizedBox(width: 10),
                    Text('${listaMesAtual[index].valor}'),
                    IconButton(
                        onPressed: () {
                          createListCubit.deleteTaskMesAtual(listaMesAtual[index].id);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red))
                  ],
                );
              },
            ),
            Text('TOTAL: ${listaMesAtual.fold(0, (previousValue, element) => previousValue + element.valor)}')
          ],
        );
      },
    );
  }
}
