package com.taobao.power_image.utils;

/**
 * created by Muke on 2021/7/21
 */
public class CastUtil {
    private CastUtil(){}

    public static <T> T get(Object value, Class<T> type) {
        if (type.isInstance(value)) {
            return type.cast(value);
        }
        throw new ClassCastException(type.getName() + " is required, but value is " + value.getClass().getName());
    }

    public static void test() {
        System.out.println('h');
    }
}
