package edu.tongji.sign_language

import android.annotation.SuppressLint
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.speech.tts.TextToSpeech
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val SOS_PHONE_CHANNEL = "SOS_PHONE";
    private lateinit var telephonyManager: TelephonyManager;
    private lateinit var tts: TextToSpeech;
    private lateinit var phoneStateListener: PhoneStateListener

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SOS_PHONE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "makePhoneCall") {
                val phoneNumber: String? = call.argument<String>("to")
                val content: String? = call.argument<String>("content")

                if (!phoneNumber.isNullOrEmpty() && !content.isNullOrEmpty()) {
                    val success = dialPhoneNumber(phoneNumber, content)
                    result.success(success)
                } else {
                    result.error("200", "参数错误", null);
                }
            } else if (call.method == "None") {
                println(call.method)
            }
        }
    }

    /**
     * 调用系统拨号界面，直接拨打电话，
     * 初始化TTS引擎
     * 初始化电话监听器
     */
    @SuppressLint("QueryPermissionsNeeded")
    private fun dialPhoneNumber(phoneNumber: String, content: String): Boolean {
        val intent = Intent(Intent.ACTION_CALL).apply {
            data = Uri.parse("tel:$phoneNumber")
        }
        return try {
            if (intent.resolveActivity(packageManager) != null) {
                initTTS();
                initPhoneListener();
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
     * 初始化TTS引擎，设置音调，语速等
     */
    private fun initTTS(): Boolean {
        if (!this::tts.isInitialized) {
            tts = TextToSpeech(this, TextToSpeech.OnInitListener { status: Int ->
                if (status == TextToSpeech.SUCCESS) {
                    val result = tts.setLanguage(Locale.CHINA)
                    if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
                        // 不支持中文,设为默认语言
                        tts.language = Locale.getDefault()
                    }
                    println("kotlin : all TTS engines : " + tts.engines.toString())
                } else {
                    println("TTS引擎初始化失败")
                }
            })
        }
        return true
    }

    /**
     * 初始化电话监听器
     */
    private fun initPhoneListener(): Unit {
        if (!this::phoneStateListener.isInitialized && !this::telephonyManager.isInitialized) {
            telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            phoneStateListener = MySOSPhoneStateListener(tts);
            telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (this::tts.isInitialized) {
            tts.stop();
            tts.shutdown()
        }
        if (this::phoneStateListener.isInitialized) {
            telephonyManager.listen(null, PhoneStateListener.LISTEN_NONE)
        }
    }
}
