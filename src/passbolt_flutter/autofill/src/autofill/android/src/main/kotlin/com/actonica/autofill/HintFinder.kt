package com.actonica.autofill

import android.text.InputType
import android.util.Log
import android.view.View
import java.util.Locale

class HintFinder {
    companion object {
        fun getHint(
            autofillHint: String?,
            inputType: Int,
            viewHint: String?,
            viewText: String?,
            className: String?,
            resourceId: String?
        ): String? {
            if (autofillHint != null) {
                Log.v(PassboltAutofillService.TAG, "Found hint using node.autofillHints $autofillHint")
                return autofillHint
            }

            var hint: String?
            if (inputType == (InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD)
                || inputType == (InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD)
                || inputType == (InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD)
            ) {
                Log.v(PassboltAutofillService.TAG, "Found hint using inputType: ${inputType}")
                hint = View.AUTOFILL_HINT_PASSWORD
                return hint
            } else if (inputType == (InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS)
                || inputType == (InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_WEB_EMAIL_ADDRESS)
            ) {
                Log.v(PassboltAutofillService.TAG, "Found hint using inputType: ${inputType}")
                hint = View.AUTOFILL_HINT_EMAIL_ADDRESS
                return hint
            } else {
                Log.v(PassboltAutofillService.TAG, "No hint using inputType: ${inputType}")
            }

            hint = inferHint(viewHint)
            if (!hint.isNullOrEmpty()) {
                Log.v(PassboltAutofillService.TAG, "Found hint using viewHint: $viewHint hint: $hint")
                return hint
            } else {
                Log.v(PassboltAutofillService.TAG, "No hint using viewHint: $viewHint")
            }

            if (viewText != null && className != null && className.toString().contains("EditText")) {
                hint = inferHint(viewText.toString())
                if (hint != null) {
                    Log.v(PassboltAutofillService.TAG, "Found hint using text: $hint")
                    return hint
                }
            } else {
                Log.v(PassboltAutofillService.TAG, "No hint using text and class $className")
            }

            hint = inferHint(resourceId)
            if (!hint.isNullOrEmpty()) {
                Log.v(PassboltAutofillService.TAG, "Found hint using resourceId($resourceId): $hint")
                return hint
            } else {
                Log.v(PassboltAutofillService.TAG, "No hint using resourceId: $resourceId")
            }

            return null
        }

        private fun inferHint(actualHint: String?): String? {
            if (actualHint == null) return null
            val hint = actualHint.toLowerCase(Locale.getDefault())
            if (hint.contains("label") || hint.contains("container")) {
                Log.v(PassboltAutofillService.TAG, "Ignoring 'label/container' hint: $hint")
                return null
            }
            if (hint.contains("password") || hint.contains("пароль")) return View.AUTOFILL_HINT_PASSWORD
            if (hint.contains("username")
                || hint.contains("login")
                || hint.contains("пользовател")
            ) return View.AUTOFILL_HINT_USERNAME
            if (hint.contains("email") || hint.contains("e-mail") || hint.contains("почта")) return View.AUTOFILL_HINT_EMAIL_ADDRESS
            if (hint.contains("name") || hint.contains("имя")) return View.AUTOFILL_HINT_NAME
            if (hint.contains("phone") || hint.contains("телефон")) return View.AUTOFILL_HINT_PHONE
            return null
        }
    }
}