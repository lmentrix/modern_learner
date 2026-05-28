package com.modernlearner.modern_learner_production

import android.os.Bundle
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        checkGooglePlayServices()
    }

    override fun onResume() {
        super.onResume()
        checkGooglePlayServices()
    }

    /**
     * Verifies Google Play services availability as required by FCM.
     * If unavailable, prompts the user to install/update via the Play Store dialog.
     */
    private fun checkGooglePlayServices() {
        val availability = GoogleApiAvailability.getInstance()
        val result = availability.isGooglePlayServicesAvailable(this)
        if (result != ConnectionResult.SUCCESS && availability.isUserResolvableError(result)) {
            availability.makeGooglePlayServicesAvailable(this)
        }
    }
}
