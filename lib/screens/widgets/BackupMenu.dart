import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/backup.dart';

/// Menu com "Copiar backup" e "Restaurar backup".
/// O backup é um texto: fica na área de transferência e pode ser colado em qualquer lugar.
class BackupMenu extends StatelessWidget {
  const BackupMenu({super.key});

  Future<void> _copiar(BuildContext context) async {
    final cubit = context.read<CreateListCubit>();
    final messenger = ScaffoldMessenger.of(context);

    await Clipboard.setData(ClipboardData(text: cubit.gerarBackup()));

    messenger.showSnackBar(
      const SnackBar(content: Text('Backup copiado. Cole em um lugar seguro (notas, mensagem para você...).')),
    );
  }

  Future<void> _restaurar(BuildContext context) async {
    final cubit = context.read<CreateListCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final dados = await showDialog<BackupDados>(
      context: context,
      builder: (_) => const _ColarBackupDialog(),
    );
    if (dados == null || !context.mounted) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Substituir os dados atuais?'),
          content: Text(
            'O backup tem ${dados.total} itens '
            '(Mês Atual: ${dados.mesAtual.length}, Próx. Mês: ${dados.proxMes.length}, Outros: ${dados.outros.length}).\n\n'
            'O que está no app agora será substituído.',
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Substituir')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ],
        );
      },
    );
    if (confirmou != true) return;

    await cubit.restaurarBackup(dados);

    messenger.showSnackBar(const SnackBar(content: Text('Backup restaurado.')));
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Backup',
      onSelected: (acao) {
        if (acao == 'copiar') _copiar(context);
        if (acao == 'restaurar') _restaurar(context);
      },
      itemBuilder: (_) => const [
        PopupMenuItem<String>(value: 'copiar', child: Text('Copiar backup')),
        PopupMenuItem<String>(value: 'restaurar', child: Text('Restaurar backup')),
      ],
    );
  }
}

class _ColarBackupDialog extends StatefulWidget {
  const _ColarBackupDialog();

  @override
  State<_ColarBackupDialog> createState() => _ColarBackupDialogState();
}

class _ColarBackupDialogState extends State<_ColarBackupDialog> {
  final TextEditingController _texto = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _colar() async {
    final dados = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    setState(() {
      _texto.text = dados?.text ?? '';
      _erro = null;
    });
  }

  void _restaurar() {
    try {
      final dados = Backup.ler(_texto.text);
      Navigator.of(context).pop(dados);
    } on FormatException catch (e) {
      setState(() => _erro = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restaurar backup'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cole aqui o texto do backup.'),
            const SizedBox(height: 8),
            TextField(
              controller: _texto,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _colar,
                icon: const Icon(Icons.paste),
                label: const Text('Colar'),
              ),
            ),
            if (_erro != null) Text(_erro!, style: const TextStyle(fontSize: 14, color: Colors.red)),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        TextButton(onPressed: _restaurar, child: const Text('Restaurar')),
      ],
    );
  }
}
