package com.example.gastos_gerais_app_flutter

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.widget.RemoteViews

/**
 * Widget da tela inicial com o saldo do Mês Atual.
 * O app (Dart) manda o texto já formatado pelo canal; aqui só se guarda e se desenha.
 */
class SaldoWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) desenhar(context, appWidgetManager, id)
    }

    companion object {
        private const val PREFS = "gastos_widget"

        /** Guarda o saldo mais recente e redesenha todos os widgets na tela. */
        fun salvarEAtualizar(context: Context, saldo: String, negativo: Boolean, oculto: Boolean) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putString("saldo", saldo)
                .putBoolean("negativo", negativo)
                .putBoolean("oculto", oculto)
                .apply()

            val gerente = AppWidgetManager.getInstance(context)
            val ids = gerente.getAppWidgetIds(ComponentName(context, SaldoWidgetProvider::class.java))
            for (id in ids) desenhar(context, gerente, id)
        }

        @Suppress("DEPRECATION")
        private fun cor(context: Context, recurso: Int): Int {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                context.getColor(recurso)
            } else {
                context.resources.getColor(recurso)
            }
        }

        private fun desenhar(context: Context, gerente: AppWidgetManager, id: Int) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val saldo = prefs.getString("saldo", null)
            val negativo = prefs.getBoolean("negativo", false)
            val oculto = prefs.getBoolean("oculto", false)

            val texto: String
            val corTexto: Int
            if (saldo == null) {
                texto = context.getString(R.string.widget_sem_dados)
                corTexto = cor(context, R.color.widget_rotulo)
            } else if (oculto) {
                texto = "R$ ••••••"
                corTexto = cor(context, R.color.widget_rotulo)
            } else {
                texto = saldo
                corTexto = cor(context, if (negativo) R.color.widget_negativo else R.color.widget_positivo)
            }

            val views = RemoteViews(context.packageName, R.layout.widget_saldo)
            views.setTextViewText(R.id.widget_saldo, texto)
            views.setTextColor(R.id.widget_saldo, corTexto)

            // tocar no widget abre o app
            val abrir = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (abrir != null) {
                val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                    (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
                views.setOnClickPendingIntent(R.id.widget_raiz, PendingIntent.getActivity(context, 0, abrir, flags))
            }

            gerente.updateAppWidget(id, views)
        }
    }
}
