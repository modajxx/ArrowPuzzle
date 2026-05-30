# Flutter & plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter deferred-components / Play Core: we don't use these features,
# so silently skip references to the Play Core split-install classes.
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# flutter_local_notifications uses reflection
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# audioplayers (native callbacks)
-keep class xyz.luan.audioplayers.** { *; }

# Lifecycle / Riverpod
-keep class androidx.lifecycle.** { *; }
