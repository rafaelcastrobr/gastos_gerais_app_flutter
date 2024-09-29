import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:google_fonts/google_fonts.dart';

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
            Align(alignment: Alignment.centerLeft, child: Text('Próx. Mês', style: GoogleFonts.lato(fontSize: 30, color: Colors.grey))),
            const Divider(),
            if (listaProxMes.isEmpty) Text('Adicione valores', style: GoogleFonts.lato(fontSize: 20)),
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
                          showConfirmationDialog(context, createListCubit, listaProxMes[index]);
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
                        Text('${listaProxMes[index].titulo.toUpperCase()} * ', style: GoogleFonts.lato(fontSize: 20)),
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
              child: Text('Sim'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: Text('Não'),
            ),
          ],
        );
      },
    );
  }
}
