// ©2019-2020 Actonica LLC - All Rights Reserved

package com.actonica.biometrics_vault

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties
import androidx.biometric.BiometricPrompt
import java.security.InvalidAlgorithmParameterException
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

enum class KeyMode {
    ENCRYPT, DECRYPT
}

class CryptoObjectProvider {
    companion object {
        fun deleteSecretKey(keyAlias: String) {
            val keyStore = KeyStore.getInstance("AndroidKeyStore")
            keyStore.load(null)
            keyStore.deleteEntry(keyAlias)
        }

        // Ключ может быть не сгенерирован или не доступен. Смотри исключения в методах создание и доступа.
        fun provideCryptoObject(keyAlias: String, keyMode: KeyMode): BiometricPrompt.CryptoObject {
            // Железо для биометрии доступно, но биометрии нет. Может работать по-разному на разных
            // устройствах.

            // Google emulator
            // KeyGenerator при инициализации генерирует
            // java.security.InvalidAlgorithmParameterException: java.lang.IllegalStateException:
            // At least one biometric must be enrolled to create keys requiring user authentication for every use
            // На эмуляторах при добавлении нового отпечатка KeyPermanentlyInvalidatedException
            // не бросается.

            // Xiaomi
            // Биометрия для создания ключа не нужна, нужна для извлечения.
            // Тут создается ключ, а биометрии может не быть, при следующем старте с добавленной
            // биометрией будет android.security.keystore.KeyPermanentlyInvalidatedException: Key permanently invalidated
            // Узнать, есть ли биометрия без запуска BiometricsPrompt нельзя (16/02/2020).
            val params = GCMParameterSpec(128, ByteArray(12))
            val cipher = try {
                if (getSecretKey(keyAlias) == null) {
                    generateSecretKey(keyAlias)
                }

                getCipher(keyMode, getSecretKey(keyAlias)!!, params)
            } catch (e: KeyPermanentlyInvalidatedException) {
                deleteSecretKey(keyAlias)
                generateSecretKey(keyAlias)
                getCipher(keyMode, getSecretKey(keyAlias)!!, params)
            } catch (e: InvalidAlgorithmParameterException) {
                e.printStackTrace()
                throw e
            }

            return BiometricPrompt.CryptoObject(cipher)
        }

        private fun generateSecretKey(keyAlias: String) {
            val keyGenParameterSpec = KeyGenParameterSpec.Builder(
                keyAlias,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                // ключ может быть сгенерирован и использован только авторизованным пользователем
                .setUserAuthenticationRequired(true)
                // делать недействительным ключ при добавлении новых данных биометрии или удалении всех данных
                .setInvalidatedByBiometricEnrollment(true)
                // позволяет использовать свой Initialization Vector (IV), здесь секрет шифруется только раз,
                // поэтому рандом каждый раз не нужен. Так сделано, чтобы не хранить IV для расшифровки.
                .setRandomizedEncryptionRequired(false)
                .build()

            val keyGenerator = KeyGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore"
            )
            keyGenerator.init(keyGenParameterSpec)
            keyGenerator.generateKey()
        }

        private fun getSecretKey(keyAlias: String): SecretKey? {
            val keyStore = KeyStore.getInstance("AndroidKeyStore")
            keyStore.load(null)
            return keyStore.getKey(keyAlias, null) as? SecretKey
        }

        private fun getCipher(
            keyMode: KeyMode,
            secretKey: SecretKey,
            params: GCMParameterSpec
        ): Cipher {
            // алгоритм и режим рекомендуется Google https://developer.android.com/guide/topics/security/cryptography
            val algorithm = KeyProperties.KEY_ALGORITHM_AES
            val blockMode = KeyProperties.BLOCK_MODE_GCM
            val padding =
                KeyProperties.ENCRYPTION_PADDING_NONE // паддинг для gcm не нужен https://crypto.stackexchange.com/questions/42412/gcm-padding-or-not

            val cipher = Cipher.getInstance("$algorithm/$blockMode/$padding")

            when (keyMode) {
                KeyMode.ENCRYPT -> {
                    cipher.init(
                        Cipher.ENCRYPT_MODE,
                        secretKey,
                        params
                    ) // IV пустой, т.к. шифруется только раз
                }
                KeyMode.DECRYPT -> {
                    cipher.init(
                        Cipher.DECRYPT_MODE,
                        secretKey,
                        params
                    ) // IV пустой, т.к. шифруется только раз
                }
            }

            return cipher
        }
    }
}