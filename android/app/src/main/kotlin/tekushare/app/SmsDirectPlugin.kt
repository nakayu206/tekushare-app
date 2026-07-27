package tekushare.app

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SmsDirectPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var binding: FlutterPlugin.FlutterPluginBinding

    override fun onAttachedToEngine(b: FlutterPlugin.FlutterPluginBinding) {
        binding = b
        channel = MethodChannel(b.binaryMessenger, "tekushare/sms_direct")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(b: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "sendSms") {
            result.notImplemented()
            return
        }
        val number = call.argument<String>("number")
        val message = call.argument<String>("message")
        if (number == null || message == null) {
            result.error("INVALID_ARGS", "number と message は必須です", null)
            return
        }

        val ctx = binding.applicationContext
        if (ContextCompat.checkSelfPermission(ctx, Manifest.permission.SEND_SMS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            result.error("PERMISSION_DENIED", "SEND_SMS 権限がありません", null)
            return
        }

        try {
            @Suppress("DEPRECATION")
            val smsManager = SmsManager.getDefault()
            val parts = smsManager.divideMessage(message)
            smsManager.sendMultipartTextMessage(number, null, parts, null, null)
            result.success(null)
        } catch (e: Exception) {
            result.error("SEND_FAILED", e.message, null)
        }
    }
}
