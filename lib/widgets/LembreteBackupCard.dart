import 'package:flutter/material.dart';
import 'package:gastos_gerais_app_flutter/utils/cores.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aviso no topo da tela: faz tempo que não se salva um backup.
class LembreteBackupCard extends StatelessWidget {
  final int dias;
  final VoidCallback onSalvar;
  final VoidCallback onDepois;

  const LembreteBackupCard({super.key, required this.dias, required this.onSalvar, required this.onDepois});

  @override
  Widget build(BuildContext context) {
    final cores = AppCores.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: cores.somaFundo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cores.somaIcone, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.backup_outlined, color: cores.somaIcone),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Faz $dias dias que você não salva um backup.', style: GoogleFonts.lato(fontSize: 14, color: cores.texto)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onDepois, child: const Text('Depois')),
              const SizedBox(width: 4),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: cores.botao, foregroundColor: cores.botaoTexto),
                onPressed: onSalvar,
                child: const Text('Salvar agora'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
