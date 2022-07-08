//
//  WTApiInterface.m
//  TravelWorld
//
//  Created by mac on 2017/9/28.
//  Copyright © 2017年 JackyZhou. All rights reserved.
//

#import "WTApiInterface.h"
#import "WTPUSHService.h"

@implementation WTApiInterface

#pragma mark--版本更新
+(void)versionUpdateFinishblock:(RequestResultBlock)finishblock
{
    WTBaseRequest * request = [[WTBaseRequest alloc] init];
    request.host = HOSTAPP;//appRenew/check/{type}/{number}
    int type = 1;///type 安装包类型 0安卓，1ios
    request.actionKey = [NSString stringWithFormat:@"appRenew/check/%d", 1];
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs setObject:@(type) forKey:@"type"];
    [request startUserCenterRequest:finishblock];
}

/** **************登录模块*************/
#pragma mark--发送验证码
//发送验证码 0验证码登录
+ (void)sendMobileCode:(NSString *)mobile Type:(NSInteger)type andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTUSER;
    request.contentType = @"application/x-www-form-urlencoded";
    request.requestMethod = HTTP_POST_Request;
    request.actionKey = @"sms/sendCode";
    [request.agrs setObject:mobile forKey:@"mobile"];
    if (type==0) {//短信标识： 注册登录：login  ；注销：logout
        [request.agrs setObject:@"login" forKey:@"distinguish"];
    }else if(type==1){
        [request.agrs setObject:@"logout" forKey:@"distinguish"];
    }
    
    [request startUserCenterRequest:finishblock];
}

#pragma mark--快捷登录
+ (void)speedLoginWith:(NSDictionary *)parames andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTUSER;
    request.actionKey = @"login/mobileLogin";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/x-www-form-urlencoded";
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:parames];
    NSString *registrationId = [WTPUSHService registrationID];
    BOOL hasRegistrationId = registrationId && [registrationId isNotBlank];
    if (hasRegistrationId) {
        [dict setObject:registrationId forKey:@"registrationId"];
    }
    [request.agrs addEntriesFromDictionary:dict];
    [request startUserCenterRequest:^(id response, NSString *errStr, int state) {
        if (state==0 && hasRegistrationId) {
            [[WTPUSHService shared] loginSuccessWithReistrationId: registrationId];
        }
        finishblock(response, errStr, state);
    }];
}

#pragma mark--退出登录
+ (void)loginQuit:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTUSER;
    request.actionKey = @"login/quit";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/x-www-form-urlencoded";
    [request startUserCenterRequest:finishblock];
}

/****************个人模块*************/


#pragma mark--注销账号
+ (void)accountLogoutWith:(NSDictionary *)par andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTUSER;
    request.actionKey = @"userinfo/logout";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/x-www-form-urlencoded";
    [request.agrs addEntriesFromDictionary:par];
    [request startUserCenterRequest:finishblock];
}


#pragma mark--修改头像
+(void)updateHeadWith:(UIImage *)head andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTUSER;
    request.actionKey = @"userinfo/updateUserImage";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/x-www-form-urlencoded";
    request.needUserId=YES;
    NSMutableArray *datas = [[NSMutableArray alloc] initWithCapacity:1];
    [datas addObject:UIImageJPEGRepresentation(head, 0.1)];
    [request startUploadImage:datas names:@[@"file"] requestBlock:^(id response, NSString *errStr, int state) {
        if (errStr) {
            finishblock(response,errStr, state);
        }else{
            finishblock(response,nil, state);
        }
    }];
}

#pragma mark--修改个人资料
+(void)updateInformationWith:(NSDictionary *)dict
              andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTUSER;
    request.actionKey = @"userinfo/updateUser";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/x-www-form-urlencoded";
    [request.agrs addEntriesFromDictionary:dict];
    request.needUserId=YES;
    [request startUserCenterRequest:finishblock];
}

#pragma mark - 获取用户信息
+ (void)getUserInfoWithNeedLogin: (BOOL)isNeedLogin finishblock: (RequestResultBlock)block{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTUSER;
    request.actionKey = @"userinfo/queryUser";
    request.requestMethod = HTTP_POST_Request;
    request.isNotNeedTokenLegalShowLoginVC = YES;
    [request startUserCenterRequest:block];
}

#pragma mark --我的二维码 --- 
+ (void)getUserQrCode:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTAPP;
    request.actionKey = @"userinfo/qrCode";///app/userinfo/qrCode
    request.requestMethod = HTTP_POST_Request;
    request.needUserId = YES;
    [request startRequestWithBody:finishblock];
}

+ (void)getUserQueryUserFigure:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTAPP;
    request.actionKey = @"userinfo/queryUserFigure";
    request.requestMethod = HTTP_POST_Request;
    request.needUserId = YES;
    request.contentType = @"application/json";
    [request startRequestWithBody:finishblock];
}

/** **************订单模块*************/
#pragma mark - 3D形象提交订单
+(void)cretat3DImageOrder:(NSDictionary *)dict
           andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc] init];
    request.host = HOSTORDER;
    request.actionKey = @"create";
    request.contentType = @"application/json";
    request.requestMethod = HTTP_POST_Request;
    [request.agrs addEntriesFromDictionary:dict];
    request.needUserId = YES;
    [request startRequestWithBody:finishblock];
}

#pragma mark--取消订单
+ (void)cancel3DImageOrder:(NSString *)orderId andFinishblock:(RequestResultBlock)finishblock
{
    WTBaseRequest * request = [[WTBaseRequest alloc] init];
    request.host = HOSTORDER;
    request.actionKey = @"cancel";
    request.contentType = @"application/json";
    request.requestMethod = HTTP_POST_Request;
    [request.agrs setObject:orderId forKey:@"id"];
    request.needUserId = YES;
    [request startRequestWithBody:finishblock];
}

#pragma mark--支付订单
+ (void)get3DImageOrderPaySign:(NSString *)orderId andPayChannel:(NSString *)payChannel andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc] init];
    request.host = HOSTORDER;
    request.actionKey = @"pay";
    request.contentType = @"application/json";
    request.requestMethod = HTTP_POST_Request;
    [request.agrs setObject:orderId forKey:@"id"];
    if ([payChannel isNotBlank]) {
        [request.agrs setObject:payChannel forKey:@"payChannel"];
    }
    request.needUserId = YES;
    [request startRequestWithBody:finishblock];
}


#pragma mark--3d订单列表
+ (void) get3DImageOrderList:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock
{
    WTBaseRequest * request = [[WTBaseRequest alloc] init];
    request.host = HOSTORDER;
    request.actionKey = @"list";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startRequestWithBody:finishblock];
}

#pragma mark--订单详情
+ (void)get3DImageOrderDetail:(NSString *)orderId andFinishblock:(RequestResultBlock)finishblock
{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTORDER;
    request.actionKey = @"detail";
    request.requestMethod = HTTP_POST_Request;
    [request.agrs setObject:orderId forKey:@"id"];
    [request startRequestWithBody:finishblock];
}

/** **************形象模块*************/
#pragma mark -- 获取高清形象的价格及名称信息
+ (void)get3DIamgePriceInfoAndFinishblock:(RequestResultBlock)finishblock
{
    WTBaseRequest * request = [[WTBaseRequest alloc] init];
    request.host = HOSTORDER;
    request.actionKey = @"product";
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request startUserCenterRequest:finishblock];
}

#pragma mark--获取我的3d形像接口 --
+(void)getMy3DImage:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTImage;
    request.actionKey = @"list";
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startUserCenterRequest:finishblock];
}

#pragma mark--  单个 获取我的3d形像 详情 接口 --
+(void)getMy3DImageDetailByID:(NSString *)modeId andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTImage;
    request.actionKey = [NSString stringWithFormat:@"detail/%@",modeId];
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:@{
        @"id":modeId,
    }];
    [request startUserCenterRequest:finishblock];
}
///** *************素材模块*************/
#pragma mark-- 单个 获取热门素材  详情 接口 --
+(void)getHotImageDetailByID:(NSString *)modeId andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTMaterial;
    request.actionKey = [NSString stringWithFormat:@"detail/%@",modeId];
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:@{
        @"id":modeId,
    }];
    [request startUserCenterRequest:finishblock];
}

/** *************模型数据模块*************/
#pragma mark-- 模型列表 接口 --
+(void)getModeListWithProductType:(int)productType andImageCellType:(WTCollectionImageCellType)cellType andDict:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock{
    if (cellType == kCollectionImageCellPreDefaultMy3DImage || cellType == kCollectionImageCellPreDefault3DImageTemp) {////预览 个人形象设置 : 我的3D形象/ 3D示例素材
        [WTApiInterface getUserInfoQueryFigureListWithResourceType:productType andDict:dict andFinishblock:finishblock];
        return;
    }
    
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    if (productType==kWT3DImageResourceTypeMyMode) {//我的3D形象
        [WTApiInterface getMy3DImage:dict andFinishblock:finishblock];
        return;
    }else if(productType==kWT3DImageResourceTypeMaterial){//3d素材
        request.host = HOSTMaterial;
        request.actionKey = @"showList";
    }else{//3D示例素材
        [WTApiInterface getUserInfoQueryFigureListWithResourceType:productType andDict:dict andFinishblock:finishblock];
        return;
    }
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    
    [request.agrs addEntriesFromDictionary:mDict];
    [request startUserCenterRequest:finishblock];
}


#pragma mark - 我的/示例形象列表
+(void)getUserInfoQueryFigureListWithResourceType:(int)resourceType andDict:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTAPP;
    request.actionKey = @"userinfo/queryFigureList";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/json";
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [mDict setObject:@(resourceType) forKey:@"resourceType"];
    [request.agrs addEntriesFromDictionary:mDict];
    [request startRequestWithBody:finishblock];
}

#pragma mark --我的/示例详情
+(void)queryFigureDetailWithResourceType:(int)resourceType andResourceId:(NSString *)resourceId andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTAPP;
    request.actionKey = @"userinfo/queryFigureDetail";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/json";
    NSDictionary *dict = @{
        @"resourceId": resourceId,
        @"resourceType": @(resourceType)
    };
    [request.agrs addEntriesFromDictionary:dict];
    [request startRequestWithBody:finishblock];
}

#pragma mark --设置我的默认形象
+(void)setUserDefaultFigureWithDict:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock;{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTAPP;
    request.actionKey = @"userinfo/setDefaultFigure";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startRequestWithBody:finishblock];
}

#pragma mark-- 单个 模型 详情 接口 --
+(void)getModeDetailWithProductType:(int)productType andImageCellType:(WTCollectionImageCellType)cellType andID:(NSString *)Id andFinishblock:(RequestResultBlock)finishblock{
    if (cellType == kCollectionImageCellPreDefaultMy3DImage || cellType == kCollectionImageCellPreDefault3DImageTemp) {////预览 个人形象设置 : 我的3D形象/ 3D示例素材
        [WTApiInterface queryFigureDetailWithResourceType:productType andResourceId:Id andFinishblock:finishblock];
        return;
    }
    if (productType==kWT3DImageResourceTypeMyMode) {//我的3D形象
        [WTApiInterface getMy3DImageDetailByID:Id andFinishblock:finishblock];
        return;
    }else{//3d素材
        [WTApiInterface getHotImageDetailByID:Id andFinishblock:finishblock];
        return;
    }
}

/****************预约模块*************/
#pragma mark--获取3D形象预约列表 --
+ (void) get3DImageReserveList:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTReserve3D;
    request.actionKey = @"list";
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startUserCenterRequest:finishblock];
}

/****************banner模块*************/
#pragma mark-- app首页banner --
+ (void) getBannerList:(NSDictionary *)dict andPosition:(KBannerPosition)position andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTBanner;
    switch (position) {
        case kBannerPositionHomePageTop:
        {
            request.actionKey = @"homeBanner";
        }
            break;
        default:
            break;
    }
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startUserCenterRequest:finishblock];
}

+(void)deleteMinePublishWithId:(NSInteger)deleteId andFinishBlock:(RequestResultBlock)finishblock{
    NSDictionary *dict = @{@"id":@(deleteId)};
    WTBaseRequest *request = [[WTBaseRequest alloc]init];
    request.host = HostCommunity;
    request.actionKey = @"delete";
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startUserCenterRequest:finishblock];
}

// 发布自己的创作
+(void)publishMineWithDict:(NSDictionary *)dict andFinishBlock:(RequestResultBlock)finishblock{
    WTBaseRequest *request = [[WTBaseRequest alloc]init];
    request.host = HostCommunity;
    request.actionKey = @"publishMedia";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startRequestWithBody:finishblock];
}

+(void)getQiNiuTokenWithType:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock{
    WTBaseRequest *request = [[WTBaseRequest alloc]init];
    request.host = HostQiNiu;
    request.actionKey = @"qiniu/nologin/getToken";
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startUserCenterRequest:finishblock];
}

#pragma mark-- 官方教程 -- 瀑布流相关接口 --
/// 教程列表
+(void)communityCourseList:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock{
    WTBaseRequest *request = [[WTBaseRequest alloc]init];
    request.host = HostCommunity;
    request.actionKey = @"course/list";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startRequestWithBody:finishblock];
}

/// 详情
+(void)communityCourseDetail:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock{    
    WTBaseRequest *request = [[WTBaseRequest alloc]init];
    request.host = HostCommunity;
    request.actionKey = @"course/detail";
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startUserCenterRequest:finishblock];
}


/// 收藏
+(void)communityCourseFavorites:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HostCommunity;
    request.actionKey = @"course/favorites";
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startUserCenterRequest:finishblock];
}
//http://meta-test-api.crhlink.com/app/image/list?pageNumber=1&pageSize=1000&type=1
/// 点赞
+(void)communityCourseLike:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HostCommunity;
    request.actionKey = @"course/like";
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startUserCenterRequest:finishblock];
}

/// 我的收藏
+(void)communityCourseMyFavorites:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HostCommunity;
    request.actionKey = @"course/myFavorites";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startRequestWithBody:finishblock];
}

/// 记录浏览
+(void)communityViewRecord:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HostCommunity;
    request.actionKey = @"viewRecord";
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startUserCenterRequest:finishblock];
}

/// 浏览记录列表
+(void)communityMyViewRecord:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock{
    WTBaseRequest *request = [[WTBaseRequest alloc]init];
    request.host = HostCommunity;
    request.actionKey = @"myViewRecord";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startRequestWithBody:finishblock];
}

/// 我的点赞
+(void)communityCourseMyLikes:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HostCommunity;
    request.actionKey = @"course/myLikes";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startRequestWithBody:finishblock];
}

/// 我的创作
+(void)communityCourseMyCreation:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HostCommunity;
    request.actionKey = @"course/myPublish";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startRequestWithBody:finishblock];
}

#pragma mark -- 举报/申诉创作
+ (void)creationReportCreate:(NSDictionary *)dict andFinishBlock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTAPP;
    request.actionKey = @"report/create";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"application/json";
    [request.agrs addEntriesFromDictionary:dict];
    [request startRequestWithBody:finishblock];
}

#pragma mark -- 七牛文件上传 type: 1-图片，2-文件
+ (void)uploadFileToQiNiu:(NSData *)fileData fileName:(NSString *)fileName mimeType:(NSString *)mimeType type:(kUploadFileToQN)type
           progress:(void(^)(NSProgress * _Nonnull uploadProgress))progress
           andFinishBlock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HostQiNiu;
    request.actionKey = @"qiniu/nologin/upload";
    request.requestMethod = HTTP_POST_Request;
    request.contentType = @"multipart/form-data";
    NSDictionary *dict = @{
        @"file": fileName,
        @"type": @(type),
    };
    [request.agrs addEntriesFromDictionary:dict];
    [request startUploadFile:fileData fileName:fileName mimeType:mimeType progress:^(NSProgress * _Nonnull uploadProgress) {
        WTLog(@" uploadProgress = %@ ", uploadProgress.localizedDescription)
        dispatch_main_async_safe(^{
            progress(uploadProgress);
        });
    } requestBlock:^(id response, NSString *errStr, int state) {
        WTSLog(@" state = %d , startUploadFile = %@ , errStr = %@", state, response, errStr)
        dispatch_main_async_safe(^{
            finishblock(response, errStr, state);
        });
    }];
}


#pragma mark -- 消息列表
+ (void)reportListWithPageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize  andFinishBlock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTAPP;
    request.actionKey = @"report/list";
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    NSDictionary *dict = @{
        @"pageNumber": @(pageNumber),
        @"pageSize": @(pageSize)
    };
    [request.agrs addEntriesFromDictionary:dict];
    [request startUserCenterRequest:finishblock];
}

#pragma mark -- 消息未读状态
+ (void)reportMessageUnReadStatusFinishBlock:(RequestResultBlock)finishblock{
    WTBaseRequest * request = [[WTBaseRequest alloc]init];
    request.host = HOSTAPP;
    request.actionKey = @"report/find";
    request.requestMethod = HTTP_GET_Request;
    request.contentType = @"application/json";
    [request startUserCenterRequest:finishblock];
}


@end

