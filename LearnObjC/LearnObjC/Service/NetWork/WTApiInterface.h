//
//  WTApiInterface.h
//  TravelWorld
//
//  Created by mac on 2017/9/28.
//  Copyright © 2017年 JackyZhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTBaseRequest.h"

typedef enum {
    kBannerPositionHomePageTop = 0,//首页头部
}KBannerPosition;

typedef enum {
    kUploadToQNFilePhoto = 1,//图片
    kUploadToQNFileVideo = 2,//视频
}kUploadFileToQN;

@interface WTApiInterface : NSObject

#pragma mark--版本更新
+(void)versionUpdateFinishblock:(RequestResultBlock)finishblock;

/** **************登录模块*************/
#pragma mark--发送验证码
//发送验证码 0验证码登录 1绑定手机号
+ (void)sendMobileCode:(NSString *)mobile Type:(NSInteger)type andFinishblock:(RequestResultBlock)finishblock;

#pragma mark--快捷登录
+ (void)speedLoginWith:(NSDictionary *)par andFinishblock:(RequestResultBlock)finishblock;

#pragma mark--退出登录
+ (void)loginQuit:(RequestResultBlock)finishblock;

/****************个人模块*************/

#pragma mark--注销账号
+ (void)accountLogoutWith:(NSDictionary *)par andFinishblock:(RequestResultBlock)finishblock;

#pragma mark--修改头像
+(void)updateHeadWith:(UIImage *)head andFinishblock:(RequestResultBlock)finishblock;

#pragma mark--修改个人资料
+(void)updateInformationWith:(NSDictionary *)Information
              andFinishblock:(RequestResultBlock)finishblock;

#pragma mark - 获取用户信息
+ (void)getUserInfoWithNeedLogin: (BOOL)isNeedLogin finishblock: (RequestResultBlock)block;


#pragma mark--我的二维码
+ (void)getUserQrCode:(RequestResultBlock)finishblock;//userinfo/qrCode
+ (void)getUserQueryUserFigure:(RequestResultBlock)finishblock;

/** **************订单模块*************/
#pragma mark - 3D形象提交订单 order/create
+(void)cretat3DImageOrder:(NSDictionary *)dict
              andFinishblock:(RequestResultBlock)finishblock;

#pragma mark--取消订单
+ (void)cancel3DImageOrder:(NSString *)orderId andFinishblock:(RequestResultBlock)finishblock;


#pragma mark--支付订单
+ (void)get3DImageOrderPaySign:(NSString *)orderId andPayChannel:(NSString *)payChannel andFinishblock:(RequestResultBlock)finishblock;

#pragma mark--3d订单列表
+ (void) get3DImageOrderList:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock;


#pragma mark--订单详情
+ (void)get3DImageOrderDetail:(NSString *)orderId andFinishblock:(RequestResultBlock)finishblock;

/** **************形象模块*************/
#pragma mark -- 获取高清形象的价格及名称信息
+ (void)get3DIamgePriceInfoAndFinishblock:(RequestResultBlock)finishblock;

#pragma mark--获取我的3d形像接口 --
+(void)getMy3DImage:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock;


#pragma mark--   单个  获取我的3d形像 详情 接口 --
+(void)getMy3DImageDetailByID:(NSString *)modeId andFinishblock:(RequestResultBlock)finishblock;

///** *************素材模块*************/
#pragma mark--   单个 获取热门素材  详情 接口 --
+(void)getHotImageDetailByID:(NSString *)modeId andFinishblock:(RequestResultBlock)finishblock;

/** *************模型数据模块*************/
+(void)getModeListWithProductType:(int)productType andImageCellType:(WTCollectionImageCellType)cellType andDict:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock;

#pragma mark - 我的/示例形象列表
+(void)getUserInfoQueryFigureListWithResourceType:(int)resourceType andDict:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock;
#pragma mark --我的/示例详情
+(void)queryFigureDetailWithResourceType:(int)resourceType andResourceId:(NSString *)resourceId andFinishblock:(RequestResultBlock)finishblock;
#pragma mark --设置我的默认形象
+(void)setUserDefaultFigureWithDict:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock;

//#pragma mark --获取我的3D形象/热门素材
//+(void)getModeDetailWithProductType:(int)productType andID:(NSString *)Id andFinishblock:(RequestResultBlock)finishblock;
#pragma mark-- 单个 模型 详情 接口 --
+(void)getModeDetailWithProductType:(int)productType andImageCellType:(WTCollectionImageCellType)cellType andID:(NSString *)Id andFinishblock:(RequestResultBlock)finishblock;
/****************预约模块*************/
#pragma mark--获取3D形象预约列表 --
+ (void) get3DImageReserveList:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock;


/****************banner模块*************/
#pragma mark-- app首页banner --
//banner/homeBanner
+ (void) getBannerList:(NSDictionary *)dict andPosition:(KBannerPosition)position andFinishblock:(RequestResultBlock)finishblock;


#pragma mark -- 删除自己的创作 ---
+(void)deleteMinePublishWithId:(NSInteger)deleteId andFinishBlock:(RequestResultBlock)finishblock;
// 发布自己的创作
+(void)publishMineWithDict:(NSDictionary *)dict andFinishBlock:(RequestResultBlock)finishblock;

#pragma mark --- 获取 七牛 云token
/// 获取七牛云token
/// @param dict 1-图片，2-文件
+(void)getQiNiuTokenWithType:(NSDictionary *)dict andFinishblock:(RequestResultBlock)finishblock;

#pragma mark-- 官方教程 -- 瀑布流相关接口 --
/// 教程列表
+(void)communityCourseList:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock;

/// 详情
+(void)communityCourseDetail:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock;

/// 收藏
+(void)communityCourseFavorites:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock;

/// 点赞
+(void)communityCourseLike:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock;

/// 我的收藏
+(void)communityCourseMyFavorites:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock;

/// 记录浏览
+(void)communityViewRecord:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock;

/// 浏览记录列表
+(void)communityMyViewRecord:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock;

/// 我的点赞
+(void)communityCourseMyLikes:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock;

/// 我的创作
+(void)communityCourseMyCreation:(NSDictionary *)dict finishblock:(RequestResultBlock)finishblock;

#pragma mark -- 举报/申诉创作
+ (void)creationReportCreate:(NSDictionary *)dict andFinishBlock:(RequestResultBlock)finishblock;

#pragma mark -- 七牛文件上传 type: 1-图片，2-文件
+ (void)uploadFileToQiNiu:(NSData *)fileData
          fileName:(NSString *)fileName
          mimeType:(NSString *)mimeType
          type:(kUploadFileToQN)type
          progress:(void(^)(NSProgress * _Nonnull uploadProgress))progress
          andFinishBlock:(RequestResultBlock)finishblock DEPRECATED_MSG_ATTRIBUTE("v1.1.0, 为了就是传大文件接口超时，所以让你们本地用七牛云,参考 WTQiNiuUpload 类");

#pragma mark -- 消息列表
+ (void)reportListWithPageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize  andFinishBlock:(RequestResultBlock)finishblock;

#pragma mark -- 消息未读状态
+ (void)reportMessageUnReadStatusFinishBlock:(RequestResultBlock)finishblock;
@end

