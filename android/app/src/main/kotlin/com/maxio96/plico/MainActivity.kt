package com.maxio96.plico

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (non FlutterActivity): il package `health` usa
// registerForActivityResult per il popup permessi Health Connect, che
// richiede un cast Activity -> ComponentActivity possibile solo con
// FlutterFragmentActivity (vedi README del package, sezione "Android 14").
// Senza questo, requestAuthorization fallisce silenziosamente con
// "Permission launcher not found" nei log nativi.
class MainActivity : FlutterFragmentActivity()
