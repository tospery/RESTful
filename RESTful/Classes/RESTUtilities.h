//
//  RESTUtilities.h
//  RESTful
//
//  Created by 杨建祥 on 2020/2/7.
//

#define REST_USING_XCODE_7 __has_feature(objc_generics)

#pragma mark - C++ Support

#ifdef __cplusplus
    #define REST_EXTERN extern "C"
#else
    #define REST_EXTERN extern
#endif

#pragma mark - Objective-C Nullability Support

#if __has_feature(nullability)
    #define REST_NONNULL nonnull
    #define REST_NULLABLE nullable
    #define REST_NULL_RESETTABLE null_resettable
    #if REST_USING_XCODE_7
        #define REST__NONNULL _Nonnull
        #define REST__NULLABLE _Nullable
        #define REST__NULL_RESETTABLE _Null_resettable
    #else
        #define REST__NONNULL __nonnull
        #define REST__NULLABLE __nullable
        #define REST__NULL_RESETTABLE __null_resettable
    #endif
#else
    #define REST_NONNULL
    #define REST__NONNULL
    #define REST_NULLABLE
    #define REST__NULLABLE
    #define REST_NULL_RESETTABLE
    #define REST__NULL_RESETTABLE
#endif

#if __has_feature(assume_nonnull)
    #ifndef NS_ASSUME_NONNULL_BEGIN
        #define NS_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
    #endif
    #ifndef NS_ASSUME_NONNULL_END
        #define NS_ASSUME_NONNULL_END _Pragma("clang assume_nonnull end")
    #endif
#else
    #define NS_ASSUME_NONNULL_BEGIN
    #define NS_ASSUME_NONNULL_END
#endif

#pragma mark - Objective-C Lightweight Generics Support

#if __has_feature(objc_generics)
    #define RESTGenerics(...) <__VA_ARGS__>
    #define RESTGenericType(TYPE, FALLBACK) TYPE
#else
    #define RESTGenerics(...)
    #define RESTGenericType(TYPE, FALLBACK) FALLBACK
#endif

#pragma mark - Designated Initailizer Support

#ifndef NS_DESIGNATED_INITIALIZER
    #if __has_attribute(objc_designated_initializer)
        #define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
    #else
        #define NS_DESIGNATED_INITIALIZER
    #endif
#endif

#pragma mark - Deprecation

#define REST_DEPRECATED(...) __attribute__((deprecated(__VA_ARGS__)))

#pragma mark - Helpers

#define REST_IS_CLASS(obj) (class_isMetaClass(object_getClass((obj))) != 0)
