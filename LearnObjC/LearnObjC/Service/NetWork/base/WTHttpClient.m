//
//  WTHttpClient.m
//  TravelWorld
//
//  Created by mac on 2017/9/28.
//  Copyright © 2017年 JackyZhou. All rights reserved.
//

#import "WTHttpClient.h"
typedef void (^RequestSuccessBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
typedef void (^RequestFailBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);
/**
 *请求超时时间
 */
#define RQUEST_TIME_OUT 40
@implementation WTHttpClient

/**
 *  WTHttpClient单例初始化
 *  @return 单例
 */

+ (WTHttpClient *)sharedInstance
{
    static WTHttpClient *httpClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        //设置我们的缓存大小 其中内存缓存大小设置10M  磁盘缓存5M
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                          diskCapacity:50 * 1024 * 1024
                                                              diskPath:nil];
        [config setURLCache:cache];
        httpClient = [[WTHttpClient alloc] initWithBaseURL:nil
                                    sessionConfiguration:config];
        [httpClient.requestSerializer setTimeoutInterval:RQUEST_TIME_OUT];
        httpClient.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return httpClient;
}


/**
 *  普通网络请求
 *
 *  @param method 请求方式 GET POST PUT DELETE等等
 *  @param url 请求地址
 *  @param parameters 请求参数
 *  @param completion 回调
 *  @return 返回任务
 */
- (NSURLSessionDataTask *)requestWithMethod:(NSString *)method Headers:(NSDictionary *)header UrlString:(NSString *)url Parameters:(id)parameters completion:(void(^)(id result, NSError *error))completion
{
    //成功block
    RequestSuccessBlock requestSuccessBlock = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse.statusCode == 200) {
            dispatch_main_async_safe(^{
                completion(responseObject, nil);
            });
        } else {
            dispatch_main_async_safe(^{
                completion(nil, nil);
            });
        }
    };
    //失败block
     RequestFailBlock requestFailBlock = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
         dispatch_main_async_safe(^{
             completion(nil, error);
         });
     };
    if ([method isEqualToString:@"GET"]) {
        NSURLSessionDataTask *task = [self GET:url parameters:parameters headers:header progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:requestSuccessBlock failure:requestFailBlock];
        return task;
    }
    
    else if([method isEqualToString:@"POST"])
    {
         NSURLSessionDataTask *task = [self POST:url parameters:parameters headers:header progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:requestSuccessBlock failure:requestFailBlock];
        return task;
    }
    
    else if([method isEqualToString:@"PUT"])
    {
        NSURLSessionDataTask *task = [self PUT:url parameters:parameters headers:header success:requestSuccessBlock failure:requestFailBlock];
        return task;
    }
    
    else if([method isEqualToString:@"DELETE"])
    {
        NSURLSessionDataTask *task = [self DELETE:url parameters:parameters headers:header success:requestSuccessBlock failure:requestFailBlock];
        return task;
    }
    else {
        return nil;
    }
}
/**
 *  图片上传-多图
 *
 *  @param url 请求地址
 *  @param parameters 请求参数
 *  @param imageDatas 图片data数组
 *  @param imagesNames 图片名参数数组
 *  @param completion 回调
 *  @return 返回任务
 */
- (NSURLSessionDataTask *)uploadImageRequest:(NSString *)url Headers:(NSDictionary *)header Parameters:(id)parameters ImageDatas:(NSArray *)imageDatas ImagesNames:(NSArray *)imagesNames completion:(void(^)(id result, NSError *error))completion
{
    NSURLSessionDataTask *task = [self POST:url parameters:parameters headers:header constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (imageDatas.count > 0) {
            for (int i = 0; i<imageDatas.count; i++) {
                [formData appendPartWithFileData:imageDatas[i]
                                            name:imagesNames[i]
                                        fileName:@"image.jpg"
                                        mimeType:@"image/jpeg"];
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse.statusCode == 200) {
            dispatch_main_async_safe(^{
                completion(responseObject, nil);
            });
        } else {
            dispatch_main_async_safe(^{
                completion(nil, nil);
            });
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
    return task;
}
/**
 *  文件上传
 *
 *  @param url 请求地址
 *  @param parameters 请求参数
 *  @param fileData 文件data
 *  @param progress 回调
 *  @return 返回任务
 */
- (NSURLSessionDataTask *)uploadFileRequest:(NSString *)url Headers:(NSDictionary *)header Parameters:(id)parameters
                                 fileData:(NSData *)fileData
                                 fileName:(NSString *)fileName
                                 mimeType:(NSString *)mimeType
                                 progress:(void(^)(NSProgress * _Nonnull uploadProgress))progress
                                 completion:(void(^)(id result, NSError *error))completion
{
    NSURLSessionDataTask *task = [self POST:url  parameters:parameters headers:header constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData :fileData name:@"file" fileName:fileName mimeType:mimeType];
    
    } progress:^(NSProgress * _Nonnull uploadProgress) {
       
        progress(uploadProgress);
    
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse.statusCode == 200) {
            dispatch_main_async_safe(^{
                completion(responseObject, nil);
            });
        } else {
            dispatch_main_async_safe(^{
                completion(nil, nil);
            });
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
    
    return task;
}

@end
