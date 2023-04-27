package edu.tongji.sign_language

import android.content.Context
import android.os.Bundle
import com.iflytek.cloud.SpeechConstant
import com.iflytek.cloud.SpeechError
import com.iflytek.cloud.SpeechSynthesizer
import com.iflytek.cloud.SpeechUtility
import com.iflytek.cloud.SynthesizerListener
import com.iflytek.cloud.util.ResourceUtil

class TTSEngine private constructor() {
    companion object {
        private const val TAG = "TTSManager"
        private var mInstance: TTSEngine? = null

        @Synchronized
        fun getInstance(): TTSEngine {
            if (mInstance == null) {
                mInstance = TTSEngine()
            }
            return mInstance!!
        }
    }

    private lateinit var mSynthesizer: SpeechSynthesizer;

    private val mListener = object : SynthesizerListener {
        override fun onSpeakBegin() {
            TODO("Not yet implemented")
        }

        override fun onBufferProgress(p0: Int, p1: Int, p2: Int, p3: String?) {
            TODO("Not yet implemented")
        }

        override fun onSpeakPaused() {
            TODO("Not yet implemented")
        }

        override fun onSpeakResumed() {
            TODO("Not yet implemented")
        }

        override fun onSpeakProgress(p0: Int, p1: Int, p2: Int) {
            TODO("Not yet implemented")
        }

        override fun onCompleted(p0: SpeechError?) {
            TODO("Not yet implemented")
        }

        override fun onEvent(p0: Int, p1: Int, p2: Int, p3: Bundle?) {
            TODO("Not yet implemented")
        }
    }

    fun init(context: Context) {
        SpeechUtility.createUtility(context, SpeechConstant.APPID + "=8555eb27");
        mSynthesizer = SpeechSynthesizer.createSynthesizer(context, null)
        mSynthesizer.setParameter(ResourceUtil.TTS_RES_PATH, getResourcePath(context, "xiaoyan"))
        mSynthesizer.setParameter(SpeechConstant.VOICE_NAME, "xiaoyan")
        mSynthesizer.setParameter(SpeechConstant.SPEED, "65")
        mSynthesizer.setParameter(SpeechConstant.VOLUME, "100")
    }

    /**
     * 获取发音人资源路径
     * 讯飞语音合成
     */
    private fun getResourcePath(context: Context, voicerTTS: String = "xiaoyan"): String {
        val tempBuffer = StringBuffer()
        val type = "tts"
        //合成通用资源
        tempBuffer.append(ResourceUtil.generateResourcePath(context, ResourceUtil.RESOURCE_TYPE.assets, "$type/common.jet"))
        tempBuffer.append(";")
        //发音人资源
        tempBuffer.append(ResourceUtil.generateResourcePath(context, ResourceUtil.RESOURCE_TYPE.assets, "$type/$voicerTTS.jet"))
        return tempBuffer.toString()
    }

    fun startSpeaking(text: String) {
        // 开始语音合成
        mSynthesizer.startSpeaking(text, mListener)
    }

    fun pauseSpeaking() {
        // 暂停语音合成
        mSynthesizer.pauseSpeaking()
    }

    fun resumeSpeaking() {
        // 恢复语音合成
        mSynthesizer.resumeSpeaking()
    }

    fun stopSpeaking() {
        // 停止语音合成
        mSynthesizer.stopSpeaking()
    }

    fun destroy() {
        // 销毁语音合成引擎
        mSynthesizer.destroy()
    }
}