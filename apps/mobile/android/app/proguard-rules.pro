## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Appwrite SDK
-keep class io.appwrite.** { *; }
-keep class io.appwrite.models.** { *; }
-keep class io.appwrite.services.** { *; }
-dontwarn io.appwrite.**

# Gson (used by Appwrite)
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Prevent obfuscation of model classes
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Google Play Core (for deferred components)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Security: Enable moderate obfuscation (aggressive settings can cause crashes)
-repackageclasses ''
-allowaccessmodification
-optimizationpasses 3

# Security: Obfuscate strings (makes reverse engineering harder)
# Disabled temporarily to prevent release crashes
# -obfuscationdictionary proguard-dict.txt
# -classobfuscationdictionary proguard-dict.txt
# -packageobfuscationdictionary proguard-dict.txt

# Security: Remove logging in production
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Security: Hide source file names and line numbers
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable

# Preserve annotations for reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Network security
-keep class javax.net.ssl.** { *; }
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**
-dontwarn javax.net.ssl.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# WebRTC
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# Nearby Connections
-keep class com.google.android.gms.nearby.** { *; }
-dontwarn com.google.android.gms.nearby.**

# OneSignal
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# Shared Preferences (for session persistence)
-keep class androidx.preference.** { *; }
-dontwarn androidx.preference.**

# Sentry
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# QR Code Scanner
-keep class com.google.zxing.** { *; }
-dontwarn com.google.zxing.**

# Prevent stripping of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all Flutter plugin registrant code
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
