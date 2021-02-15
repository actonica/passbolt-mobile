// ©2019-2020 Actonica LLC - All Rights Reserved

package com.actonica.biometrics_vault

import androidx.biometric.BiometricPrompt
import androidx.biometric.BiometricPrompt.PromptInfo
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import java.util.concurrent.Executor

internal class BiometricsAuth(
    private val activity: FragmentActivity,
    private val completionHandler: CompletionHandler,
    instructions: String
) : BiometricPrompt.AuthenticationCallback() {
    internal interface CompletionHandler {

        fun onSuccess(cryptoObject: BiometricPrompt.CryptoObject)

        fun onFailure()

        fun onError(code: String?, error: String?)
    }

    private val promptInfo: PromptInfo = PromptInfo.Builder()
        .setTitle("Use biometrics")
        .setNegativeButtonText("Cancel")
        .setDescription(instructions)
        .build()
    private val executor: Executor = ContextCompat.getMainExecutor(activity)
    private lateinit var biometricPrompt: BiometricPrompt

    fun auth(cryptoObject: BiometricPrompt.CryptoObject) {
        biometricPrompt = BiometricPrompt(activity, executor, this)
        biometricPrompt.authenticate(promptInfo, cryptoObject)
    }

    override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
        if (result.cryptoObject != null) {
            completionHandler.onSuccess(result.cryptoObject!!)
        } else {
            completionHandler.onFailure()
        }
    }

    override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
        when (errorCode) {
            BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL -> completionHandler.onError(
                "PasscodeNotSet",
                "Phone not secured by PIN, pattern or password, or SIM is currently locked."
            )
            BiometricPrompt.ERROR_NO_SPACE, BiometricPrompt.ERROR_NO_BIOMETRICS -> {
                completionHandler.onError("NotEnrolled", "No Biometrics enrolled on this device.")
            }
            BiometricPrompt.ERROR_HW_UNAVAILABLE, BiometricPrompt.ERROR_HW_NOT_PRESENT -> completionHandler.onError(
                "NotAvailable",
                "Biometrics is not available on this device."
            )
            BiometricPrompt.ERROR_LOCKOUT -> completionHandler.onError(
                "LockedOut",
                "The operation was canceled because the API is locked out due to too many attempts. This occurs after 5 failed attempts, and lasts for 30 seconds."
            )
            BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> completionHandler.onError(
                "PermanentlyLockedOut",
                "The operation was canceled because ERROR_LOCKOUT occurred too many times. Biometric authentication is disabled until the user unlocks with strong authentication (PIN/Pattern/Password)"
            )
            BiometricPrompt.ERROR_CANCELED, BiometricPrompt.ERROR_USER_CANCELED, BiometricPrompt.ERROR_NEGATIVE_BUTTON ->
                completionHandler.onError("Canceled", null)
            else -> completionHandler.onFailure()
        }
    }

    override fun onAuthenticationFailed() {
        completionHandler.onFailure()
    }
}