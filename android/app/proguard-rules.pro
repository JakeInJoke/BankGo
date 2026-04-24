# ProGuard configuration for BankGo - Obfuscation and Code Shrinking
# Generated: 24 Apr 2026

# Keep Flutter-related code
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep our application code (optional for security)
-keep class com.bankgo.app.** { *; }

# Keep model classes that are serialized/deserialized
-keep class com.bankgo.** { *; }

# Keep BuildConfig
-keep class **.BuildConfig { *; }

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep library APIs
-dontwarn sun.misc.Unsafe
-dontwarn com.google.android.gms.**
-dontwarn com.squareup.okhttp3.**
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn java.nio.file.**
-dontwarn javax.annotation.**

# Obfuscation options
-obfuscationdictionary obfuscation_dictionary.txt
-packageobfuscationdictionary obfuscation_dictionary.txt

# Optimization passes
-optimizationpasses 5

# Verbose output
-verbose
