package edu.tongji.sign_language

import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager

class PhoneAudio : PhoneStateListener() {
    var path: String = ""
    private var mediaPlayer: MediaPlayer? = null

    init {
        mediaPlayer = MediaPlayer()
//        mediaPlayer?.setDataSource(this.filePath)
//        mediaPlayer?.prepare()
//        mediaPlayer?.setAudioAttributes(AudioAttributes.)
        mediaPlayer?.setAudioAttributes(getAudioAttributes())
        print("init");
    }

    private fun getAudioAttributes(): AudioAttributes {
        return AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .setLegacyStreamType(AudioManager.STREAM_MUSIC)
            .build()
    }

    fun givePathP(path: String) {
        mediaPlayer = MediaPlayer()
        mediaPlayer?.setAudioAttributes(getAudioAttributes())
        this.path = path;
        mediaPlayer?.setDataSource(this.path)
        mediaPlayer?.prepare()
        mediaPlayer?.start();
        println("set 播放路径");
        println(mediaPlayer.toString());
    }

    @Deprecated("Deprecated in Java")
    override fun onCallStateChanged(state: Int, phoneNumber: String?) {
        // 监听电话状态改变
        when (state) {

            TelephonyManager.CALL_STATE_OFFHOOK -> {
                // 电话正在响铃
//                AudioManager
            }

            TelephonyManager.CALL_STATE_RINGING -> {
//                mediaPlayer?.setDataSource(this.path)
//                mediaPlayer?.prepare()
                mediaPlayer?.start();
                // 电话已接通
                println("电话接通")
                println("语音通话")
            }

            TelephonyManager.CALL_STATE_IDLE -> {
                // 处于空闲状态
                println("电话空闲")
                mediaPlayer?.start();
            }
        }
    }
}