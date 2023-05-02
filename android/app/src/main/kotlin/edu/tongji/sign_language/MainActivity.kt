package edu.tongji.sign_language

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val SOS_PHONE_CHANNEL = "SOS_PHONE";

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SOS_PHONE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "makePhoneCall") {
                val phoneNumber: String? = call.argument<String>("to")
                if (!phoneNumber.isNullOrEmpty()) {
                    val success = dialPhoneNumber(phoneNumber)
                    result.success(success)
                } else {
                    result.error("200", "参数错误", null);
                }
            } else if (call.method == "createShortCut") {
                val phoneNumber: String? = call.argument<String>("to")
                val content: String? = call.argument<String>("content")
                val title: String? = call.argument("title")
                if (!phoneNumber.isNullOrEmpty() && !content.isNullOrEmpty() && !title.isNullOrEmpty()) {
                    val success = createDialShortCut(phoneNumber, content, title)
                    result.success(success)
                } else {
                    result.error("200", "参数错误", null);
                }
            } else {
                result.notImplemented();
            }
        }

    }


    /**
     * 创建紧急拨号快捷方式
     */
    private fun createDialShortCut(phoneNumber: String, content: String, title: String): Boolean {

        val shortcutManager = getSystemService(ShortcutManager::class.java)
        if (shortcutManager!!.isRequestPinShortcutSupported) {
            // Assumes there's already a shortcut with the ID "my-shortcut".
            // The shortcut must be enabled.
            val pinShortcutInfo = ShortcutInfo.Builder(context, phoneNumber)
                .setShortLabel(title)
                .setLongLabel(title)
                .setIcon(Icon.createWithResource(this, R.drawable.my_shortcut_foreground))
                .build()

            // Create the PendingIntent object only if your app needs to be notified
            // that the user allowed the shortcut to be pinned. Note that, if the
            // pinning operation fails, your app isn't notified. We assume here that the
            // app has implemented a method called createShortcutResultIntent() that
            // returns a broadcast intent.
            val pinnedShortcutCallbackIntent = shortcutManager.createShortcutResultIntent(pinShortcutInfo)

            // Configure the intent so that your app's broadcast receiver gets
            // the callback successfully.For details, see PendingIntent.getBroadcast().
            val successCallback = PendingIntent.getBroadcast(
                context, /* request code */ 0,
                pinnedShortcutCallbackIntent, /* flags */ PendingIntent.FLAG_IMMUTABLE
            )

            shortcutManager.requestPinShortcut(
                pinShortcutInfo,
                successCallback.intentSender
            )
            return true
        } else {
            return false
        }
    }

    /**
     * 调用系统拨号界面，直接拨打电话，
     * 初始化TTS引擎
     * 初始化电话监听器
     */
    @SuppressLint("QueryPermissionsNeeded")
    private fun dialPhoneNumber(phoneNumber: String): Boolean {
        val intent = Intent(Intent.ACTION_CALL).apply {
            data = Uri.parse("tel:$phoneNumber")
        }
        return try {
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: ActivityNotFoundException) {
            false
        }
    }

}
