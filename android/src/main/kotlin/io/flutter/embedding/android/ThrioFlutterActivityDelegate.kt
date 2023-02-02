/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2022 foxsofter
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

package io.flutter.embedding.android

import android.app.Activity
import android.content.Context
import com.foxsofter.flutter_thrio.BooleanCallback
import com.foxsofter.flutter_thrio.IntCallback
import com.foxsofter.flutter_thrio.extension.getEntrypoint
import com.foxsofter.flutter_thrio.extension.getPageId
import com.foxsofter.flutter_thrio.navigator.*
import com.foxsofter.flutter_thrio.navigator.Log
import com.foxsofter.flutter_thrio.navigator.NAVIGATION_ROUTE_PAGE_ID_NONE
import com.foxsofter.flutter_thrio.navigator.PageRoutes
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

open class ThrioFlutterActivityDelegate(val activity: Activity) : ThrioFlutterActivityBase {
    var disableBackButtonPressed = false;

    override val engine: com.foxsofter.flutter_thrio.navigator.FlutterEngine?
        get() {
            val pageId = activity.intent.getPageId()
            val holder = PageRoutes.lastRouteHolder(pageId)
            return FlutterEngineFactory.getEngine(pageId, holder!!.entrypoint)
        }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineFactory.provideEngine(activity).also {
            setupBackPressedMethodChannel(it.dartExecutor.binaryMessenger)
        }
    }

    private fun setupBackPressedMethodChannel(binaryMessenger: BinaryMessenger) {
        MethodChannel(binaryMessenger, "com.foxsofter.flutter_thrio/backbutton")
            .setMethodCallHandler { call, result ->
                if (call.method == "disable") {
                    disableBackButtonPressed = true
                } else if (call.method == "enable") {
                    disableBackButtonPressed = false
                }
                result.success(true)
            }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        FlutterEngineFactory.cleanUpFlutterEngine(activity)
    }

    private var lastClickTime = System.currentTimeMillis()

    override fun onBackPressed() {
        if (disableBackButtonPressed) {
            Log.i("ThrioFlutterActiviyDelate", "onBackPressed ignored")
            return
        }


        val now = System.currentTimeMillis()
        if (now - lastClickTime <= 400) {
            return
        }
        lastClickTime = now
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val holder = PageRoutes.lastRouteHolder(pageId) ?:  throw IllegalStateException("holder must not be null")
        if (holder.routes.size <= 2) {
            Log.i("ThrioFlutterActiviyDelate", "onBackPressed maybePop");
            ThrioNavigator.maybePop()
        } else {
            engine?.engine?.navigationChannel?.popRoute()
            Log.i("ThrioFlutterActiviyDelate", "onBackPressed popRoute");
        }
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        return !FlutterEngineFactory.isMainEngine(pageId, entrypoint)
    }

    override fun onPush(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPush(arguments, result)
    }

    override fun onNotify(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onNotify(arguments, result)
    }

    override fun onMaybePop(arguments: Map<String, Any?>?, result: IntCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onMaybePop(arguments, result)
    }

    override fun onPop(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPop(arguments, result)
    }

    override fun onPopTo(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPopTo(arguments, result)
    }

    override fun onRemove(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onRemove(arguments, result)
    }

    override fun onReplace(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onReplace(arguments, result)
    }

    override fun onCanPop(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onCanPop(arguments, result)
    }
}