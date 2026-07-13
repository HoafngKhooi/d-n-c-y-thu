package com.igelik.app.virtualspace;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.PowerManager;
import android.provider.Settings;
import android.util.Log;

import androidx.annotation.RequiresApi;

/**
 * Helper class to manage battery optimization whitelisting for the virtual space service.
 * Checks if the app is whitelisted from battery optimization and prompts user if needed.
 */
public class BatteryOptimizationHelper {

    private static final String TAG = "BatteryOptimizationHelper";
    private static final int REQUEST_CODE_BATTERY_OPTIMIZATION = 1001;

    private BatteryOptimizationHelper() {
        // Prevent instantiation
    }

    /**
     * Check if the app is whitelisted from battery optimization and prompt user if needed.
     *
     * @param context Application context
     */
    public static void checkAndPromptBatteryWhitelist(Context context) {
        if (!isIgnoringBatteryOptimizations(context)) {
            Log.i(TAG, "App is not whitelisted from battery optimization, prompting user");
            promptBatteryOptimizationWhitelist(context);
        } else {
            Log.i(TAG, "App is already whitelisted from battery optimization");
        }
    }

    /**
     * Check if the app is currently whitelisted from battery optimization.
     *
     * @param context Application context
     * @return true if whitelisted, false otherwise
     */
    public static boolean isIgnoringBatteryOptimizations(Context context) {
        PowerManager powerManager = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
        if (powerManager != null) {
            return powerManager.isIgnoringBatteryOptimizations(context.getPackageName());
        }
        return false;
    }

    /**
     * Prompt the user to whitelist the app from battery optimization.
     * This launches the system battery optimization settings screen.
     *
     * @param context Application context
     */
    @RequiresApi(api = Build.VERSION_CODES.M)
    public static void promptBatteryOptimizationWhitelist(Context context) {
        PowerManager powerManager = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
        if (powerManager != null && !powerManager.isIgnoringBatteryOptimizations(context.getPackageName())) {
            Intent intent = new Intent();
            String packageName = context.getPackageName();
            
            intent.setAction(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
            intent.setData(Uri.parse("package:" + packageName));
            
            // Only start activity if we're in an activity context
            if (context instanceof android.app.Activity) {
                try {
                    ((android.app.Activity) context).startActivityForResult(
                            intent, REQUEST_CODE_BATTERY_OPTIMIZATION);
                    Log.i(TAG, "Battery optimization whitelist prompt launched");
                } catch (Exception e) {
                    Log.e(TAG, "Failed to launch battery optimization prompt: " + e.getMessage());
                }
            } else {
                // For non-activity contexts, just log that whitelisting is needed
                Log.w(TAG, "Battery optimization whitelist needed but not in activity context");
            }
        }
    }

    /**
     * Handle the result from the battery optimization prompt.
     * This should be called from Activity.onActivityResult().
     *
     * @param requestCode The request code passed to startActivityForResult()
     * @param resultCode  The result code returned by the child activity
     * @param data        The Intent data returned by the child activity
     * @return true if the result was handled, false otherwise
     */
    public static boolean handleBatteryOptimizationResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_BATTERY_OPTIMIZATION) {
            boolean isIgnoring = isIgnoringBatteryOptimizations(MyApplication.getInstance());
            Log.i(TAG, "Battery optimization result handled. Whitelisted: " + isIgnoring);
            return true;
        }
        return false;
    }

    /**
     * Get a user-friendly message explaining why battery optimization whitelisting is needed.
     *
     * @return Message string for user explanation
     */
    public static String getBatteryOptimizationExplanation() {
        return MyApplication.getInstance().getString(R.string.battery_optimization_explanation);
    }
}