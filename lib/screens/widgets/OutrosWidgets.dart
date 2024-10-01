import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:google_fonts/google_fonts.dart';

class OutrosWidgets extends StatefulWidget {
  const OutrosWidgets({super.key});

  @override
  State<OutrosWidgets> createState() => _OutrosWidgetsState();
}

class _OutrosWidgetsState extends State<OutrosWidgets> {
  List<ListasModel> listaOutrosSoma = [];

  addSoma(ListasModel model) {
    if (listaOutrosSoma.contains(model)) return;
    listaOutrosSoma.add(model);
  }

  @override
  Widget build(BuildContext context) {
    var createListCubit = context.read<CreateListCubit>();

    return BlocBuilder<CreateListCubit, CreateListState>(
      bloc: createListCubit,
      builder: (context, state) {
        final listaOutros = state.outros ?? [];

        var total = Formatervalor.formaterForReal(listaOutros.fold(0.0, (previousValue, element) => previousValue + element.valor));
        var totalSoma = Formatervalor.formaterForReal(listaOutrosSoma.fold(0.0, (previousValue, element) => previousValue + element.valor));

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(alignment: Alignment.centerLeft, child: Text('Outros', style: GoogleFonts.lato(fontSize: 25, color: Colors.grey))),
                TextButton(
                    onPressed: () {
                      setState(() => listaOutrosSoma.clear());
                    },
                    child: Text('Lim. Soma', style: GoogleFonts.lato(fontSize: 15)))
              ],
            ),
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
                          showConfirmationDialog(context, createListCubit, listaOutros[index]);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red)),
                    IconButton(
                        onPressed: () {
                          TextEditingController contText = TextEditingController();
                          TextEditingController contValor = TextEditingController();
                          contText.text = listaOutros[index].titulo;
                          contValor.text = listaOutros[index].valor.toString().replaceFirst('-', '').trim();

                          createListCubit.initControllerText(contText, contValor);
                        },
                        icon: const Icon(Icons.copy, color: Colors.blue)),
                    IconButton(
                        onPressed: () {
                          TextEditingController contText = TextEditingController();
                          TextEditingController contValor = TextEditingController();
                          contText.text = listaOutros[index].titulo;
                          contValor.text = listaOutros[index].valor.toString().replaceFirst('-', '').trim();

                          createListCubit.initControllerText(contText, contValor);
                          createListCubit.deleteTaskOutros(listaOutros[index].id);
                        },
                        icon: const Icon(Icons.edit, color: Colors.green)),
                    Row(
                      children: [
                        Text('${listaOutros[index].titulo.toUpperCase()} * ',
                            style: GoogleFonts.lato(fontSize: 16, color: listaOutrosSoma.contains(listaOutros[index]) ? Colors.orange : Colors.black)),
                        Text(valor, style: GoogleFonts.lato(fontSize: 16, color: Formatervalor.verificaSeENegativo(valor))),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() => addSoma(listaOutros[index]));
                        },
                        icon: const Icon(Icons.add))
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: 'TOTAL: ',
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: total, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Formatervalor.verificaSeENegativo(total))),
                ],
              ),
            ),
            if (listaOutrosSoma.isNotEmpty) const SizedBox(height: 20),
            if (listaOutrosSoma.isNotEmpty)
              RichText(
                text: TextSpan(
                  text: 'SOMA: ',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(text: totalSoma, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Formatervalor.verificaSeENegativo(total))),
                  ],
                ),
              )
          ],
        );
      },
    );
  }

  static showConfirmationDialog(BuildContext context, CreateListCubit cubit, ListasModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Apagar ${model.titulo} ?'),
          content: Text('Valor ${Formatervalor.formaterForReal(model.valor)}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                cubit.deleteTaskOutros(model.id);
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text('Sim'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text('Não'),
            ),
          ],
        );
      },
    );
  }
}
