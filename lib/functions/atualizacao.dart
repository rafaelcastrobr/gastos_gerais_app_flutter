import 'dart:convert';
import 'dart:io';

/// Uma versão nova publicada nas Releases do GitHub.
class NovaVersao {
  final int build;

  /// Endereço de download do APK.
  final String url;

  const NovaVersao({required this.build, required this.url});
}

/// Confere se existe uma versão mais nova do app que a instalada.
/// Cada build publica uma Release com a tag `build-N` e o APK anexado.
class Atualizacao {
  static const String _api = 'https://api.github.com/repos/rafaelcastrobr/gastos_gerais_app_flutter/releases/latest';

  /// Número do build que está no nome da tag ('build-15' vira 15).
  static int? buildDaTag(String tag) {
    final achou = RegExp(r'^build-(\d+)$').firstMatch(tag);
    return achou == null ? null : int.tryParse(achou.group(1)!);
  }

  /// Lê a resposta do GitHub. Devolve null se não for uma Release com APK.
  static NovaVersao? lerRelease(String corpo) {
    Object? dados;
    try {
      dados = jsonDecode(corpo);
    } on FormatException {
      return null;
    }
    if (dados is! Map) return null;

    final tag = dados['tag_name'];
    final assets = dados['assets'];
    if (tag is! String || assets is! List) return null;

    final build = buildDaTag(tag);
    if (build == null) return null;

    for (final asset in assets) {
      if (asset is! Map) continue;
      final nome = asset['name'];
      final url = asset['browser_download_url'];
      if (nome is String && nome.endsWith('.apk') && url is String) {
        return NovaVersao(build: build, url: url);
      }
    }
    return null;
  }

  /// A versão nova, ou null se o app já está atualizado ou não deu para conferir
  /// (sem internet, limite do GitHub...). Nunca lança erro: conferir não pode atrapalhar o app.
  static Future<NovaVersao?> buscar(int buildInstalado) async {
    final cliente = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final pedido = await cliente.getUrl(Uri.parse(_api));
      pedido.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      pedido.headers.set(HttpHeaders.userAgentHeader, 'gastos-gerais-app');

      final resposta = await pedido.close().timeout(const Duration(seconds: 8));
      if (resposta.statusCode != 200) return null;

      final corpo = await resposta.transform(utf8.decoder).join().timeout(const Duration(seconds: 8));
      final nova = lerRelease(corpo);
      if (nova == null || nova.build <= buildInstalado) return null;
      return nova;
    } catch (_) {
      return null;
    } finally {
      cliente.close(force: true);
    }
  }
}
