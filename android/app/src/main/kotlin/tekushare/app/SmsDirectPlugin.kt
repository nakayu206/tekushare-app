package tekushare.app

import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
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
        if (call.method != "sendSms") { result.notImplemented(); return }
        val number = call.argument<String>("number")
        val message = call.argument<String>("message")
        if (number == null || message == null) {
            result.error("INVALID_ARGS", "number と message は必須です", null); return
        }
        val ctx = binding.applicationContext
        if (ContextCompat.checkSelfPermission(ctx, Manifest.permission.SEND_SMS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            result.error("PERMISSION_DENIED", "SEND_SMS 権限がありません", null); return
        }
        try {
            val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                ctx.getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }
            val parts = smsManager.divideMessage(message)
            val actionName = "SMS_SENT_${System.nanoTime()}"

            val sentIntents = ArrayList(parts.map {
                PendingIntent.getBroadcast(
                    ctx, 0,
                    Intent(actionName),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                )
            })

            val completed = intArrayOf(0)
            val failed = intArrayOf(0)
            val total = parts.size

            val receiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    if (resultCode == Activity.RESULT_OK) completed[0]++
                    else failed[0]++
                    if (completed[0] + failed[0] >= total) {
                        context.unregisterReceiver(this)
                        if (failed[0] == 0) {
                            result.success(null)
                        } else {
                            result.error(
                                "SEND_FAILED",
                                "${failed[0]}/${total}件の送信に失敗しました",
                                null,
                            )
                        }
                    }
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                ctx.registerReceiver(receiver, IntentFilter(actionName), Context.RECEIVER_NOT_EXPORTED)
            } else {
                @Suppress("UnspecifiedRegisterReceiverFlag")
                ctx.registerReceiver(receiver, IntentFilter(actionName))
            }

            smsManager.sendMultipartTextMessage(number, null, parts, sentIntents, null)
        } catch (e: Exception) {
            result.error("SEND_FAILED", e.message, null)
        }
    }
}
