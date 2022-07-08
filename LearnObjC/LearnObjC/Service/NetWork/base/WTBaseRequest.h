//
//  WTBaseRequest.h
//  TravelWorld
//
//  Created by mac on 2017/9/28.
//  Copyright © 2017年 JackyZhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTHttpClient.h"
#define HTTP_GET_Request     @"GET"
#define HTTP_POST_Request    @"POST"
#define HTTP_PUT_Request     @"PUT"
#define HTTP_DELETE_Request  @"DELETE"

typedef void(^RequestResultBlock)(id response,NSString *errStr, int state);

@interface WTBaseRequest : NSObject

/**
 * 服务器地址 必传
 */
@property(nonatomic,strong)NSString *host;
/**
 * 接口名 必传
 */
@property(nonatomic,strong)NSString *actionKey;
/**
 * 请求方法 GET POST 必传
 */
@property(nonatomic,strong)NSString *requestMethod;

@property(nonatomic, strong)NSString *contentType;
/**
 * 请求参数
 */
@property (nonatomic,strong)NSMutableDictionary *agrs;
/**
 * 请求参数 非字典类型
 */
@property (nonatomic,strong)id parameters;
/**
 * 是否需要userId
 */
@property (nonatomic,assign)BOOL needUserId;

/**
 * token验证失败未登录时，是否拦截不弹出loginVC,    NO: 需要验证，YES：token验证失败也不弹出loginVC
 */
@property (nonatomic,assign)BOOL isNotNeedTokenLegalShowLoginVC;
/**
 * 请求数据回调block 必传
 */
@property (nonatomic,strong)RequestResultBlock callBackBlock;

/**
 *  多图上传 ，单图时数组内传一个元素
 *  @param imageDatas 图片data数组
 *  @param names 图片名参数数组
 *  @param block 回调
 */
- (void)startUploadImage:(NSArray *)imageDatas names:(NSArray *)names requestBlock:(RequestResultBlock)block;

/**
 *  文件上传
 *  @param fileData data
 *  @param block 回调
 */
- (void)startUploadFile:(NSData *)fileData fileName:(NSString *)fileName mimeType:(NSString *)mimeType progress:(void(^)(NSProgress * _Nonnull uploadProgress))progress requestBlock:(RequestResultBlock)block;

/**
 *开始请求
 *@param block 请求数据回调block
 */
- (void)startUserCenterRequest:(RequestResultBlock)block;
- (void)startRequestWithBody:(RequestResultBlock)block;
/**
 *  取消请求
 */
- (void)cancelRequest;
/**
 *  挂起请求
 */
- (void)suspendRequest;
/**
 *  继续请求
 */
- (void)resumeRequest;

@end

