import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';

class OutrosWidgets extends StatefulWidget {
  const OutrosWidgets({super.key});

  @override
  State<OutrosWidgets> createState() => _OutrosWidgetsState();
}

class _OutrosWidgetsState extends State<OutrosWidgets> {
  @override
  Widget build(BuildContext context) {
    var createListCubit = context.read<CreateListCubit>();

    return BlocBuilder<CreateListCubit, CreateListState>(
      bloc: createListCubit,
      builder: (context, state) {
        final listaOutros = state.outros ?? [];

        return Column(
          children: [
            const Text('Outros', style: TextStyle(fontSize: 25)),
            if (listaOutros.isEmpty) const Text('Adicione valores', style: TextStyle(fontSize: 15)),
            ListView.builder(
              shrinkWrap: true,
              itemCount: listaOutros.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Text(listaOutros[index].titulo),
                    const SizedBox(width: 10),
                    Text('${listaOutros[index].valor}'),
                    IconButton(
                        onPressed: () {
                          createListCubit.deleteTaskProxAtual(listaOutros[index].id);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red))
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
