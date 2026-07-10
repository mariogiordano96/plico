# Room (usato internamente da WorkManager, a sua volta usato da
# flutter_local_notifications per i promemoria/timer) istanzia le classi
# *_Impl via reflection (Class.forName + newInstance). La regola consumer
# bundled in room-runtime (-keep class * extends RoomDatabase, senza membri)
# protegge solo la classe dal rename, non costruttore/metodi: R8 li rimuove
# in release, causando "Failed to create an instance of ...Database".
-keep class androidx.room.** { *; }
-keep class androidx.work.** { *; }
-dontwarn androidx.room.paging.**

# mobile_scanner (barcode) usa CameraX + Google ML Kit. La regola consumer
# bundled nel plugin (com.google.mlkit.*, asterisco singolo) copre solo le
# classi dirette nel package, non i sottopackage come
# com.google.mlkit.vision.barcode.* dove vive il codice reale: R8 le
# rimuove/rinomina in release, causando "Impossibile avviare la fotocamera"
# (MobileScannerException / MissingPluginException) solo in release.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_common.** { *; }
-keep class androidx.camera.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn androidx.camera.**
