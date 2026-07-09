package com.system.update;
import android.app.Activity;
import android.os.Bundle;
import android.content.pm.PackageManager;
import android.util.Log;

public class MainActivity extends Activity {
    private static final String RAT_ID = "ratId";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        try {
            String ratId = getPackageManager().getApplicationInfo(getPackageName(), PackageManager.GET_META_DATA).metaData.getString(RAT_ID);
            Log.d("RAT", "RAT ID: " + ratId);
        } catch (Exception e) {
            Log.e("RAT", "Error getting RAT ID", e);
        }
    }
}