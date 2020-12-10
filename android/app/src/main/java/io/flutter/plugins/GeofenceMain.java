package io.flutter.plugins;

import io.flutter.app.FlutterApplication;

public class GeofenceMain extends FlutterApplication {
    
    @Override
    public void onCreate() {
        super.onCreate();

        //check for 26 SDK. If it is, you need to create a notification channel. You want to register the channel as soon as your app starts
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationChannel channel = new NotificationChannel("messages","Messages", NotificationManager.IMPORTANCE_LOW);
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }
    }
}