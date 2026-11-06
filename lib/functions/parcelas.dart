/// Resultado da leitura dos campos de parcela.
class ParcelasLidas {
  final int atual;
  final int total;
  final String? erro;

  const ParcelasLidas({this.atual = 0, this.total = 0, this.erro});
}

/// Lê os campos "parcela atual" e "total de parcelas".
/// Total vazio significa recorrente sem fim (atual = 0 e total = 0).
ParcelasLidas lerParcelas(String textoAtual, String textoTotal) {
  final totalTexto = textoTotal.trim();
  if (totalTexto.isEmpty) return const ParcelasLidas();

  final total = int.tryParse(totalTexto);
  if (total == null || total < 1) {
    return const ParcelasLidas(erro: 'Total de parcelas inválido');
  }

  final atualTexto = textoAtual.trim();
  final atual = atualTexto.isEmpty ? 1 : int.tryParse(atualTexto);
  if (atual == null || atual < 1 || atual > total) {
    return ParcelasLidas(erro: 'A parcela atual deve ficar entre 1 e $total');
  }

  return ParcelasLidas(atual: atual, total: total);
}
