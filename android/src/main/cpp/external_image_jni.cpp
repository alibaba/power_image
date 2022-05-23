#include <jni.h>
#include <android/bitmap.h>
#include <android/log.h>

#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, "power_image_jni", __VA_ARGS__)

extern "C" JNIEXPORT jlong JNICALL
Java_com_taobao_power_1image_request_PowerImageExternalRequest_getByteBufferPtr(
        JNIEnv* env,
        jobject clazz,
        jobject byte_buffer) {
    jbyte *cData = (jbyte*)env->GetDirectBufferAddress(byte_buffer);//获取指针
    return (jlong)cData;
}

extern "C" JNIEXPORT jlong JNICALL
Java_com_taobao_power_1image_request_PowerImageExternalRequest_getBitmapPixelsPtr(
        JNIEnv* env,
        jobject clazz,
        jobject bitmap) {
    void *addrPtr;
    int ret = AndroidBitmap_lockPixels(env, bitmap, &addrPtr);
    if (ret < 0) {
        LOGE("AndroidBitmap_lockPixels failed : %d", ret);
        return 0;
    }
    return (jlong)addrPtr;
}

extern "C" JNIEXPORT void JNICALL
Java_com_taobao_power_1image_request_PowerImageExternalRequest_releaseBitmapPixels(
        JNIEnv* env,
        jobject clazz,
        jobject bitmap) {
    int ret = AndroidBitmap_unlockPixels(env,bitmap);
    if (ret < 0) {
        LOGE("AndroidBitmap_unlockPixels failed : %d", ret);
    }
}