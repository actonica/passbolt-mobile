package com.actonica.autofill

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.ImageView
import java.util.HashMap

class PassboltAccessibilityService : AccessibilityService() {
    companion object {
        const val TAG: String = "PassboltAccessibilityService"
        const val INTENT_EXTRAS_MESSAGE_RECEIVER: String = "PassboltAccessibilityServiceKeyReceiver"
        const val INTENT_EXTRAS_APP_MESSAGE: String = "PassboltAccessibilityServiceKeyMessage"
    }

    private var autofillIdPackage: String? = null
    private var autofillWebDomain: String? = null
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var fields: Map<String, AccessibilityNodeInfo>
    private var isInvocationViewOnScreen: Boolean = false
    private lateinit var invocationViewLayout: FrameLayout

    override fun onServiceConnected() {
        Log.d(TAG, "onServiceConntected")
    }

    override fun onInterrupt() {
        Log.d(TAG, "onInterrupt")
        hideInvocationView()
    }

    override fun onDestroy() {
        super.onDestroy()
        hideInvocationView()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        val eventDescription = event.toString()
        if (!eventDescription.contains("EditText")) return
        Log.d(TAG, "onAccessibilityEvent $event")

        event.source?.let {
            val rootNodeInfo = findRootNodeInfo(it)

            rootNodeInfo?.let {
                fields = getAutofillableNodes(rootNodeInfo)
                Log.d(TAG, "fields ${fields.keys}")

                if (fields.isNotEmpty()) {
                    val windowManager = getSystemService(
                        WINDOW_SERVICE
                    ) as WindowManager

                    val layoutParams = WindowManager.LayoutParams()
                    layoutParams.type = WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY
                    layoutParams.format = PixelFormat.TRANSLUCENT
                    layoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                    layoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT
                    layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT
                    layoutParams.gravity = Gravity.CENTER

                    if (!this::invocationViewLayout.isInitialized) {
                        invocationViewLayout = FrameLayout(this)

                        val layoutInflater = LayoutInflater.from(this)
                        layoutInflater.inflate(
                            R.layout.accessibility_autofill_invocation,
                            invocationViewLayout
                        )

                        val image =
                            invocationViewLayout.findViewById<ImageView>(R.id.imageInvocation)
                        image.setImageResource(R.mipmap.ic_launcher)

                        val buttonStart =
                            invocationViewLayout.findViewById<Button>(R.id.buttonStart)
                        buttonStart.text = "Autofill with Passbolt"
                        buttonStart.setOnClickListener {
                            Log.d(TAG, "Start autofill")

                            val autoFillHints = hashMapOf<String, Any>()

                            autofillIdPackage?.let {
                                autoFillHints["autofillIdPackage"] = it
                            }

                            autofillWebDomain?.let {
                                autoFillHints["autofillWebDomain"] = it
                            }

                            val hintsList = mutableListOf<HashMap<String, String>>()

                            fields.forEach { (hint: String, nodeInfo: AccessibilityNodeInfo) ->
                                val hintMap = hashMapOf<String, String>()
                                hintMap["hint"] = hint
                                hintMap["autofillId"] = hint

                                Log.v(
                                    PassboltAutofillService.TAG,
                                    "autofillHint hint: $hint, nodeInfo: $nodeInfo"
                                )

                                hintsList.add(hintMap)
                            }

                            autoFillHints["hints"] = hintsList

                            val authIntent =
                                Intent(this, Class.forName("com.actonica.passbolt.MainActivity"))
                            authIntent.putExtra(
                                PassboltAutofillService.INTENT_EXTRAS_DATASET,
                                autoFillHints
                            )
                            authIntent.putExtra(
                                PassboltAccessibilityService.INTENT_EXTRAS_MESSAGE_RECEIVER,
                                MessageReceiver(this, handler)
                            )
                            authIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK

                            startActivity(authIntent)
                            hideInvocationView()
                        }
                        val buttonCancel =
                            invocationViewLayout.findViewById<ImageButton>(R.id.buttonCancel)
                        buttonCancel.setOnClickListener {
                            Log.d(TAG, "Cancel autofill")
                            hideInvocationView()
                        }
                    }

                    if (!isInvocationViewOnScreen) {
                        windowManager.addView(invocationViewLayout, layoutParams)
                        isInvocationViewOnScreen = true

                        handler.postDelayed({
                                                hideInvocationView()
                                            }, 8000)
                    }
                }
            }
        }
    }

    fun performPaste(datasets: AutofillDatasets) {
        if (datasets.datasets.isNotEmpty()) {

            handler.postDelayed(
                {
                    val autofillDataset = datasets.datasets.first()
                    autofillDataset.values.forEach { autofillValue ->
                        val nodeInfo = fields[autofillValue.hint]
                        nodeInfo?.let {
                            Log.d(
                                PassboltAccessibilityService.TAG,
                                "try paste to ${autofillValue.hint}/${autofillValue.autofillId}/$nodeInfo"
                            )
                            val arguments = Bundle()
                            arguments.putString(
                                AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE,
                                autofillValue.valueForHint
                            )

                            val result =
                                nodeInfo.performAction(
                                    AccessibilityNodeInfo.ACTION_SET_TEXT,
                                    arguments
                                )
                            Log.d(
                                PassboltAccessibilityService.TAG,
                                "paste result ${autofillValue.labelForHint}: $result"
                            )
                        }
                    }
                }, 1000
            )
        }
    }

    private fun hideInvocationView() {
        if (isInvocationViewOnScreen) {
            val windowManager = getSystemService(
                WINDOW_SERVICE
            ) as WindowManager
            windowManager.removeView(invocationViewLayout)
            isInvocationViewOnScreen = false
            handler.removeCallbacksAndMessages(null)
        }
    }

    private fun findRootNodeInfo(nodeInfo: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        val parent = nodeInfo.parent

        return if (parent != null) {
            findRootNodeInfo(parent)
        } else {
            nodeInfo
        }
    }

    private fun getAutofillableNodes(rootNodeInfo: AccessibilityNodeInfo): MutableMap<String, AccessibilityNodeInfo> {
        val fields = mutableMapOf<String, AccessibilityNodeInfo>()
        val childCount = rootNodeInfo.childCount
        for (i in 0 until childCount) {
            val nodeInfo = rootNodeInfo.getChild(i)
            addAutofillableFieldsWithHints(fields, nodeInfo)
        }

        return fields
    }

    private fun addAutofillableFieldsWithHints(
        fields: MutableMap<String, AccessibilityNodeInfo>,
        node: AccessibilityNodeInfo
    ) {
        Log.v(
            PassboltAccessibilityService.TAG,
            "viewNode package ${node.packageName} domain null"
        )

        if (this.autofillIdPackage == null && node.packageName != null) {
            this.autofillIdPackage = node.packageName.toString()
        }

        this.autofillWebDomain = null

        val hint: String? = HintFinder.getHint(
            null,
            node.inputType,
            node.hintText?.toString(),
            node.text?.toString(),
            node.className?.toString(),
            node.viewIdResourceName
        )
        if (hint != null) {
            if (!fields.containsKey(hint) && node.className.toString().contains("EditText")) {
                Log.v(PassboltAccessibilityService.TAG, "Setting hint '$hint' on $node")
                fields[hint] = node
            } else {
                Log.v(
                    PassboltAccessibilityService.TAG,
                    "Ignoring hint '" + hint + "' on $node"
                            + " because it was already set"
                )
            }
        }
        val childrenSize = node.childCount
        for (i in 0 until childrenSize) {
            val child = node.getChild(i)
            child?.let {
                addAutofillableFieldsWithHints(fields, child)
            }
        }
    }

}