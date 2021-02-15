package com.actonica.autofill

import android.app.Activity.RESULT_OK
import android.os.Bundle
import android.os.Handler
import android.os.ResultReceiver
import com.google.gson.Gson

class MessageReceiver(private val service: PassboltAccessibilityService, handler: Handler) :
    ResultReceiver(handler) {
    override fun onReceiveResult(resultCode: Int, resultData: Bundle?) {
        super.onReceiveResult(resultCode, resultData)

        if (resultCode != RESULT_OK) {
            return
        }

        resultData?.let {
            val gson = Gson()
            val datasets = gson.fromJson<AutofillDatasets>(
                it.getString(PassboltAccessibilityService.INTENT_EXTRAS_APP_MESSAGE),
                AutofillDatasets::class.java
            )
            service.performPaste(datasets)
        }
    }
}