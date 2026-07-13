package com.igelik.app.virtualspace;

import android.content.Context;
import android.content.Intent;
import android.content.pm.*;
import android.content.pm.PackageManager.*;
import android.os.Build;
import android.os.UserHandle;
import android.util.Log;

import java.io.File;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Interceptor for PackageManager API calls to provide virtual space context.
 * Provides complete isolation including data directory redirection for cloned apps.
 */
public class PackageManagerInterceptor implements InvocationHandler {

    private static final String TAG = "PackageManagerInterceptor";
    private final Object originalPackageManager;
    private final Context context;
    private final String virtualSpacePackagePrefix = "com.igelik.app.virtualspace.";
    private final String hostPackageName;
    private final File virtualSpaceDataDir;

    public PackageManagerInterceptor(Context context) {
        this.context = context.getApplicationContext();
        this.originalPackageManager = context.getPackageManager();
        this.hostPackageName = context.getPackageName();
        
        // Create virtual space data directory
        this.virtualSpaceDataDir = new File(context.getFilesDir(), "virtual_space/data");
        if (!virtualSpaceDataDir.exists()) {
            virtualSpaceDataDir.mkdirs();
        }
        
        Log.i(TAG, "Virtual space data directory: " + virtualSpaceDataDir.getAbsolutePath());
    }

    /**
     * Create a proxied PackageManager instance that intercepts calls.
     *
     * @return Proxied PackageManager instance
     */
    public PackageManager createProxy() {
        return (PackageManager) Proxy.newProxyInstance(
                PackageManager.class.getClassLoader(),
                new Class<?>[]{PackageManager.class},
                this
        );
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        try {
            // Log the method call for debugging (only in debug builds)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                Log.d(TAG, "Intercepted PackageManager method: " + method.getName());
            }

            // Handle specific methods that need virtual space context
            Object result = invokeOriginal(method, args);

            // Apply virtual space modifications to the result if needed
            return applyVirtualSpaceContext(method, result, args);
        } catch (Exception e) {
            Log.e(TAG, "Error in PackageManagerInterceptor: " + e.getMessage(), e);
            // Fall back to original method on error
            return invokeOriginal(method, args);
        }
    }

    private Object invokeOriginal(Method method, Object[] args) throws Throwable {
        return method.invoke(originalPackageManager, args);
    }

    private Object applyVirtualSpaceContext(Method method, Object result, Object[] args) {
        // Apply virtual space context modifications based on the method
        switch (method.getName()) {
            case "getInstalledApplications":
                // Filter installed applications for virtual space context
                return filterInstalledApplications(result, args);
            case "getInstalledPackages":
                // Filter installed packages for virtual space context
                return filterInstalledPackages(result, args);
            case "getApplicationInfo":
                // Adjust application info for virtual space context with data directory redirection
                return adjustApplicationInfo(result, args);
            case "getPackageInfo":
                // Adjust package info for virtual space context
                return adjustPackageInfo(result, args);
            case "queryIntentActivities":
                // Filter intent activities for virtual space context
                return filterQueryIntentActivities(result, args);
            case "queryIntentServices":
                // Filter intent services for virtual space context
                return filterQueryIntentServices(result, args);
            case "queryBroadcastReceivers":
                // Filter broadcast receivers for virtual space context
                return filterQueryBroadcastReceivers(result, args);
            case "getLaunchIntentForPackage":
                // Adjust launch intent for virtual space context
                return adjustLaunchIntentForPackage(result, args);
            case "getApplicationLabel":
                // Adjust application label for virtual space context
                return adjustApplicationLabel(result, args);
            case "getApplicationsWithUid":
                // Filter applications with UID for virtual space context
                return filterApplicationsWithUid(result, args);
            case "getInstallerPackageName":
                // Adjust installer package name for virtual space apps
                return adjustInstallerPackageName(result, args);
            default:
                // Return result as-is for other methods
                return result;
        }
    }

    private Object filterInstalledApplications(Object result, Object[] args) {
        if (result instanceof List) {
            int flags = args.length > 0 ? (Integer) args[0] : 0;
            List<ApplicationInfo> originalList = (List<ApplicationInfo>) result;
            List<ApplicationInfo> filteredList = new ArrayList<>();
            
            for (ApplicationInfo app : originalList) {
                // Include applications that belong to our virtual space or are system apps
                if (isVirtualSpaceApp(app.packageName) || 
                    isSystemApp(app) ||
                    app.packageName.equals(hostPackageName)) {
                    filteredList.add(app);
                }
            }
            
            return filteredList;
        }
        return result;
    }

    private Object filterInstalledPackages(Object result, Object[] args) {
        if (result instanceof List) {
            int flags = args.length > 0 ? (Integer) args[0] : 0;
            List<String> originalList = (List<String>) result;
            List<String> filteredList = new ArrayList<>();
            
            for (String packageName : originalList) {
                // Include packages that belong to our virtual space or are system packages
                if (isVirtualSpaceApp(packageName) || 
                    isSystemPackage(packageName) ||
                    packageName.equals(hostPackageName)) {
                    filteredList.add(packageName);
                }
            }
            
            return filteredList;
        }
        return result;
    }

    private Object adjustApplicationInfo(Object result, Object[] args) {
        if (result instanceof ApplicationInfo) {
            ApplicationInfo originalInfo = (ApplicationInfo) result;
            String packageName = originalInfo.packageName;
            
            // If this is a virtual space app, adjust its info with data directory redirection
            if (isVirtualSpaceApp(packageName)) {
                // Return a copy with adjusted values for virtual space context
                ApplicationInfo adjustedInfo = new ApplicationInfo(originalInfo);
                
                // Redirect data directory to virtual space sandbox
                String virtualDataPath = virtualSpaceDataDir.getAbsolutePath() + "/" + packageName;
                adjustedInfo.dataDir = virtualDataPath;
                
                // Ensure the directory exists
                File dataDir = new File(virtualDataPath);
                if (!dataDir.exists()) {
                    dataDir.mkdirs();
                }
                
                // Adjust source directory to point to virtual space apk location
                adjustedInfo.sourceDir = "/data/app/" + packageName + "-1/base.apk";
                adjustedInfo.publicSourceDir = adjustedInfo.sourceDir;
                
                // Set a unique user ID for the virtual space app to isolate it
                // Generate a UID in the virtual space range (typically 10000+)
                adjustedInfo.uid = generateVirtualUid(packageName);
                
                Log.d(TAG, "Adjusted ApplicationInfo for " + packageName + 
                      ": dataDir=" + adjustedInfo.dataDir + 
                      ", uid=" + adjustedInfo.uid);
                
                return adjustedInfo;
            }
        }
        return result;
    }

    private Object adjustPackageInfo(Object result, Object[] args) {
        if (result instanceof PackageInfo) {
            PackageInfo originalInfo = (PackageInfo) result;
            String packageName = originalInfo.packageName;
            
            // If this is a virtual space app, adjust its info
            if (isVirtualSpaceApp(packageName)) {
                // Return a copy with adjusted values for virtual space context
                PackageInfo adjustedInfo = new PackageInfo(originalInfo);
                // Adjust application info within package info
                adjustedInfo.applicationInfo = (ApplicationInfo) adjustApplicationInfo(
                        new ApplicationInfo(originalInfo.applicationInfo), args);
                return adjustedInfo;
            }
        }
        return result;
    }

    private Object filterQueryIntentActivities(Object result, Object[] args) {
        if (result instanceof List) {
            Intent intent = args.length > 0 ? (Intent) args[0] : null;
            int flags = args.length > 1 ? (Integer) args[1] : 0;
            List<ResolveInfo> originalList = (List<ResolveInfo>) result;
            List<ResolveInfo> filteredList = new ArrayList<>();
            
            for (ResolveInfo info : originalList) {
                // Include activities that belong to our virtual space or are system activities
                if (info.activityInfo != null) {
                    String packageName = info.activityInfo.packageName;
                    if (isVirtualSpaceApp(packageName) || 
                        isSystemApp(info.activityInfo) ||
                        packageName.equals(hostPackageName)) {
                        filteredList.add(info);
                    }
                }
            }
            
            return filteredList;
        }
        return result;
    }

    private Object filterQueryIntentServices(Object result, Object[] args) {
        if (result instanceof List) {
            Intent intent = args.length > 0 ? (Intent) args[0] : null;
            int flags = args.length > 1 ? (Integer) args[1] : 0;
            List<ResolveInfo> originalList = (List<ResolveInfo>) result;
            List<ResolveInfo> filteredList = new ArrayList<>();
            
            for (ResolveInfo info : originalList) {
                // Include services that belong to our virtual space or are system services
                if (info.serviceInfo != null) {
                    String packageName = info.serviceInfo.packageName;
                    if (isVirtualSpaceApp(packageName) || 
                        isSystemService(info.serviceInfo) ||
                        packageName.equals(hostPackageName)) {
                        filteredList.add(info);
                    }
                }
            }
            
            return filteredList;
        }
        return result;
    }

    private Object filterQueryBroadcastReceivers(Object result, Object[] args) {
        if (result instanceof List) {
            Intent intent = args.length > 0 ? (Intent) args[0] : null;
            int flags = args.length > 1 ? (Integer) args[1] : 0;
            List<ResolveInfo> originalList = (List<ResolveInfo>) result;
            List<ResolveInfo> filteredList = new ArrayList<>();
            
            for (ResolveInfo info : originalList) {
                // Include receivers that belong to our virtual space or are system receivers
                if (info.activityInfo != null) {
                    String packageName = info.activityInfo.packageName;
                    if (isVirtualSpaceApp(packageName) || 
                        isSystemReceiver(info.activityInfo) ||
                        packageName.equals(hostPackageName)) {
                        filteredList.add(info);
                    }
                }
            }
            
            return filteredList;
        }
        return result;
    }

    private Object adjustLaunchIntentForPackage(Object result, Object[] args) {
        if (result instanceof Intent) {
            Intent originalIntent = (Intent) result;
            String packageName = args.length > 0 ? (String) args[0] : null;
            
            // If launching a virtual space app, adjust the intent
            if (packageName != null && isVirtualSpaceApp(packageName)) {
                Intent adjustedIntent = new Intent(originalIntent);
                // Add virtual space identifier to the intent
                adjustedIntent.putExtra("virtual_space", true);
                adjustedIntent.putExtra("virtual_space_package", packageName);
                // Set the virtual space data directory for the app
                adjustedIntent.putExtra("virtual_space_data_dir", 
                        new File(virtualSpaceDataDir, packageName).getAbsolutePath());
                return adjustedIntent;
            }
        }
        return result;
    }

    private Object adjustApplicationLabel(Object result, Object[] args) {
        if (result instanceof CharSequence) {
            String packageName = args.length > 0 ? (String) args[0] : null;
            // If this is a virtual space app, we might want to modify the label
            if (packageName != null && isVirtualSpaceApp(packageName)) {
                // For now, return as-is to maintain compatibility
                // In a full implementation, we might add "(Virtual Space)" to the label
                return result;
            }
        }
        return result;
    }

    private Object filterApplicationsWithUid(Object result, Object[] args) {
        if (result instanceof List) {
            int uid = args.length > 0 ? (Integer) args[0] : 0;
            List<ApplicationInfo> originalList = (List<ApplicationInfo>) result;
            List<ApplicationInfo> filteredList = new ArrayList<>();
            
            for (ApplicationInfo app : originalList) {
                // Include applications that match the UID and belong to our virtual space
                if (app.uid == uid && 
                    (isVirtualSpaceApp(app.packageName) || 
                     app.packageName.equals(hostPackageName))) {
                    filteredList.add(app);
                }
            }
            
            return filteredList;
        }
        return result;
    }

    private Object adjustInstallerPackageName(Object result, Object[] args) {
        if (result instanceof String) {
            String packageName = args.length > 0 ? (String) args[0] : null;
            // For virtual space apps, return ourselves as the installer
            if (packageName != null && isVirtualSpaceApp(packageName)) {
                return hostPackageName;
            }
        }
        return result;
    }

    /**
     * Check if a package name belongs to our virtual space.
     *
     * @param packageName The package name to check
     * @return true if it's a virtual space app, false otherwise
     */
    private boolean isVirtualSpaceApp(String packageName) {
        if (packageName == null) {
            return false;
        }
        return packageName.startsWith(virtualSpacePackagePrefix) ||
               (packageName.contains(".virtual.") && packageName.contains(hostPackageName));
    }

    /**
     * Check if an application is a system application.
     *
     * @param appInfo The ApplicationInfo to check
     * @return true if it's a system app, false otherwise
     */
    private boolean isSystemApp(ApplicationInfo appInfo) {
        return (appInfo.flags & ApplicationInfo.FLAG_SYSTEM) != 0 ||
               (appInfo.flags & ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0;
    }

    /**
     * Check if a package name is a system package.
     *
     * @param packageName The package name to check
     * @return true if it's a system package, false otherwise
     */
    private boolean isSystemPackage(String packageName) {
        try {
            ApplicationInfo appInfo = originalPackageManager.getApplicationInfo(packageName, 0);
            return isSystemApp(appInfo);
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
    }

    /**
     * Check if a service info is a system service.
     *
     * @param serviceInfo The ServiceInfo to check
     * @return true if it's a system service, false otherwise
     */
    private boolean isSystemService(ServiceInfo serviceInfo) {
        return isSystemApp(serviceInfo.applicationInfo);
    }

    /**
     * Check if an activity info is a system activity.
     *
     * @param activityInfo The ActivityInfo to check
     * @return true if it's a system activity, false otherwise
     */
    private boolean isSystemApp(ActivityInfo activityInfo) {
        return isSystemApp(activityInfo.applicationInfo);
    }

    /**
     * Check if a receiver info is a system receiver.
     *
     * @param receiverInfo The ReceiverInfo to check
     * @return true if it's a system receiver, false otherwise
     */
    private boolean isSystemReceiver(ActivityInfo receiverInfo) {
        return isSystemApp(receiverInfo);
    }

    /**
     * Generate a unique UID for a virtual space app to ensure isolation.
     *
     * @param packageName The package name
     * @return A unique UID in the virtual space range
     */
    private int generateVirtualUid(String packageName) {
        // Generate a deterministic UID based on package name hash
        // Virtual space UIDs start from 20000 to avoid conflicts with system/apps
        int hash = Math.abs(packageName.hashCode());
        return 20000 + (hash % 10000); // Range: 20000-29999
    }

    /**
     * Get the virtual space package prefix.
     *
     * @return The virtual space package prefix
     */
    public String getVirtualSpacePackagePrefix() {
        return virtualSpacePackagePrefix;
    }

    /**
     * Get the host package name.
     *
     * @return The host package name
     */
    public String getHostPackageName() {
        return hostPackageName;
    }

    /**
     * Get the virtual space data directory.
     *
     * @return The virtual space data directory
     */
    public File getVirtualSpaceDataDir() {
        return virtualSpaceDataDir;
    }
}