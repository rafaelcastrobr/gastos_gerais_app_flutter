import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';

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

        var total = Formatervalor.formaterForReal(listaProxMes.fold(0.0, (previousValue, element) => previousValue + element.valor));

        return Column(
          children: [
            const Align(alignment: Alignment.centerLeft, child: Text('PRÓ. MÊS', style: TextStyle(fontSize: 30, color: Colors.grey))),
            const Divider(),
            if (listaProxMes.isEmpty) const Text('Adicione valores', style: TextStyle(fontSize: 20)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaProxMes.length,
              itemBuilder: (context, index) {
                String valor = Formatervalor.formaterForReal(listaProxMes[index].valor);

                return Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          createListCubit.deleteTaskProxMes(listaProxMes[index].id);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red)),
                    IconButton(
                        onPressed: () {
                          TextEditingController contText = TextEditingController();
                          TextEditingController contValor = TextEditingController();
                          contText.text = listaProxMes[index].titulo;
                          contValor.text = listaProxMes[index].valor.toString();

                          createListCubit.initControllerText(contText, contValor);
                        },
                        icon: const Icon(Icons.copy, color: Colors.blue)),
                    IconButton(
                        onPressed: () {
                          TextEditingController contText = TextEditingController();
                          TextEditingController contValor = TextEditingController();
                          contText.text = listaProxMes[index].titulo;
                          contValor.text = listaProxMes[index].valor.toString();

                          createListCubit.initControllerText(contText, contValor);
                          createListCubit.deleteTaskProxMes(listaProxMes[index].id);
                        },
                        icon: const Icon(Icons.edit, color: Colors.green)),
                    Row(
                      children: [
                        Text('${listaProxMes[index].titulo.toUpperCase()} * ', style: const TextStyle(fontSize: 20)),
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
