package com.foxsofter.flutter_thrio.platform_view_factory

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

abstract class BaseFlutterViewFactory  : PlatformViewFactory(
    StandardMessageCodec.INSTANCE){
    protected lateinit var messenger: BinaryMessenger
    fun setBinaryMessenger(messenger: BinaryMessenger) {
        this.messenger = messenger
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return registerAndroidView(context,viewId,args)

    }
  abstract  fun registerAndroidView(context: Context, viewId: Int, args: Any?):PlatformView
}