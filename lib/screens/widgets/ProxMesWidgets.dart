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

        return Column(
          children: [
            const Text('Próx. Mês', style: TextStyle(fontSize: 25)),
            if (listaProxMes.isEmpty) const Text('Adicione valores', style: TextStyle(fontSize: 15)),
            ListView.builder(
              shrinkWrap: true,
              itemCount: listaProxMes.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Text(listaProxMes[index].titulo),
                    const SizedBox(width: 10),
                    Text('${listaProxMes[index].valor}'),
                    IconButton(
                        onPressed: () {
                          createListCubit.deleteTaskProxAtual(listaProxMes[index].id);
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