package com.igelik.app;

import com.getcapacitor.BridgeActivity;
import com.igelik.app.virtualspace.VirtualSpaceManager;

/**
 * Main activity that initializes the virtual space manager.
 */
public class MainActivity extends BridgeActivity {

    private VirtualSpaceManager virtualSpaceManager;

    @Override
    public void onCreate() {
        super.onCreate();
        // Initialize virtual space manager
        virtualSpaceManager = new VirtualSpaceManager(this);
        virtualSpaceManager.initialize();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Clean up virtual space manager if needed
        if (virtualSpaceManager != null && virtualSpaceManager.isVirtualSpaceActive()) {
            virtualSpaceManager.stopVirtualSpace();
        }
    }
}