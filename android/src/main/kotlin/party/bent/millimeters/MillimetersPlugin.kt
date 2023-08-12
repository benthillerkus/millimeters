package party.bent.millimeters

import android.content.Context
import android.hardware.display.DisplayManager
import android.os.Build
import android.util.DisplayMetrics
import android.view.Display
import android.view.WindowManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** MillimetersPlugin */
class MillimetersPlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "millimeters")
    channel.setMethodCallHandler(this)
  }

  @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")

      "getSize" -> {
        val (width, height) = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
          val displayManager = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
          val display = displayManager.getDisplay(Display.DEFAULT_DISPLAY)
          val metrics = DisplayMetrics()
          display.getRealMetrics(metrics)

          Pair(
            (metrics.widthPixels / metrics.xdpi).toDouble() * 25.4,
            (metrics.heightPixels / metrics.ydpi).toDouble() * 25.4
          )
        } else {
          val manager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
          val metrics = DisplayMetrics()
          manager.defaultDisplay.getRealMetrics(metrics)
          Pair(
            (metrics.widthPixels / metrics.xdpi).toDouble() * 25.4,
            (metrics.heightPixels / metrics.ydpi).toDouble() * 25.4
          )
        }
        result.success(mapOf("Width" to width, "Height" to height))
      }

      "getResolution" -> {
        val manager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val (width, height) = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
          val bounds = manager.currentWindowMetrics.bounds
          Pair(bounds.width(), bounds.height())
        } else {
          val metrics = DisplayMetrics()
          manager.defaultDisplay.getRealMetrics(metrics)
          Pair(metrics.widthPixels, metrics.heightPixels)
        }
        result.success(mapOf("Width" to width, "Height" to height))
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
