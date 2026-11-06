import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastos_gerais_app_flutter/bloc/create_list_cubit/create_list_cubit.dart';
import 'package:gastos_gerais_app_flutter/functions/backup.dart';
import 'package:gastos_gerais_app_flutter/functions/lembrete_backup.dart';
import 'package:gastos_gerais_app_flutter/screens/CategoriasScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Menu de backup. O backup é um texto JSON, que pode ir de quatro jeitos:
/// salvo como arquivo pelo menu de compartilhar do Android (Drive, WhatsApp...),
/// copiado para a área de transferência, ou lido de volta de um arquivo ou do texto colado.
class BackupMenu extends StatelessWidget {
  /// Chamado depois de mudar o intervalo do lembrete, para a tela reavaliar o aviso.
  final VoidCallback? aoMudarLembrete;

  const BackupMenu({super.key, this.aoMudarLembrete});

  Future<void> _copiar(BuildContext context) async {
    final cubit = context.read<CreateListCubit>();
    final messenger = ScaffoldMessenger.of(context);

    await Clipboard.setData(ClipboardData(text: cubit.gerarBackup()));
    await LembreteBackup.marcarFeito();

    messenger.showSnackBar(
      const SnackBar(content: Text('Backup copiado. Cole em um lugar seguro (notas, mensagem para você...).')),
    );
  }

  /// Gera o arquivo do backup e abre o menu de compartilhar do Android.
  /// Lá é só escolher o Drive e salvar.
  static Future<void> salvarArquivo(BuildContext context) async {
    final cubit = context.read<CreateListCubit>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final agora = DateTime.now();
      String dois(int n) => n.toString().padLeft(2, '0');
      final nome = 'gastos-gerais-backup-${agora.year}-${dois(agora.month)}-${dois(agora.day)}.json';

      final pasta = await getTemporaryDirectory();
      final arquivo = File('${pasta.path}/$nome');
      await arquivo.writeAsString(cubit.gerarBackup());

      final resultado = await Share.shareXFiles([XFile(arquivo.path, mimeType: 'application/json')], subject: 'Backup Gastos Gerais');

      // se a pessoa fechou o menu de compartilhar sem escolher nada, não conta como backup feito
      if (resultado.status.name != 'dismissed') await LembreteBackup.marcarFeito();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Não foi possível gerar o arquivo de backup.')));
    }
  }

  /// Abre o seletor de arquivos do celular (que mostra o Drive) e restaura o backup escolhido.
  Future<void> _ajustarLembrete(BuildContext context) async {
    final atual = await LembreteBackup.intervalo();
    if (!context.mounted) return;

    final novo = await showDialog<int>(
      context: context,
      builder: (_) => _LembreteDialog(dias: atual),
    );
    if (novo == null) return;

    await LembreteBackup.definirIntervalo(novo);
    aoMudarLembrete?.call();
  }

  Future<void> _restaurarDeArquivo(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    FilePickerResult? escolha;
    try {
      escolha = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Não foi possível abrir o seletor de arquivos.')));
      return;
    }
    if (escolha == null || escolha.files.isEmpty) return;

    final bytes = escolha.files.single.bytes;
    if (bytes == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Não consegui ler esse arquivo.')));
      return;
    }

    String texto;
    try {
      texto = utf8.decode(bytes);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Esse arquivo não é um backup do app.')));
      return;
    }

    BackupDados dados;
    try {
      dados = Backup.ler(texto);
    } on FormatException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (!context.mounted) return;

    await _confirmarERestaurar(context, dados);
  }

  Future<void> _restaurarColando(BuildContext context) async {
    final dados = await showDialog<BackupDados>(
      context: context,
      builder: (_) => const _ColarBackupDialog(),
    );
    if (dados == null || !context.mounted) return;

    await _confirmarERestaurar(context, dados);
  }

  Future<void> _confirmarERestaurar(BuildContext context, BackupDados dados) async {
    final cubit = context.read<CreateListCubit>();
    final messenger = ScaffoldMessenger.of(context);

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
      tooltip: 'Mais opções',
      onSelected: (acao) {
        if (acao == 'categorias') Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CategoriasScreen()));
        if (acao == 'salvar') salvarArquivo(context);
        if (acao == 'copiar') _copiar(context);
        if (acao == 'arquivo') _restaurarDeArquivo(context);
        if (acao == 'colar') _restaurarColando(context);
        if (acao == 'lembrete') _ajustarLembrete(context);
      },
      itemBuilder: (_) => const [
        PopupMenuItem<String>(value: 'categorias', child: Text('Categorias')),
        PopupMenuDivider(),
        PopupMenuItem<String>(value: 'salvar', child: Text('Salvar backup (Drive...)')),
        PopupMenuItem<String>(value: 'copiar', child: Text('Copiar backup (texto)')),
        PopupMenuItem<String>(value: 'arquivo', child: Text('Restaurar de um arquivo')),
        PopupMenuItem<String>(value: 'colar', child: Text('Restaurar colando o texto')),
        PopupMenuItem<String>(value: 'lembrete', child: Text('Lembrete de backup')),
      ],
    );
  }
}

/// Escolhe de quantos em quantos dias o app lembra de salvar um backup (7 a 15).
class _LembreteDialog extends StatefulWidget {
  final int dias;

  const _LembreteDialog({required this.dias});

  @override
  State<_LembreteDialog> createState() => _LembreteDialogState();
}

class _LembreteDialogState extends State<_LembreteDialog> {
  late int _dias = widget.dias;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lembrete de backup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lembrar a cada $_dias dias'),
          Slider(
            value: _dias.toDouble(),
            min: LembreteBackup.minDias.toDouble(),
            max: LembreteBackup.maxDias.toDouble(),
            divisions: LembreteBackup.maxDias - LembreteBackup.minDias,
            label: '$_dias dias',
            onChanged: (valor) => setState(() => _dias = valor.round()),
          ),
          const Text('Você escolhe de 7 a 15 dias.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.of(context).pop(_dias), child: const Text('Salvar')),
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
