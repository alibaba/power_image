package com.alibaba.power_image_example_kotlin_swift.example_kotlin_swift.power_image_loader

import android.content.Context
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.load.resource.gif.GifDrawable
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.target.Target
import com.taobao.power_image.loader.PowerImageLoaderProtocol
import com.taobao.power_image.loader.PowerImageLoaderProtocol.PowerImageResponse
import com.taobao.power_image.loader.PowerImageResult
import com.taobao.power_image.request.PowerImageRequestConfig
import com.taobao.power_image_example.GlideMultiFrameImage
import com.taobao.power_image.loader.FlutterSingleFrameImage


class PowerImageNetworkLoader(private val context: Context) : PowerImageLoaderProtocol {
    override fun handleRequest(request: PowerImageRequestConfig, response: PowerImageResponse) {
        Glide.with(context).asDrawable().load(request.srcString())
            .listener(object : RequestListener<Drawable> {
                override fun onLoadFailed(
                    e: GlideException?,
                    model: Any,
                    target: Target<Drawable>,
                    isFirstResource: Boolean
                ): Boolean {
                    response.onResult(PowerImageResult.genFailRet("Native加载失败: " + if (e != null) e.message else "null"))
                    return true
                }

                override fun onResourceReady(
                    resource: Drawable,
                    model: Any,
                    target: Target<Drawable>,
                    dataSource: DataSource,
                    isFirstResource: Boolean
                ): Boolean {
                    if (resource is GifDrawable) {
                        response.onResult(
                            PowerImageResult.genSucRet(
                                GlideMultiFrameImage(
                                    resource as GifDrawable,
                                    false
                                )
                            )
                        )
                    } else {
                        if (resource is BitmapDrawable) {
                            response.onResult(
                                PowerImageResult.genSucRet(
                                    FlutterSingleFrameImage(
                                        resource as BitmapDrawable
                                    )
                                )
                            )
                        } else {
                            response.onResult(PowerImageResult.genFailRet("Native加载失败:  resource : $resource"))
                        }
                    }
                    return true
                }
            }).submit(
                if (request.width <= 0) Target.SIZE_ORIGINAL else request.width,
                if (request.height <= 0) Target.SIZE_ORIGINAL else request.height
            )
    }
}
