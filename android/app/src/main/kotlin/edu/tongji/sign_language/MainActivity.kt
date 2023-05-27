package edu.tongji.sign_language

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.media.MediaPlayer
import android.net.Uri
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val SOS_PHONE_CHANNEL = "SOS_PHONE";

    private var filePath: String = "";
    private var content: String = "";
    private var mediaPlayer: MediaPlayer? = null

    /*override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        val intentFilter = IntentFilter(TelephonyManager.ACTION_PHONE_STATE_CHANGED)
        registerReceiver(phoneStateReceiver, intentFilter)
    }*/

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SOS_PHONE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "makePhoneCall") {
                val phoneNumber: String? = call.argument<String>("to")
                val content: String? = call.argument("content");
                val filePath: String? = call.argument("path");
                if (content != null) {
                    this.content = content
                }
                if (filePath != null) {
                    this.filePath = filePath;
                }
                if (this.content.length > 1 && this.filePath.length > 1) {
                    mediaPlayer = MediaPlayer()
                    mediaPlayer?.setDataSource(this.filePath)
                    mediaPlayer?.prepare()
                }

                if (!phoneNumber.isNullOrEmpty()) {
//                    val success = dialPhoneNumber(phoneNumber)
                    var success = false;
                    if (filePath != null) {
                        success = dialPhoneNumber2(phoneNumber, filePath);
                    } else {
                        success = dialPhoneNumber(phoneNumber);
                    }
//                    val
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

    /*private val phoneStateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val telephonyManager = context?.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
        }
    }
    private val phoneStateListener = object : PhoneStateListener() {
        override fun onCallStateChanged(state: Int, phoneNumber: String?) {
            when (state) {
                TelephonyManager.CALL_STATE_IDLE -> {
                    // 电话空闲状态
                    if (content.length > 1 && filePath.length > 1) {
                        mediaPlayer?.stop()
                        mediaPlayer?.release()
                        mediaPlayer = null
                    }
                }

                TelephonyManager.CALL_STATE_RINGING -> {
                    // 电话响铃状态
                }

                TelephonyManager.CALL_STATE_OFFHOOK -> {
                    // 电话通话状态
                    if (content.length > 1 && filePath.length > 1) {
                        mediaPlayer?.start();
                    }
                }
            }
        }
    }*/


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
//                print("${this.content},${this.filePath},this.mediaPlayer");
                val phoneListener = PhoneAudio();
                phoneListener.path = "";

                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: ActivityNotFoundException) {
            false
        }
    }

    @SuppressLint("QueryPermissionsNeeded")
    private fun dialPhoneNumber2(phoneNumber: String, filePath: String): Boolean {
        val intent = Intent(Intent.ACTION_CALL).apply {
            data = Uri.parse("tel:$phoneNumber")
        }
        return try {
            if (intent.resolveActivity(packageManager) != null) {
//                print("${this.content},${this.filePath},this.mediaPlayer");
//                val phoneListener = PhoneAudio();
//                var telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager;
//                phoneListener.givePathP(filePath);
//                telephonyManager.listen(phoneListener, PhoneStateListener.LISTEN_CALL_STATE)

                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: ActivityNotFoundException) {
            false
        }
    }

    /*override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(phoneStateReceiver)
    }*/
}
