package com.azvidi.coka;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;

// Không dùng FlutterApplication (đã deprecated), dùng android.app.Application tiêu chuẩn
public class Application extends android.app.Application {
    // ...
    @Override
    public void onCreate() {
        super.onCreate();

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationChannel channel = new NotificationChannel("coka_notification","coka_notification", NotificationManager.IMPORTANCE_MAX);
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }
    }
}
