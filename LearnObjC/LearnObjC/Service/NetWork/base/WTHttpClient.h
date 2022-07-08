//
//  WTHttpClient.h
//  TravelWorld
//
//  Created by mac on 2017/9/28.
//  Copyright © 2017年 JackyZhou. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface WTHttpClient : AFHTTPSessionManager

/**
 *  WTHttpClient单例初始化
 *  @return 单例
 */

+ (WTHttpClient *)sharedInstance;
/**
 *  网络请求
 *
 *  @param method 请求方式 GET POST PUT DELETE等等
 *  @param url 请求地址
 *  @param parameters 请求参数
 *  @param completion 回调
 *  @return 返回任务
 */
- (NSURLSessionDataTask *)requestWithMethod:(NSString *)method Headers:(NSDictionary *)header UrlString:(NSString *)url Parameters:(id)parameters completion:(void(^)(id result, NSError *error))completion;

/**
 *  图片上传
 *
 *  @param url 请求地址
 *  @param parameters 请求参数
 *  @param imageDatas 图片data数组
 *  @param imagesNames 图片名参数数组
 *  @param completion 回调
 *  @return 返回任务
 */
- (NSURLSessionDataTask *)uploadImageRequest:(NSString *)url Headers:(NSDictionary *)header Parameters:(id)parameters ImageDatas:(NSArray *)imageDatas ImagesNames:(NSArray *)imagesNames completion:(void(^)(id result, NSError *error))completion;
/**
 *
 *
 *  @param url 请求地址
 *  @param parameters 请求参数
 *  @param fileData 文件data
 *  @param fileName 文件参数名
 *  @param completion 回调
 *  @return 返回任务
 */
- (NSURLSessionDataTask *)uploadFileRequest:(NSString *)url Headers:(NSDictionary *)header Parameters:(id)parameters
                                   fileData:(NSData *)fileData
                                   fileName:(NSString *)fileName
                                   mimeType:(NSString *)mimeType
                                   progress:(void(^)(NSProgress * _Nonnull uploadProgress))progress
                                   completion:(void(^)(id result, NSError *error))completion;
@end
