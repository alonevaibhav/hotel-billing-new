# ===============================
# 🔴 SOCKET.IO (CRITICAL)
# ===============================
-keep class io.socket.** { *; }
-keep class io.socket.client.** { *; }
-keep class io.socket.engineio.** { *; }
-keepclassmembers class io.socket.** { *; }

# ===============================
# 🔴 OKHTTP (Socket.IO dependency)
# ===============================
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# ===============================
# 🔴 WEBSOCKET
# ===============================
-keep class org.java_websocket.** { *; }

# ===============================
# 🔴 GSON (JSON parsing)
# ===============================
-keep class com.google.gson.** { *; }
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ===============================
# 🔴 FLUTTER SAFETY
# ===============================
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# ===============================
# 🔴 REMOVE WARNINGS
# ===============================
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
