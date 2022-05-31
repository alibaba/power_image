package com.alibaba.power_image_example_kotlin_swift.example_kotlin_swift.power_image_loader

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.target.Target
import com.taobao.power_image.request.PowerImageRequestConfig
import com.taobao.power_image.loader.PowerImageLoaderProtocol
import com.taobao.power_image.loader.PowerImageLoaderProtocol.PowerImageResponse
import com.taobao.power_image.loader.PowerImageResult

class PowerImageFileLoader(private val context: Context) : PowerImageLoaderProtocol {
    override fun handleRequest(request: PowerImageRequestConfig, response: PowerImageResponse) {
        val name = request.srcString()
        if (name == null || name.length <= 0) {
            response.onResult(PowerImageResult.genFailRet("src 为空"))
            return
        }
        val asset = Uri.parse("file://$name")
        Glide.with(context).asBitmap().load(asset).listener(object : RequestListener<Bitmap?> {
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
