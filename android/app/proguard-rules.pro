# Room (usato internamente da WorkManager, a sua volta usato da
# flutter_local_notifications per i promemoria/timer) istanzia le classi
# *_Impl via reflection (Class.forName + newInstance). La regola consumer
# bundled in room-runtime (-keep class * extends RoomDatabase, senza membri)
# protegge solo la classe dal rename, non costruttore/metodi: R8 li rimuove
# in release, causando "Failed to create an instance of ...Database".
-keep class androidx.room.** { *; }
-keep class androidx.work.** { *; }
-dontwarn androidx.room.paging.**
