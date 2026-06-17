package com.maxio96.plico

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class PlicoWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences
  ) {
    val consumed = widgetData.getInt("kcal_consumed", 0)
    val target = widgetData.getInt("kcal_target", 0)
    val progress = if (target > 0) ((consumed * 100) / target).coerceIn(0, 100) else 0

    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.plico_widget).apply {
        setTextViewText(R.id.widget_kcal_line, "$consumed / $target kcal")
        setProgressBar(R.id.widget_progress, 100, progress, false)

        val pendingIntent = HomeWidgetLaunchIntent.getActivity(
            context, MainActivity::class.java, Uri.parse("plico://add-meal"))
        setOnClickPendingIntent(R.id.widget_container, pendingIntent)
      }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
