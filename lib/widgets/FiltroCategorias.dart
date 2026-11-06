import 'package:flutter/material.dart';
import 'package:gastos_gerais_app_flutter/models/categoria_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// Faixa de categorias para filtrar as listas. Nada marcado = mostra tudo.
/// O nome vazio ('') representa os itens sem categoria.
class FiltroCategorias extends StatelessWidget {
  final List<Categoria> categorias;
  final Set<String> selecionadas;
  final ValueChanged<Set<String>> onChanged;

  const FiltroCategorias({
    super.key,
    required this.categorias,
    required this.selecionadas,
    required this.onChanged,
  });

  void _alternar(String nome) {
    final Set<String> novo = {...selecionadas};
    if (!novo.add(nome)) novo.remove(nome);
    onChanged(novo);
  }

  @override
  Widget build(BuildContext context) {
    if (categorias.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filtrar por categoria', style: GoogleFonts.lato(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Todas'),
                selected: selecionadas.isEmpty,
                onSelected: (_) => onChanged(<String>{}),
              ),
              for (final c in categorias) ...[
                const SizedBox(width: 6),
                FilterChip(
                  label: Text(c.rotulo),
                  selected: selecionadas.contains(c.nome),
                  onSelected: (_) => _alternar(c.nome),
                ),
              ],
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('Sem categoria'),
                selected: selecionadas.contains(''),
                onSelected: (_) => _alternar(''),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
