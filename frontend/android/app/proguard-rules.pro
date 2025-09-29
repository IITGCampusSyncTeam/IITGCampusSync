# Flutter + Razorpay custom keep rules

# Suppress warnings about missing ProGuard annotations
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Razorpay SDK rules
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# (Optional but safe) Flutter and common rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
