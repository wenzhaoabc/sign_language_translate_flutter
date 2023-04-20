package edu.tongji.sign_language

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.speech.tts.TextToSpeech
import android.telephony.PhoneStateListener
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi


class MySOSPhoneStateListener(textToSpeech: TextToSpeech) : PhoneStateListener() {

    private lateinit var textToSpeech: TextToSpeech;

    init {
        this.textToSpeech = textToSpeech
    }

    @Deprecated("Deprecated in Java")
    override fun onCallStateChanged(state: Int, phoneNumber: String?) {
        // 监听电话状态改变
        when (state) {
            TelephonyManager.CALL_STATE_OFFHOOK -> {
                // 电话已接通
                println("电话接通")
            }

            TelephonyManager.CALL_STATE_RINGING -> {
                // 电话正在响铃
                println("电话响铃")
            }

            TelephonyManager.CALL_STATE_IDLE -> {
                // 处于空闲状态
                println("电话空闲")
                println(textToSpeech.availableLanguages)
                textToSpeech.stop();
            }
        }
    }

}