import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/filtro.dart';
import 'package:gastos_gerais_app_flutter/models/categoria_model.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/BackupMenu.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/ListaWidget.dart';
import 'package:gastos_gerais_app_flutter/utils/cores.dart';
import 'package:gastos_gerais_app_flutter/widgets/FiltroCategorias.dart';
import 'package:gastos_gerais_app_flutter/widgets/FormularioItem.dart';
import 'package:gastos_gerais_app_flutter/widgets/ResumoMes.dart';
import 'package:gastos_gerais_app_flutter/widgets/VersionWidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final CreateListCubit createListCubit;

  /// Categorias escolhidas no filtro ('' = sem categoria). Vazio = mostra tudo.
  Set<String> _filtro = {};

  @override
  void initState() {
    createListCubit = context.read<CreateListCubit>();
    listShared();
    super.initState();
  }

  void listShared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listConvertMesAtual = prefs.getString('mesAtual') ?? '[]';
    var listConvertProxMes = prefs.getString('proxMes') ?? '[]';
    var listConvertOutros = prefs.getString('outros') ?? '[]';
    var listConvertCategorias = prefs.getString('categorias') ?? '[]';

    createListCubit.initMesAtual(listConvertMesAtual, listConvertProxMes, listConvertOutros, listConvertCategorias);
  }

  @override
  Widget build(BuildContext context) {
    final cores = AppCores.of(context);

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          backgroundColor: cores.fundo,
          floatingActionButton: FloatingActionButton(
            onPressed: () => abrirFormulario(context, createListCubit),
            backgroundColor: cores.botao,
            foregroundColor: cores.botaoTexto,
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: BlocBuilder<CreateListCubit, CreateListState>(
                bloc: createListCubit,
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Align(alignment: Alignment.centerRight, child: BackupMenu()),
                      Icon(Icons.account_balance, color: cores.texto),
                      Text('Gastos Gerais', style: GoogleFonts.lato(fontSize: 20)),
                      const VersionWidget(),
                      const SizedBox(height: 12),
                      ResumoMes(itens: aplicarFiltro(state.mesAtual ?? [], _filtro), filtrado: _filtro.isNotEmpty),
                      const SizedBox(height: 20),
                      FiltroCategorias(
                        categorias: state.categorias ?? const <Categoria>[],
                        selecionadas: _filtro,
                        onChanged: (novo) => setState(() => _filtro = novo),
                      ),
                      ListaWidget(tipo: TipoLista.mesAtual, aoCopiar: (item) => abrirFormulario(context, createListCubit, copiaDe: item), filtro: _filtro),
                      const SizedBox(height: 20),
                      ListaWidget(tipo: TipoLista.proxMes, aoCopiar: (item) => abrirFormulario(context, createListCubit, copiaDe: item), filtro: _filtro),
                      const SizedBox(height: 20),
                      ListaWidget(tipo: TipoLista.outros, aoCopiar: (item) => abrirFormulario(context, createListCubit, copiaDe: item), filtro: _filtro),
                      const SizedBox(height: 40),
                      const Center(
                        child: Row(
                          children: [Icon(Icons.add, size: 20), Text('calcular itens de forma mais rápida')],
                        ),
                      ),
                      // espaço para o botão + não cobrir o fim da lista
                      const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
