package com.example.gastos_gerais_app_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // O app avisa o widget da tela inicial sempre que o saldo (ou o "olho") muda
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gastos_gerais/widget").setMethodCallHandler { chamada, resposta ->
            if (chamada.method == "atualizar") {
                val saldo = chamada.argument<String>("saldo") ?: ""
                val negativo = chamada.argument<Boolean>("negativo") ?: false
                val oculto = chamada.argument<Boolean>("oculto") ?: false
                SaldoWidgetProvider.salvarEAtualizar(applicationContext, saldo, negativo, oculto)
                resposta.success(null)
            } else {
                resposta.notImplemented()
            }
        }
    }
}
