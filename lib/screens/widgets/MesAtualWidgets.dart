import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:google_fonts/google_fonts.dart';

class MesAtualWidgets extends StatefulWidget {
  const MesAtualWidgets({super.key});

  @override
  State<MesAtualWidgets> createState() => _MesAtualWidgetsState();
}

class _MesAtualWidgetsState extends State<MesAtualWidgets> {
  List<ListasModel> listaMesAtualSoma = [];

  addSoma(ListasModel model) {
    if (listaMesAtualSoma.contains(model)) return;
    listaMesAtualSoma.add(model);
  }

  @override
  Widget build(BuildContext context) {
    var createListCubit = context.read<CreateListCubit>();

    return BlocBuilder<CreateListCubit, CreateListState>(
      bloc: createListCubit,
      builder: (context, state) {
        final listaMesAtual = state.mesAtual ?? [];
        var total = Formatervalor.formaterForReal(listaMesAtual.fold(0.0, (previousValue, element) => previousValue + element.valor));
        var totalSoma = Formatervalor.formaterForReal(listaMesAtualSoma.fold(0.0, (previousValue, element) => previousValue + element.valor));

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(alignment: Alignment.centerLeft, child: Text('Mês Atual', style: GoogleFonts.lato(fontSize: 25, color: Colors.grey))),
                TextButton(
                    onPressed: () {
                      setState(() => listaMesAtualSoma.clear());
                    },
                    child: Text('Lim. Soma', style: GoogleFonts.lato(fontSize: 15)))
              ],
            ),
            const Divider(),
            if (listaMesAtual.isEmpty) Text('Adicione valores', style: GoogleFonts.lato(fontSize: 20)),
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
                          showConfirmationDialog(context, createListCubit, listaMesAtual[index]);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red)),
                    IconButton(
                        onPressed: () {
                          TextEditingController contText = TextEditingController();
                          TextEditingController contValor = TextEditingController();
                          contText.text = listaMesAtual[index].titulo;
                          contValor.text = listaMesAtual[index].valor.toString().replaceFirst('-', '').trim();

                          createListCubit.initControllerText(contText, contValor);
                        },
                        icon: const Icon(Icons.copy, color: Colors.blue)),
                    IconButton(
                        onPressed: () {
                          TextEditingController contText = TextEditingController();
                          TextEditingController contValor = TextEditingController();
                          contText.text = listaMesAtual[index].titulo;
                          contValor.text = listaMesAtual[index].valor.toString().replaceFirst('-', '').trim();

                          createListCubit.initControllerText(contText, contValor);
                          createListCubit.deleteTaskMesAtual(listaMesAtual[index].id);
                        },
                        icon: const Icon(Icons.edit, color: Colors.green)),
                    Row(
                      children: [
                        Text('${listaMesAtual[index].titulo.toUpperCase()} * ',
                            style: GoogleFonts.lato(fontSize: 16, color: listaMesAtualSoma.contains(listaMesAtual[index]) ? Colors.orange : Colors.black)),
                        Text(valor, style: GoogleFonts.lato(fontSize: 16, color: Formatervalor.verificaSeENegativo(valor))),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() => addSoma(listaMesAtual[index]));
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
            if (listaMesAtualSoma.isNotEmpty) const SizedBox(height: 20),
            if (listaMesAtualSoma.isNotEmpty)
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
                cubit.deleteTaskMesAtual(model.id);
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
