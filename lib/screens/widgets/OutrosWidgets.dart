import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:google_fonts/google_fonts.dart';

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

        var total = Formatervalor.formaterForReal(listaOutros.fold(0.0, (previousValue, element) => previousValue + element.valor));

        return Column(
          children: [
            Align(alignment: Alignment.centerLeft, child: Text('Outros', style: GoogleFonts.lato(fontSize: 30, color: Colors.grey))),
            const Divider(),
            if (listaOutros.isEmpty) Text('Adicione valores', style: GoogleFonts.lato(fontSize: 20)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaOutros.length,
              itemBuilder: (context, index) {
                String valor = Formatervalor.formaterForReal(listaOutros[index].valor);

                return Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          createListCubit.deleteTaskOutros(listaOutros[index].id);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red)),
                    IconButton(
                        onPressed: () {
                          TextEditingController contText = TextEditingController();
                          TextEditingController contValor = TextEditingController();
                          contText.text = listaOutros[index].titulo;
                          contValor.text = listaOutros[index].valor.toString();

                          createListCubit.initControllerText(contText, contValor);
                        },
                        icon: const Icon(Icons.copy, color: Colors.blue)),
                    IconButton(
                        onPressed: () {
                          TextEditingController contText = TextEditingController();
                          TextEditingController contValor = TextEditingController();
                          contText.text = listaOutros[index].titulo;
                          contValor.text = listaOutros[index].valor.toString();

                          createListCubit.initControllerText(contText, contValor);
                          createListCubit.deleteTaskMesAtual(listaOutros[index].id);
                        },
                        icon: const Icon(Icons.edit, color: Colors.green)),
                    Row(
                      children: [
                        Text('${listaOutros[index].titulo.toUpperCase()} * ', style: GoogleFonts.lato(fontSize: 20)),
                        Text(valor, style: GoogleFonts.lato(fontSize: 20, color: Formatervalor.verificaSeENegativo(valor))),
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
                  TextSpan(text: total, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Formatervalor.verificaSeENegativo(total))),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
