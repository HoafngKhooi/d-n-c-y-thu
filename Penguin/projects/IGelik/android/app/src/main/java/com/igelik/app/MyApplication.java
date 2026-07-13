package com.igelik.app;

import android.app.Application;

/**
 * Custom Application class to provide global application context.
 */
public class MyApplication extends Application {

    private static MyApplication instance;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
    }

    /**
     * Get the global application instance.
     *
     * @return Application instance
     */
    public static MyApplication getInstance() {
        return instance;
    }
}