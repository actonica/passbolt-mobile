// ©2019-2020 Actonica LLC - All Rights Reserved

package com.actonica.biometrics_vault

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.util.Base64
import androidx.annotation.NonNull
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.security.InvalidAlgorithmParameterException
import java.security.UnrecoverableKeyException
import javax.crypto.AEADBadTagException

/**
 * Если недоступно железо для биометрии или отпечатки - UNAVAILABLE
 * Если удалил отпечаток - UNRECOVERABLE_KEY
 * Если добавил новый отпечаток к существующему - KEY_PERMANENTLY_INVALIDATED
 * Если удалил PIN с телефона - KEY_PERMANENTLY_INVALIDATED
 * */
enum class BiometricsVaultErrorCode(val value: String) {
    KEY_PERMANENTLY_INVALIDATED("KeyPermanentlyInvalidated"),
    UNRECOVERABLE_KEY("UnrecoverableKey"),
    UNAVAILABLE("Unavailable"),
    UNKNOWN_ERROR("Error"),
    CANCELED("Canceled"),
}

// https://source.android.com/security/biometric
// https://developer.android.com/jetpack/androidx/releases/biometric
// https://developer.android.com/training/sign-in/biometric-auth
public class BiometricsVaultPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private val sharedPreferencesName = "BiometricsVaultPlugin"
    private var activity: Activity? = null
    private lateinit var sharedPreferences: SharedPreferences
    private lateinit var channel: MethodChannel

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getSecretWithBiometrics") {
            try {
                val packageManager: PackageManager = activity!!.packageManager
                if (!packageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT)) {
                    result.error(BiometricsVaultErrorCode.UNAVAILABLE.value, null, null)
                    return
                }

                val instructions = call.argument<String>("instructions")!!
                val key = call.argument<String>("key")!!


                val cryptoObject =
                    CryptoObjectProvider.provideCryptoObject(
                        key,
                        KeyMode.DECRYPT
                    )

                val biometricsAuth = BiometricsAuth(
                    activity as FragmentActivity,
                    object : BiometricsAuth.CompletionHandler {
                        override fun onSuccess(cryptoObject: BiometricPrompt.CryptoObject) {
                            try {
                                val secret = sharedPreferences.getString(key, null)

                                if (secret != null) {
                                    val decrypted = cryptoObject.cipher?.doFinal(
                                        Base64.decode(
                                            secret,
                                            Base64.DEFAULT
                                        )
                                    )!!
                                    result.success(String(decrypted))
                                } else {
                                    result.success(null)
                                }
                            }
                            // Для этого исключения возможна такая причина - пользователь уже имеет
                            // зашифрованный секрет, но добавил еще биометрию. На Xiaomi ключ инвалидируется,
                            // на эмуляторе нет. CryptoObjectProvider создаст новый ключ. Будет ошибка
                            // расшифровки секрета новым ключом. Нужно сообщить, что требуется
                            // перешифровать его секрет новым ключом
                            catch (e: AEADBadTagException) {
                                result.error(
                                    BiometricsVaultErrorCode.KEY_PERMANENTLY_INVALIDATED.value,
                                    null,
                                    null
                                )
                            } catch (e: Throwable) {
                                result.error(
                                    BiometricsVaultErrorCode.UNKNOWN_ERROR.value,
                                    e.message,
                                    null
                                )
                            }
                        }

                        override fun onFailure() {}

                        override fun onError(code: String?, error: String?) {
                            result.error(code, error, null)
                        }
                    },
                    instructions
                )
                biometricsAuth.auth(cryptoObject)
            } catch (e: Throwable) {
                handleError(e, result)
            }
        } else if (call.method == "setSecretWithBiometrics") {
            try {
                val packageManager: PackageManager = activity!!.packageManager
                if (!packageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT)) {
                    result.error(BiometricsVaultErrorCode.UNAVAILABLE.value, null, null)
                    return
                }

                val instructions = call.argument<String>("instructions")!!
                val key = call.argument<String>("key")!!
                val clear = call.argument<String>("clear")!!

                val cryptoObject = CryptoObjectProvider.provideCryptoObject(
                    key,
                    KeyMode.ENCRYPT
                )

                val biometricsAuth = BiometricsAuth(
                    activity as FragmentActivity,
                    object : BiometricsAuth.CompletionHandler {
                        override fun onSuccess(cryptoObject: BiometricPrompt.CryptoObject) {
                            val encrypted = cryptoObject.cipher?.doFinal(clear.toByteArray())
                            val secret = Base64.encodeToString(encrypted!!, Base64.DEFAULT)

                            val editor = sharedPreferences.edit()
                            editor.putString(key, secret)
                            editor.apply()

                            result.success("Success")
                        }

                        override fun onFailure() {}

                        override fun onError(code: String?, error: String?) {
                            result.error(code, error, null)
                        }
                    },
                    instructions
                )
                biometricsAuth.auth(cryptoObject)
            } catch (error: Throwable) {
                handleError(error, result)
            }
        } else if (call.method == "deleteSecretWithBiometrics") {
            try {
                val packageManager: PackageManager = activity!!.packageManager
                if (!packageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT)) {
                    result.error(BiometricsVaultErrorCode.UNAVAILABLE.value, null, null)
                    return
                }

                val key = call.argument<String>("key")!!

                CryptoObjectProvider.deleteSecretKey(key)
                result.success("Success")
            } catch (error: Throwable) {
                handleError(error, result)
            }
        } else {
            result.notImplemented()
        }
    }

    private fun handleError(error: Throwable, result: Result) {
        when (error) {
            is InvalidAlgorithmParameterException -> {
                result.error(BiometricsVaultErrorCode.UNAVAILABLE.value, null, null)
            }
            is UnrecoverableKeyException -> {
                result.error(BiometricsVaultErrorCode.UNRECOVERABLE_KEY.value, null, null)
            }
            is KeyPermanentlyInvalidatedException -> {
                result.error(
                    BiometricsVaultErrorCode.KEY_PERMANENTLY_INVALIDATED.value,
                    null,
                    null
                );
            }
            else -> {
                result.error(BiometricsVaultErrorCode.UNKNOWN_ERROR.value, error.toString(), null)
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        channel = MethodChannel(binding.flutterEngine.dartExecutor, "com.actonica.biometrics_vault")
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {}

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        sharedPreferences =
            activity!!.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
        channel.setMethodCallHandler(null)
    }
}
