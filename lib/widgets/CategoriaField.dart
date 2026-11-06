import 'package:flutter/material.dart';
import 'package:gastos_gerais_app_flutter/models/categoria_model.dart';

const String _valorNova = '__nova__';

/// Campo para escolher a categoria, com a opção de criar uma nova na hora.
/// O valor é o nome da categoria ('' = sem categoria).
class CategoriaField extends StatelessWidget {
  final String valor;
  final List<Categoria> categorias;
  final ValueChanged<String> onChanged;
  final Future<Categoria?> Function(String nome, String icone) onCriar;

  const CategoriaField({
    super.key,
    required this.valor,
    required this.categorias,
    required this.onChanged,
    required this.onCriar,
  });

  Future<void> _escolheu(BuildContext context, String? escolhida) async {
    if (escolhida == null) return;

    if (escolhida != _valorNova) {
      onChanged(escolhida);
      return;
    }

    final nova = await pedirNovaCategoria(context);
    if (nova == null) return;

    final criada = await onCriar(nova.nome, nova.icone);
    if (criada != null) onChanged(criada.nome);
  }

  @override
  Widget build(BuildContext context) {
    final atual = categorias.any((c) => c.nome == valor) ? valor : '';

    return DropdownButtonFormField<String>(
      value: atual,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Categoria'),
      items: [
        const DropdownMenuItem<String>(value: '', child: Text('Sem categoria')),
        for (final c in categorias) DropdownMenuItem<String>(value: c.nome, child: Text(c.rotulo, overflow: TextOverflow.ellipsis)),
        const DropdownMenuItem<String>(
          value: _valorNova,
          child: Row(children: [Icon(Icons.add, size: 18), SizedBox(width: 8), Text('Nova categoria')]),
        ),
      ],
      onChanged: (v) => _escolheu(context, v),
    );
  }
}

/// Pergunta o nome e o ícone da categoria (nova, ou a que está sendo editada). Devolve null se cancelar.
Future<Categoria?> pedirNovaCategoria(BuildContext context, {Categoria? editar}) {
  return showDialog<Categoria>(
    context: context,
    builder: (_) => _NovaCategoriaDialog(inicial: editar),
  );
}

class _NovaCategoriaDialog extends StatefulWidget {
  final Categoria? inicial;

  const _NovaCategoriaDialog({this.inicial});

  @override
  State<_NovaCategoriaDialog> createState() => _NovaCategoriaDialogState();
}

class _NovaCategoriaDialogState extends State<_NovaCategoriaDialog> {
  static const List<String> _sugestoes = ['🟠', '🟣', '🔴', '🔵', '🟢', '🟡', '❤️', '💡', '🚌', '💰', '🛒', '🍔', '🏠', '🐶'];

  late final TextEditingController _nome = TextEditingController(text: widget.inicial?.nome ?? '');
  late final TextEditingController _icone = TextEditingController(text: widget.inicial?.icone ?? '');

  @override
  void dispose() {
    _nome.dispose();
    _icone.dispose();
    super.dispose();
  }

  void _criar() {
    final nome = _nome.text.trim();
    if (nome.isEmpty) return;

    // no máximo 3 emojis seguidos, para não ocupar a linha toda
    final icone = String.fromCharCodes(_icone.text.trim().runes.take(3));
    Navigator.of(context).pop(Categoria(nome: nome, icone: icone));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.inicial == null ? 'Nova categoria' : 'Editar categoria'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nome,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _icone,
              decoration: const InputDecoration(labelText: 'Ícone (emoji)'),
            ),
            const SizedBox(height: 8),
            Wrap(
              children: [
                for (final e in _sugestoes)
                  InkWell(
                    onTap: () => setState(() => _icone.text = e),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        TextButton(onPressed: _criar, child: Text(widget.inicial == null ? 'Criar' : 'Salvar')),
      ],
    );
  }
}
