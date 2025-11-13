package com.azvidi.coka;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.window.SplashScreenView;

import androidx.core.view.WindowCompat;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    private  Intent forService;
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
    }
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // Aligns the Flutter view vertically with the window.
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Disable the Android splash screen fade out animation to avoid
            // a flicker before the similar frame is drawn in Flutter.
            getSplashScreen()
                    .setOnExitAnimationListener(
                            SplashScreenView::remove);
        }

        super.onCreate(savedInstanceState);
    }
}

