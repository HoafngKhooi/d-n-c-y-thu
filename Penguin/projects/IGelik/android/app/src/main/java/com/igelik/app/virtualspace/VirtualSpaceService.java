package com.igelik.app.virtualspace;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.os.PowerManager;
import android.os.WifiManager;
import android.util.Log;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

/**
 * Foreground service that runs the virtual space container in a separate process.
 * Holds WakeLock and WifiLock to prevent CPU/WiFi sleep and avoid LMK/Doze killing.
 */
public class VirtualSpaceService extends Service {

    private static final String TAG = "VirtualSpaceService";
    private static final String CHANNEL_ID = "virtual_space_foreground_channel";
    private static final int NOTIFICATION_ID = 1;

    private PowerManager.WakeLock wakeLock;
    private WifiManager.WifiLock wifiLock;
    private boolean isStarted = false;

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "VirtualSpaceService created");
        initializeNotificationChannel();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG, "VirtualSpaceService started");

        if (intent != null) {
            String action = intent.getAction();
            if ("com.igelik.app.action.START_VIRTUAL_SPACE".equals(action)) {
                startVirtualSpace();
            } else if ("com.igelik.app.action.STOP_VIRTUAL_SPACE".equals(action)) {
                stopVirtualSpace();
            }
        }

        // Make this service sticky so it gets restarted if killed
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "VirtualSpaceService destroyed");
        stopVirtualSpace();
    }

    @Override
    public IBinder onBind(Intent intent) {
        // We don't provide binding, so return null
        return null;
    }

    /**
     * Start the virtual space functionality including acquiring locks.
     */
    private void startVirtualSpace() {
        if (isStarted) {
            Log.w(TAG, "Virtual space service already started");
            return;
        }

        Log.i(TAG, "Starting virtual space functionality");

        // Acquire WakeLock to prevent CPU sleep
        PowerManager powerManager = (PowerManager) getSystemService(POWER_SERVICE);
        if (powerManager != null) {
            wakeLock = powerManager.newWakeLock(
                    PowerManager.PARTIAL_WAKE_LOCK,
                    "VirtualSpace:WakeLock"
            );
            wakeLock.acquire(10*60*1000L); // 10 minutes
            Log.i(TAG, "WakeLock acquired");
        }

        // Acquire WifiLock to prevent WiFi sleep
        WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(WIFI_SERVICE);
        if (wifiManager != null) {
            wifiLock = wifiManager.createWifiLock(
                    WifiManager.WIFI_MODE_FULL,
                    "VirtualSpace:WifiLock"
            );
            wifiLock.acquire();
            Log.i(TAG, "WifiLock acquired");
        }

        // Start foreground service with persistent notification
        startForeground(NOTIFICATION_ID, buildNotification());

        isStarted = true;
        Log.i(TAG, "Virtual space functionality started");
    }

    /**
     * Stop the virtual space functionality and release locks.
     */
    private void stopVirtualSpace() {
        if (!isStarted) {
            Log.w(TAG, "Virtual space service not started");
            return;
        }

        Log.i(TAG, "Stopping virtual space functionality");

        // Release WakeLock
        if (wakeLock != null && wakeLock.isHeld()) {
            wakeLock.release();
            wakeLock = null;
            Log.i(TAG, "WakeLock released");
        }

        // Release WifiLock
        if (wifiLock != null && wifiLock.isHeld()) {
            wifiLock.release();
            wifiLock = null;
            Log.i(TAG, "WifiLock released");
        }

        // Stop foreground service
        stopForeground(STOP_FOREGROUND_REMOVE);
        isStarted = false;
        Log.i(TAG, "Virtual space functionality stopped");
    }

    /**
     * Build the persistent notification for the foreground service.
     *
     * @return Notification object for the foreground service
     */
    private Notification buildNotification() {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_lock_idle_low_battery)
                .setContentTitle(getString(R.string.virtual_space_active))
                .setContentText(getString(R.string.virtual_space_description))
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setOngoing(true)
                .setCategory(NotificationCompat.CATEGORY_SERVICE);

        // Make notification non-dismissible on Android O+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder.setOnlyAlertOnce(true);
        }

        return builder.build();
    }

    /**
     * Initialize the notification channel for Android O+.
     */
    @RequiresApi(api = Build.VERSION_CODES.O)
    private void initializeNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Virtual Space Service",
                    NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription("Shows when virtual space container is running");
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);

            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(channel);
            }
        }
    }
}