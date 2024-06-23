package com.example.trainerproject

import android.annotation.SuppressLint
import io.flutter.embedding.android.FlutterActivity

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import androidx.annotation.NonNull
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.vision.imagegenerator.ImageGenerator
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.native_interaction/image"

    @SuppressLint("WrongThread")
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getImage") {
                val text = call.argument<String>("text")
                val imageBytes = call.argument<ByteArray>("image")
                if (text != null && imageBytes != null) {
                    val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                    // Process Start
                    val processedBitmap = processImage(text, bitmap)
                    // Process End
                    val stream = ByteArrayOutputStream()
                    processedBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                    val byteArray = stream.toByteArray()
                    result.success(byteArray)
                } else {
                    result.error("INVALID_ARGUMENTS", "Text or image is null", null)
                }
            } else {
                result.notImplemented()
            }
        }


    }
    fun processImage(text: String, bitmap: Bitmap): Bitmap {
        // Example processing: draw text over the image
        val helper = ImageGenerationHelper(context)
        val modelPath = "/data/local/tmp/image_generator/bins/"
        helper.initializeImageGeneratorWithEdgePlugin(modelPath)
        val processedBitmap = helper.generate(text!!, BitmapImageBuilder(bitmap).build(), ImageGenerator.ConditionOptions.ConditionType.EDGE, 20, 0 )
        helper.close()
        return processedBitmap
    }
}

