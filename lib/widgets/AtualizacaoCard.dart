import 'package:flutter/material.dart';
import 'package:gastos_gerais_app_flutter/utils/cores.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aviso no topo da tela: existe uma versão nova do app.
class AtualizacaoCard extends StatelessWidget {
  final int numeroBuild;
  final VoidCallback onAtualizar;
  final VoidCallback onDepois;

  const AtualizacaoCard({super.key, required this.numeroBuild, required this.onAtualizar, required this.onDepois});

  @override
  Widget build(BuildContext context) {
    final cores = AppCores.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: cores.cartao,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cores.positivo, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.system_update_alt, color: cores.positivo),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Nova versão disponível (build $numeroBuild).', style: GoogleFonts.lato(fontSize: 14, color: cores.texto)),
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
                onPressed: onAtualizar,
                child: const Text('Atualizar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
