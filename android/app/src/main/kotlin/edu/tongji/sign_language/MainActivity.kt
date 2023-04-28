package edu.tongji.sign_language

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.view.ActionMode
import androidx.annotation.RequiresApi
import androidx.core.content.pm.ShortcutManagerCompat.isRequestPinShortcutSupported
import com.iflytek.cloud.ErrorCode
import com.iflytek.cloud.InitListener
import com.iflytek.cloud.SpeechConstant
import com.iflytek.cloud.SpeechSynthesizer
import com.iflytek.cloud.SpeechUtility
import com.iflytek.cloud.SynthesizerListener
import com.iflytek.cloud.util.ResourceUtil
import com.iflytek.cloud.util.ResourceUtil.RESOURCE_TYPE
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.Exception


class MainActivity : FlutterActivity() {
    private val SOS_PHONE_CHANNEL = "SOS_PHONE";
    private val VOICE_CHANNEL = "VOICE_AUDIO";

    private lateinit var telephonyManager: TelephonyManager;
    private lateinit var tts: SpeechSynthesizer;
    private lateinit var phoneStateListener: MySOSPhoneStateListener


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        try {
            SpeechUtility.createUtility(context, SpeechConstant.APPID + "=8555eb27");

//            tts = SpeechSynthesizer.createSynthesizer(context, mTtsInitListener)!!
        }catch (e:Exception){
            println(e)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SOS_PHONE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "makePhoneCall") {
                val phoneNumber: String? = call.argument<String>("to")
                var content: String? = call.argument<String>("content")
                val female: Boolean? = call.argument<Boolean>("voicer")
                val repeat: Boolean? = call.argument<Boolean>("repeat")
                if (repeat == true) {
                    content = "$content。$content。$content。"
                }
                var _voicer = "xiaoyan"
                if (female == true) {
                    _voicer = "xiaofeng"
                }
                if (!phoneNumber.isNullOrEmpty() && !content.isNullOrEmpty()) {
                    val success = dialPhoneNumber(phoneNumber, content, voicer = _voicer)
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
            } else if (call.method == "None") {
                println(call.method)
            } else {
                result.notImplemented();
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VOICE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "textToSpeech") {
                val content = call.argument<String>("content")
                if (!content.isNullOrEmpty()) {
                    val res = playVoiceAudio(content);
                    result.success(res);
                } else {
                    result.error("200", "参数错误", null);
                }
            } else {
                result.notImplemented()
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
    private fun dialPhoneNumber(phoneNumber: String, content: String, voicer: String = "xiaoyan", repeat: Boolean = true): Boolean {
        initTTS();
        println("打电话")
        val intent = Intent(Intent.ACTION_CALL).apply {
            data = Uri.parse("tel:$phoneNumber")
        }
        var newContent: String = content;
        if (repeat) {
            newContent = "$content。$content。$content。";
        }
        return try {
            if (intent.resolveActivity(packageManager) != null) {
                tts.setParameter(SpeechConstant.VOICE_NAME, voicer)
                tts.setParameter(ResourceUtil.TTS_RES_PATH, getResourcePath(voicer))
                initPhoneListener(newContent);
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: ActivityNotFoundException) {
            false
        }
    }

    /**
     * 利用TTS播放音频
     */
    private fun playVoiceAudio(content: String): Boolean {
        initTTS();
        try {
            tts.startSpeaking(content, null);
            return true
        } catch (e: Exception) {
            println("TTS : 语音合成异常")
            return false
        } finally {
//            tts.stopSpeaking();
        }
    }


    /**
     * 初始化TTS引擎，设置音调，语速等
     */
    private fun initTTS(): Boolean {
        val mTtsInitListener: InitListener = InitListener { code ->
            if (code != ErrorCode.SUCCESS) {
                println("Kotlin : 讯飞语音合成初始化失败")
            } else {
                println("Kotlin Error: 讯飞语音合成初始化成功")
            }
        }
        if (!this::tts.isInitialized || SpeechSynthesizer.getSynthesizer() == null) {
            SpeechUtility.createUtility(context, SpeechConstant.APPID + "=8555eb27");

            tts = SpeechSynthesizer.createSynthesizer(context, mTtsInitListener)!!
            println("after : " + tts.toString())
        }
        tts.setParameter(SpeechConstant.ENGINE_TYPE, SpeechConstant.TYPE_LOCAL)
        return true
    }

    /**
     * 初始化电话监听器
     */
    private fun initPhoneListener(content: String): Unit {
        if (!this::telephonyManager.isInitialized) {
            telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager;
        }

        if (!this::phoneStateListener.isInitialized) {

            phoneStateListener = MySOSPhoneStateListener();
            phoneStateListener.content = content;
            telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
        } else {
            phoneStateListener.content = content;
        }
    }

    /**
     * 获取发音人资源路径
     * 讯飞语音合成
     */
    private fun getResourcePath(voicerTTS: String = "xiaoyan"): String {
        val tempBuffer = StringBuffer()
        val type = "tts"
        //合成通用资源
        tempBuffer.append(ResourceUtil.generateResourcePath(this, RESOURCE_TYPE.assets, "$type/common.jet"))
        tempBuffer.append(";")
        //发音人资源
        tempBuffer.append(ResourceUtil.generateResourcePath(this, RESOURCE_TYPE.assets, "$type/$voicerTTS.jet"))
        return tempBuffer.toString()
    }

    /**
     * 应用退出时，释放资源
     */
    override fun onDestroy() {
        super.onDestroy()
        if (this::tts.isInitialized) {
            tts.stopSpeaking()
            tts.destroy()
        }
        if (this::phoneStateListener.isInitialized) {
            telephonyManager.listen(null, PhoneStateListener.LISTEN_NONE)
        }
    }
}
