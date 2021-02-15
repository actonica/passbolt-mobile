// ©2019-2020 Actonica LLC - All Rights Reserved

package com.actonica.autofill

import android.app.Activity
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.os.Bundle
import android.os.Parcel
import android.os.ResultReceiver
import android.service.autofill.Dataset
import android.service.autofill.FillResponse
import android.util.Log
import android.view.autofill.AutofillId
import android.view.autofill.AutofillManager.EXTRA_AUTHENTICATION_RESULT
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import androidx.annotation.NonNull
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

public class AutofillPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        const val TAG: String = "PassboltAutofillPlugin"
    }

    private var activity: Activity? = null
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(
        @NonNull
        flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
    ) {
        channel =
            MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "autofill")
        channel.setMethodCallHandler(AutofillPlugin());
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getAutofillHints") {
            val intent = activity?.intent

            if (intent != null && intent.hasExtra(PassboltAutofillService.INTENT_EXTRAS_DATASET)) {
                result.success(intent.getSerializableExtra(PassboltAutofillService.INTENT_EXTRAS_DATASET))
            } else {
                result.success(null)
            }
        } else if (call.method == "setAutofillValues") {
            val request = call.argument<HashMap<Any, Any>>("request")
            Log.v(TAG, "setAutofillValues request ${request.toString()}")

            if (request != null) {
                val intent = activity?.intent ?: return

                if (intent.hasExtra(PassboltAccessibilityService.INTENT_EXTRAS_MESSAGE_RECEIVER)) {
                    activity?.apply {
                        val messageReceiver =
                            intent.getParcelableExtra<ResultReceiver>(PassboltAccessibilityService.INTENT_EXTRAS_MESSAGE_RECEIVER)
                        val message = Bundle()

                        val gson = Gson()

                        message.putString(
                            PassboltAccessibilityService.INTENT_EXTRAS_APP_MESSAGE,
                            gson.toJson(request)
                        )
                        messageReceiver.send(RESULT_OK, message)
                        finish()
                    }
                } else {
                    val fillResponseBuilder = FillResponse.Builder()
                    activity?.apply {
                        val packageName = this.applicationContext.packageName

                        val datasets = request["datasets"] as? List<*>

                        if (datasets != null && datasets.isNotEmpty()) {
                            datasets.forEach {
                                val datasetData = it as HashMap<*, *>
                                val hints = datasetData["values"] as? List<*>

                                if (hints != null && hints.isNotEmpty()) {
                                    val datasetBuilder = Dataset.Builder()

                                    hints.forEach {
                                        val hintData = it as HashMap<*, *>
                                        val hint = hintData["hint"] as String
                                        val valueForHint = hintData["valueForHint"] as String
                                        val labelForHint = hintData["labelForHint"] as String
                                        val autofillIdData = hintData["autofillId"] as String

                                        Log.v(
                                            TAG,
                                            "setAutofillValues hint: ${hint}, valueForHint: ${valueForHint}, labelForHint: ${labelForHint}, autofillIdData: $autofillIdData"
                                        )

                                        val autofillIds =
                                            intent.getParcelableArrayExtra(PassboltAutofillService.INTENT_EXTRAS_AUTOFILLIDS)
                                        val autofillId = autofillIds.first { parcelable ->
                                            (parcelable as AutofillId).toString() == autofillIdData
                                        }

                                        Log.v(TAG, "setAutofillValues autofillId $autofillId")

                                        val presentation = if (labelForHint.isEmpty()) {
                                            RemoteViews(packageName, R.layout.no_data).apply {
                                                setTextViewText(
                                                    R.id.label,
                                                    valueForHint
                                                )
                                            }
                                        } else {
                                            RemoteViews(
                                                packageName,
                                                R.layout.value_with_label
                                            ).apply {
                                                setTextViewText(
                                                    R.id.hintValue,
                                                    if (hint.contains("password")) {
                                                        "password"
                                                    } else {
                                                        valueForHint
                                                    }
                                                )
                                                setTextViewText(R.id.hintLabel, labelForHint)
                                            }
                                        }

                                        Log.v(TAG, "setAutofillValues presentation $presentation")

                                        datasetBuilder.setValue(
                                            autofillId as AutofillId,
                                            AutofillValue.forText(
                                                if (labelForHint.isEmpty()) {
                                                    null
                                                } else {
                                                    valueForHint
                                                }
                                            ),
                                            presentation
                                        )
                                    }

                                    fillResponseBuilder.addDataset(datasetBuilder.build())
                                    Log.v(TAG, "setAutofillValues dataset added")
                                }
                            }

                            val fillResponse: FillResponse = fillResponseBuilder.build()

                            val replyIntent = Intent().apply {
                                putExtra(EXTRA_AUTHENTICATION_RESULT, fillResponse)
                            }

                            Log.v(TAG, "setAutofillValues setResult")

                            setResult(Activity.RESULT_OK, replyIntent)
                            Log.v(TAG, "setAutofillValues complete")
                        } else {
                            Log.v(TAG, "setAutofillValues dataset is null or empty")
                        }

                        finish()
                    }
                }


            } else {
                Log.v(TAG, "setAutofillValues request is null")
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
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
