import 'package:flutter/material.dart';
import 'package:gastos_gerais_app_flutter/functions/formaterValor.dart';
import 'package:gastos_gerais_app_flutter/functions/privacidade.dart';
import 'package:gastos_gerais_app_flutter/models/listas_model.dart';
import 'package:gastos_gerais_app_flutter/utils/cores.dart';
import 'package:google_fonts/google_fonts.dart';

/// Resumo do Mês Atual: saldo, total de entradas e total de saídas.
/// Recebe os itens já filtrados, então acompanha o filtro de categorias.
class ResumoMes extends StatelessWidget {
  final List<ListasModel> itens;
  final bool filtrado;

  /// Esconde os valores (e as cores que revelariam o sinal).
  final bool ocultar;

  const ResumoMes({super.key, required this.itens, this.filtrado = false, this.ocultar = false});

  BoxDecoration _caixa(AppCores cores) {
    return BoxDecoration(
      color: cores.cartao,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: cores.borda, width: 0.5),
    );
  }

  Widget _rotulo(String texto, AppCores cores) {
    return Text(texto, style: GoogleFonts.lato(fontSize: 12, letterSpacing: 0.8, color: cores.mudo));
  }

  Widget _cartaoPequeno(String rotulo, String valor, Color cor, AppCores cores) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: _caixa(cores),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rotulo(rotulo, cores),
          const SizedBox(height: 2),
          Text(valor, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: cor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = AppCores.of(context);

    double entradas = 0;
    double saidas = 0;
    for (final item in itens) {
      if (item.valor > 0) {
        entradas += item.valor;
      } else {
        saidas += -item.valor;
      }
    }

    // arredonda para não aparecer "-R$ 0,00" por sobra de casas decimais
    final saldo = ((entradas - saidas) * 100).round() / 100;
    final saldoTexto = Formatervalor.formaterForReal(saldo);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: _caixa(cores),
          child: Column(
            children: [
              _rotulo(filtrado ? 'SALDO · MÊS ATUAL (FILTRADO)' : 'SALDO · MÊS ATUAL', cores),
              const SizedBox(height: 4),
              Text(ocultar ? valorOculto : saldoTexto, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold, color: ocultar ? cores.texto : cores.valor(saldoTexto))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _cartaoPequeno('ENTRADAS', ocultar ? valorOculto : Formatervalor.formaterForReal(entradas), ocultar ? cores.texto : cores.positivo, cores)),
            const SizedBox(width: 10),
            Expanded(child: _cartaoPequeno('SAÍDAS', ocultar ? valorOculto : Formatervalor.formaterForReal(saidas), ocultar ? cores.texto : cores.negativo, cores)),
          ],
        ),
      ],
    );
  }
}
