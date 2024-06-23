package com.example.trainerproject

import android.content.Context
import android.graphics.Bitmap
import com.google.mediapipe.framework.image.BitmapExtractor
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.imagegenerator.ImageGenerator
import com.google.mediapipe.tasks.vision.imagegenerator.ImageGenerator.ConditionOptions
import com.google.mediapipe.tasks.vision.imagegenerator.ImageGenerator.ConditionOptions.ConditionType
import com.google.mediapipe.tasks.vision.imagegenerator.ImageGenerator.ConditionOptions.EdgeConditionOptions


class ImageGenerationHelper(val context: Context) {

    lateinit var imageGenerator: ImageGenerator


    fun initializeImageGeneratorWithEdgePlugin(modelPath: String) {
        val options = ImageGenerator.ImageGeneratorOptions.builder()
            .setImageGeneratorModelDirectory(modelPath)
            .build()

        val edgePluginModelBaseOptions = BaseOptions.builder()
            .setModelAssetPath("/data/local/tmp/image_generator/canny_edge_plugin.tflite")
            .build()

        val edgeConditionOptions = EdgeConditionOptions.builder()
            .setThreshold1(100.0f) // default = 100.0f
            .setThreshold2(100.0f) // default = 100.0f
            .setApertureSize(3) // default = 3
            .setL2Gradient(false) // default = false
            .setPluginModelBaseOptions(edgePluginModelBaseOptions)
            .build()

        val conditionOptions = ConditionOptions.builder()
            .setEdgeConditionOptions(edgeConditionOptions)
            .build()

        imageGenerator =
            ImageGenerator.createFromOptions(context, options, conditionOptions)
    }

    fun generate(
        prompt: String,
        inputImage: MPImage,
        conditionType: ConditionType,
        iteration: Int,
        seed: Int
    ): Bitmap {
        val result = imageGenerator.generate(
            prompt,
            inputImage,
            conditionType,
            iteration,
            seed
        )
        val bitmap = BitmapExtractor.extract(result?.generatedImage())
        return bitmap
    }

    fun close() {
        try {
            imageGenerator.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


//    fun generateImage(prompt: String, conditionType: ConditionType, iteration: Int, seed: Int, inputImage: Bitmap) {
//        val result = generate(
//            prompt,
//            BitmapImageBuilder(inputImage).build(),
//            conditionType,
//            iteration,
//            seed
//        )
//    }


}