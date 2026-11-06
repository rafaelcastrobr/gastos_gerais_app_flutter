import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/filtro.dart';
import 'package:gastos_gerais_app_flutter/functions/lembrete_backup.dart';
import 'package:gastos_gerais_app_flutter/models/categoria_model.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/BackupMenu.dart';
import 'package:gastos_gerais_app_flutter/screens/widgets/ListaWidget.dart';
import 'package:gastos_gerais_app_flutter/utils/cores.dart';
import 'package:gastos_gerais_app_flutter/widgets/FiltroCategorias.dart';
import 'package:gastos_gerais_app_flutter/widgets/FormularioItem.dart';
import 'package:gastos_gerais_app_flutter/widgets/LembreteBackupCard.dart';
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

  /// Lembrete de backup: dias desde o último, de quantos em quantos dias lembrar,
  /// e se a pessoa tocou em "Depois" nesta abertura do app.
  int _diasSemBackup = 0;
  int _intervaloLembrete = LembreteBackup.padraoDias;
  bool _lembreteDispensado = false;

  /// O "olho": esconde saldo, totais e valores dos itens. Fica salvo para a próxima abertura.
  bool _ocultar = false;

  @override
  void initState() {
    createListCubit = context.read<CreateListCubit>();
    listShared();
    _carregarLembrete();
    _carregarOcultar();
    super.initState();
  }

  Future<void> _carregarOcultar() async {
    final prefs = await SharedPreferences.getInstance();
    final ocultar = prefs.getBool('ocultarValores') ?? false;
    if (!mounted) return;
    setState(() => _ocultar = ocultar);
  }

  Future<void> _alternarOcultar() async {
    setState(() => _ocultar = !_ocultar);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ocultarValores', _ocultar);
  }

  Future<void> _carregarLembrete() async {
    final dias = await LembreteBackup.diasSemBackup();
    final intervalo = await LembreteBackup.intervalo();
    if (!mounted) return;
    setState(() {
      _diasSemBackup = dias;
      _intervaloLembrete = intervalo;
    });
  }

  bool _temDados(CreateListState state) {
    return (state.mesAtual?.isNotEmpty ?? false) || (state.proxMes?.isNotEmpty ?? false) || (state.outros?.isNotEmpty ?? false);
  }

  Future<void> listShared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var listConvertMesAtual = prefs.getString('mesAtual') ?? '[]';
    var listConvertProxMes = prefs.getString('proxMes') ?? '[]';
    var listConvertOutros = prefs.getString('outros') ?? '[]';
    var listConvertCategorias = prefs.getString('categorias') ?? '[]';

    try {
      await createListCubit.initMesAtual(listConvertMesAtual, listConvertProxMes, listConvertOutros, listConvertCategorias);
    } catch (_) {
      // dados salvos ilegíveis: abre com as listas vazias em vez de ficar carregando para sempre
      await createListCubit.initMesAtual('[]', '[]', '[]', '[]');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = AppCores.of(context);

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          backgroundColor: cores.fundo,
          // o botão só aparece depois que os dados salvos foram lidos
          floatingActionButton: BlocBuilder<CreateListCubit, CreateListState>(
            bloc: createListCubit,
            buildWhen: (anterior, atual) => (anterior.mesAtual == null) != (atual.mesAtual == null),
            builder: (context, state) {
              if (state.mesAtual == null) return const SizedBox.shrink();
              return FloatingActionButton(
                onPressed: () => abrirFormulario(context, createListCubit),
                backgroundColor: cores.botao,
                foregroundColor: cores.botaoTexto,
                child: const Icon(Icons.add),
              );
            },
          ),
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: BlocBuilder<CreateListCubit, CreateListState>(
                bloc: createListCubit,
                builder: (context, state) {
                  // enquanto os dados salvos estão sendo lidos, mostra a tela de carregamento
                  if (state.mesAtual == null) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.account_balance, size: 48, color: cores.texto),
                            const SizedBox(height: 12),
                            Text('Gastos Gerais', style: GoogleFonts.lato(fontSize: 22, color: cores.texto)),
                            const SizedBox(height: 24),
                            const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    );
                  }

                  // categorias apagadas ou renomeadas saem do filtro
                  final nomes = (state.categorias ?? const <Categoria>[]).map((c) => c.nome).toSet();
                  final filtro = _filtro.where((n) => n.isEmpty || nomes.contains(n)).toSet();

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: _ocultar ? 'Mostrar valores' : 'Esconder valores',
                            icon: Icon(_ocultar ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: _alternarOcultar,
                          ),
                          BackupMenu(aoMudarLembrete: _carregarLembrete),
                        ],
                      ),
                      Icon(Icons.account_balance, color: cores.texto),
                      Text('Gastos Gerais', style: GoogleFonts.lato(fontSize: 20)),
                      const VersionWidget(),
                      const SizedBox(height: 12),
                      if (_diasSemBackup >= _intervaloLembrete && !_lembreteDispensado && _temDados(state)) ...[
                        LembreteBackupCard(
                          dias: _diasSemBackup,
                          onSalvar: () async {
                            await BackupMenu.salvarArquivo(context);
                            await _carregarLembrete();
                          },
                          onDepois: () => setState(() => _lembreteDispensado = true),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ResumoMes(itens: aplicarFiltro(state.mesAtual ?? [], filtro), filtrado: filtro.isNotEmpty, ocultar: _ocultar),
                      const SizedBox(height: 20),
                      FiltroCategorias(
                        categorias: state.categorias ?? const <Categoria>[],
                        selecionadas: filtro,
                        onChanged: (novo) => setState(() => _filtro = novo),
                      ),
                      ListaWidget(tipo: TipoLista.mesAtual, aoCopiar: (item) => abrirFormulario(context, createListCubit, copiaDe: item), filtro: filtro, ocultar: _ocultar),
                      const SizedBox(height: 20),
                      ListaWidget(tipo: TipoLista.proxMes, aoCopiar: (item) => abrirFormulario(context, createListCubit, copiaDe: item), filtro: filtro, ocultar: _ocultar),
                      const SizedBox(height: 20),
                      ListaWidget(tipo: TipoLista.outros, aoCopiar: (item) => abrirFormulario(context, createListCubit, copiaDe: item), filtro: filtro, ocultar: _ocultar),
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
