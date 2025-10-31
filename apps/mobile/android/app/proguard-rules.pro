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

# Supabase
-keep class io.supabase.** { *; }
-keepclassmembers class io.supabase.** { *; }

# Prevent obfuscation of model classes
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Google Play Core (for deferred components)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Security: Obfuscate app-specific classes
-obfuscationdictionary proguard-dictionary.txt
-classobfuscationdictionary proguard-dictionary.txt
-packageobfuscationdictionary proguard-dictionary.txt

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Optimize and shrink
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Remove debug information
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable

# Crash reporting (keep stack traces readable)
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# WebRTC
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# Nearby Connections
-keep class com.google.android.gms.nearby.** { *; }
-dontwarn com.google.android.gms.nearby.**

# Additional security measures
-repackageclasses 'o'
-allowaccessmodification

# String encryption (basic protection)
-keepclassmembers class * {
    native <methods>;
}
