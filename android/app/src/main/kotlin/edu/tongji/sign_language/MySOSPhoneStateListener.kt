package edu.tongji.sign_language

import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import com.iflytek.cloud.SpeechSynthesizer


class MySOSPhoneStateListener : PhoneStateListener() {

    private var textToSpeech: SpeechSynthesizer = SpeechSynthesizer.getSynthesizer();
    var content: String = "";


    @Deprecated("Deprecated in Java")
    override fun onCallStateChanged(state: Int, phoneNumber: String?) {
        // 监听电话状态改变
        when (state) {

            TelephonyManager.CALL_STATE_OFFHOOK -> {
                // 电话正在响铃
                println("电话响铃")
            }

            TelephonyManager.CALL_STATE_RINGING -> {

                // 电话已接通
                println("电话接通")

                textToSpeech.startSpeaking(content, null);

                println("语音通话")
            }

            TelephonyManager.CALL_STATE_IDLE -> {
                // 处于空闲状态
                println("电话空闲")
                println(textToSpeech.isSpeaking)
                textToSpeech.stopSpeaking();
            }
        }
    }

}