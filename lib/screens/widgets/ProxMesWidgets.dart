import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:google_fonts/google_fonts.dart';

class ProxMesWidget extends StatefulWidget {
  final Function funcOnTop;

  const ProxMesWidget({super.key, required this.funcOnTop});

  @override
  State<ProxMesWidget> createState() => _ProxMesWidgetState();
}

class _ProxMesWidgetState extends State<ProxMesWidget> {
  List<ListasModel> listaProxMesSoma = [];

  addSoma(ListasModel model) {
    if (listaProxMesSoma.contains(model)) return;
    listaProxMesSoma.add(model);
  }

  @override
  Widget build(BuildContext context) {
    var createListCubit = context.read<CreateListCubit>();

    return BlocBuilder<CreateListCubit, CreateListState>(
      bloc: createListCubit,
      builder: (context, state) {
        final listaProxMes = state.proxMes ?? [];

        var total = Formatervalor.formaterForReal(listaProxMes.fold(0.0, (previousValue, element) => previousValue + element.valor));
        var totalSoma = Formatervalor.formaterForReal(listaProxMesSoma.fold(0.0, (previousValue, element) => previousValue + element.valor));

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(alignment: Alignment.centerLeft, child: Text('Próx. Mês', style: GoogleFonts.lato(fontSize: 25, color: Colors.grey))),
                if (listaProxMesSoma.isNotEmpty)
                TextButton(
                    onPressed: () {
                      setState(() => listaProxMesSoma.clear());
                    },
                    child: Text('Limpar Soma', style: GoogleFonts.lato(fontSize: 15)))
              ],
            ),
            const Divider(),
            if (listaProxMes.isEmpty) Text('Adicione valores', style: GoogleFonts.lato(fontSize: 20)),
            if (listaProxMes.isNotEmpty)
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                RichText(
                  text: TextSpan(
                    text: 'TOTAL: ',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(text: total, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Formatervalor.verificaSeENegativo(total))),
                    ],
                  ),
                ),
                if (listaProxMesSoma.isNotEmpty) const SizedBox(height: 20),
                if (listaProxMesSoma.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      text: 'SOMA: ',
                      style: const TextStyle(fontSize: 16, color: Colors.orange),
                      children: <TextSpan>[
                        TextSpan(text: totalSoma, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Formatervalor.verificaSeENegativo(total))),
                      ],
                    ),
                  ),
              ]),
            const SizedBox(height: 20),
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
                          showConfirmationDeleteDialog(context, createListCubit, listaProxMes[index]);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red)),
                    IconButton(
                        onPressed: () {
                          TextEditingController contText = TextEditingController();
                          TextEditingController contValor = TextEditingController();
                          contText.text = listaProxMes[index].titulo;
                          contValor.text = listaProxMes[index].valor.toString().replaceFirst('-', '').trim();

                          createListCubit.initControllerText(contText, contValor);

                          widget.funcOnTop.call();
                        },
                        icon: const Icon(Icons.copy, color: Colors.blue)),
                    IconButton(
                        onPressed: () {
                          showConfirmationEditDialog(context, createListCubit, listaProxMes[index], widget.funcOnTop);
                        },
                        icon: const Icon(Icons.edit, color: Colors.green)),
                    Row(
                      children: [
                        Text('${listaProxMes[index].titulo.toUpperCase()} * ',
                            style: GoogleFonts.lato(fontSize: 16, color: listaProxMesSoma.contains(listaProxMes[index]) ? Colors.orange : Colors.black)),
                        Text(valor, style: GoogleFonts.lato(fontSize: 16, color: Formatervalor.verificaSeENegativo(valor))),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() => addSoma(listaProxMes[index]));
                        },
                        icon: const Icon(Icons.add))
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  static showConfirmationDeleteDialog(BuildContext context, CreateListCubit cubit, ListasModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Apagar ${model.titulo} ?'),
          content: Text('Valor ${Formatervalor.formaterForReal(model.valor)}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                cubit.deleteTaskProxMes(model.id);
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

   static showConfirmationEditDialog(BuildContext context, CreateListCubit cubit, ListasModel model, Function funcOnTop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar ${model.titulo} ?'),
          content: Text('Valor ${Formatervalor.formaterForReal(model.valor)}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                TextEditingController contText = TextEditingController();
                TextEditingController contValor = TextEditingController();
                contText.text = model.titulo;
                contValor.text = model.valor.toString().replaceFirst('-', '').trim();

                cubit.initControllerText(contText, contValor);
                cubit.deleteTaskProxMes(model.id);

                funcOnTop.call();
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
