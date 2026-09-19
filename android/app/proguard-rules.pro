# FitBook 2026 ProGuard / R8 — keep Play-safe rules for plugins

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# flutter_local_notifications (daily 9 AM food tips)
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# flutter_timezone
-keep class net.wolverinebeach.flutter_timezone.** { *; }

# Supabase / coroutines
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn io.supabase.**
-dontwarn com.supabase.**
-dontwarn kotlinx.coroutines.**

# Hive
-keep class hive.** { *; }
-keep class com.example.fitforge.** { *; }

# JSON
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

-keepclasseswithmembernames class * {
    native <methods>;
}

-dontwarn com.google.android.play.core.**

-keep class com.baseflow.** { *; }
-keep class dev.fluttercommunity.plus.** { *; }

-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
