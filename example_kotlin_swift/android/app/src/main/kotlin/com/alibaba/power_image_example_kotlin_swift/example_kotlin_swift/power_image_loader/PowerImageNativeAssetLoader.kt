package com.alibaba.power_image_example_kotlin_swift.example_kotlin_swift.power_image_loader

import android.content.Context
import android.content.res.Resources
import android.graphics.Bitmap
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.target.Target
import com.taobao.power_image.loader.PowerImageLoaderProtocol
import com.taobao.power_image.loader.PowerImageLoaderProtocol.PowerImageResponse
import com.taobao.power_image.loader.PowerImageResult
import com.taobao.power_image.request.PowerImageRequestConfig

class PowerImageNativeAssetLoader(private val context: Context) : PowerImageLoaderProtocol {
    override fun handleRequest(request: PowerImageRequestConfig, response: PowerImageResponse) {
        val resources = context.resources
        var resourceId = 0
        try {
            resourceId = resources.getIdentifier(
                request.srcString(),
                "drawable", context.packageName
            )
        } catch (e: Resources.NotFoundException) {
            // 资源未找到
            e.printStackTrace()
        }
        if (resourceId == 0) {
            response.onResult(PowerImageResult.genFailRet("资源未找到"))
            return
        }
        Glide.with(context).asBitmap().load(resourceId).listener(object : RequestListener<Bitmap?> {
            override fun onLoadFailed(
                e: GlideException?,
                model: Any,
                target: Target<Bitmap?>,
                isFirstResource: Boolean
            ): Boolean {
                response.onResult(PowerImageResult.genFailRet("Native加载失败: " + if (e != null) e.message else "null"))
                return true
            }

            override fun onResourceReady(
                resource: Bitmap?,
                model: Any,
                target: Target<Bitmap?>,
                dataSource: DataSource,
                isFirstResource: Boolean
            ): Boolean {
                response.onResult(PowerImageResult.genSucRet(resource))
                return true
            }
        }).submit(
            if (request.width <= 0) Target.SIZE_ORIGINAL else request.width,
            if (request.height <= 0) Target.SIZE_ORIGINAL else request.height
        )
    }
}
