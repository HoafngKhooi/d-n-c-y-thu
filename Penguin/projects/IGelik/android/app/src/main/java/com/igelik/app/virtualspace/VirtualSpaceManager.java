package com.igelik.app.virtualspace;

import android.app.ActivityManager;
import android.app.AppOpsManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.PowerManager;
import android.os.UserHandle;
import android.util.Log;

import androidx.annotation.RequiresApi;

/**
 * Core manager for the Virtual Space container/sandbox functionality.
 * Handles initialization, lifecycle management, and coordination of virtual space components.
 */
public class VirtualSpaceManager {

    private static final String TAG = "VirtualSpaceManager";
    private static final String ACTION_START_VIRTUAL_SPACE = "com.igelik.app.action.START_VIRTUAL_SPACE";
    private static final String ACTION_STOP_VIRTUAL_SPACE = "com.igelik.app.action.STOP_VIRTUAL_SPACE";

    private final Context context;
    private VirtualSpaceService virtualSpaceService;
    private boolean isVirtualSpaceActive = false;

    public VirtualSpaceManager(Context context) {
        this.context = context.getApplicationContext();
    }

    /**
     * Initialize the virtual space manager.
     * Should be called from Application or Activity onCreate.
     */
    public void initialize() {
        Log.i(TAG, "VirtualSpaceManager initialized");
        // Check if we need to restore virtual space state after reboot
        checkAndRestoreVirtualSpaceState();
    }

    /**
     * Start the virtual space container.
     * This will launch the foreground service in a separate process.
     */
    public void startVirtualSpace() {
        if (isVirtualSpaceActive) {
            Log.w(TAG, "Virtual space is already active");
            return;
        }

        Log.i(TAG, "Starting virtual space container");

        // Check and handle battery optimization
        BatteryOptimizationHelper.checkAndPromptBatteryWhitelist(context);

        // Start the virtual space service
        Intent serviceIntent = new Intent(context, VirtualSpaceService.class);
        serviceIntent.setAction("com.igelik.app.action.START_VIRTUAL_SPACE");
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent);
        } else {
            context.startService(serviceIntent);
        }

        isVirtualSpaceActive = true;
        Log.i(TAG, "Virtual space container started");
    }

    /**
     * Stop the virtual space container.
     * This will stop the foreground service and clean up resources.
     */
    public void stopVirtualSpace() {
        if (!isVirtualSpaceActive) {
            Log.w(TAG, "Virtual space is not active");
            return;
        }

        Log.i(TAG, "Stopping virtual space container");

        // Stop the virtual space service
        Intent serviceIntent = new Intent(context, VirtualSpaceService.class);
        serviceIntent.setAction("com.igelik.app.action.STOP_VIRTUAL_SPACE");
        context.stopService(serviceIntent);

        isVirtualSpaceActive = false;
        Log.i(TAG, "Virtual space container stopped");
    }

    /**
     * Check if the virtual space is currently active.
     *
     * @return true if virtual space is active, false otherwise
     */
    public boolean isVirtualSpaceActive() {
        return isVirtualSpaceActive;
    }

    /**
     * Check and restore virtual space state after device reboot.
     * This ensures continuity of the virtual space experience.
     */
    private void checkAndRestoreVirtualSpaceState() {
        // Check if the service is running
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        if (activityManager != null) {
            for (ActivityManager.RunningServiceInfo service : activityManager.getRunningServices(Integer.MAX_VALUE)) {
                if (VirtualSpaceService.class.getName().equals(service.service.getClassName())) {
                    isVirtualSpaceActive = true;
                    Log.i(TAG, "Virtual space service found running, state restored");
                    break;
                }
            }
        }
    }

    /**
     * Get the ActivityManager interceptor for hooking API calls.
     * This provides the proxy mechanism for ActivityManager interactions.
     *
     * @return ActivityManager interceptor instance
     */
    public ActivityManagerInterceptor getActivityManagerInterceptor() {
        return new ActivityManagerInterceptor(context);
    }

    /**
     * Get the PackageManager interceptor for hooking API calls.
     * This provides the proxy mechanism for PackageManager interactions.
     *
     * @return PackageManager interceptor instance
     */
    public PackageManagerInterceptor getPackageManagerInterceptor() {
        return new PackageManagerInterceptor(context);
    }

    /**
     * Get the WindowManager interceptor for hooking API calls.
     * This provides the proxy mechanism for WindowManager interactions.
     *
     * @return WindowManager interceptor instance
     */
    public WindowManagerInterceptor getWindowManagerInterceptor() {
        return new WindowManagerInterceptor(context);
    }
}