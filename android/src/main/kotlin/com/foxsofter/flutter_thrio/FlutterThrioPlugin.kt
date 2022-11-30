package com.foxsofter.flutter_thrio

import androidx.annotation.NonNull
import com.foxsofter.flutter_thrio.navigator.Log
import com.foxsofter.flutter_thrio.platform_view_factory.BaseFlutterViewFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** FlutterThrioPlugin */
class FlutterThrioPlugin : FlutterPlugin , MethodCallHandler{
    private lateinit var channel: MethodChannel
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.i(TAG, "onAttachedToEngine")
        val messenger: BinaryMessenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(messenger, "custom_platform_view")
        channel.setMethodCallHandler(this)
        myFlutterViewFactorr?.let {
            it.setBinaryMessenger(messenger)
            flutterPluginBinding
                .platformViewRegistry
                .registerViewFactory(
                    "plugins.flutter.io/custom_platform_view",it
                )
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Log.i(TAG, "onDetachedFromEngine")
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val TAG = "FlutterThrioPlugin"
        private var myFlutterViewFactorr : BaseFlutterViewFactory?=null
        fun  setFlutterViewFactor(flutterViewFactor: BaseFlutterViewFactory){
            this.myFlutterViewFactorr=flutterViewFactor;
        }
    }
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }
}
