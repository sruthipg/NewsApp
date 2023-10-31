package com.iptelecom.topnews.top_news_app
//
import android.content.Context
import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDex;
//import io.flutter.plugin.common.PluginRegistry
//
//import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin
//
//class TelecomApp : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
//    override fun registerWith(registry: PluginRegistry?) {
//        val key: String? = FlutterFirebaseMessagingPlugin::class.java.canonicalName
//        if (!registry?.hasPlugin(key)!!) {
//            MyPlugin.registerWith(registry?.registrarFor("com.iptelecom.topnews.top_news_app.MyPlugin"));
//        }
//    }
//}
class TelecomApp : FlutterApplication(){
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
