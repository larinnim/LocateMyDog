package io.flutter.plugins;

public class GeofenceService extends Service {
     @Override
    public void onCreate() {
        super.onCreate();

        //If sdk > 26. Channel ID is message
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this,"messages")
                    .setContentText("Your dog escaped!")
                    .setContentTitle("Locate My Pet");
                    // .setSmallIcon(R.drawable.ic_android_black_24dp);
            //This gives the notification
            startForeground(101,builder.build());
        }
    }
    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}