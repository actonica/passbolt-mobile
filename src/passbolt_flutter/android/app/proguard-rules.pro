#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

-keep class android.support.v7.widget.SearchView { *; }
-keep,includedescriptorclasses class com.actonica.** { *; }
-keep class go.** { *; }
-keep class openpgp.** { *; }

-dontwarn org.spongycastle.**
-dontwarn javax.annotation.**
-dontwarn net.bytebuddy.**
-dontwarn org.mockito.**
-dontwarn com.google.errorprone.annotations.*
-dontwarn org.slf4j.**
-dontwarn org.apache.oltu.oauth2.common.**
-dontnote net.bytebuddy.**
-dontnote com.github.mikephil.charting.**
-dontnote com.google.android.gms.**