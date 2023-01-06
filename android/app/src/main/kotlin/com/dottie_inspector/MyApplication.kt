package com.dottie_inspector

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry

class MyApplication : FlutterApplication(){
//    override fun registerWith(registry: PluginRegistry) {
////         The line below this would be uncommented
////         GeneratedPluginRegistrant.registerWith(registry)
//        WorkmanagerPlugin.registerWith(registry.registrarFor("be.tramckrijte.workmanager.WorkmanagerPlugin"));
//    }
//
    override fun onCreate() {
        super.onCreate()
//        WorkmanagerPlugin.setPluginRegistrantCallback(this)
//        val invocationEvents: ArrayList<String> = ArrayList()
//        invocationEvents.add(InstabugFlutterPlugin.INVOCATION_EVENT_SHAKE)
//        InstabugFlutterPlugin().start(this@MyApplication, "bf8ad056dc0ddcfda7f2546eaa29844c", invocationEvents)
    }
}