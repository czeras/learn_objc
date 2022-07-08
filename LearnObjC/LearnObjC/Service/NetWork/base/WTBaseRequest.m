//
//  WTBaseRequest.m
//  TravelWorld
//
//  Created by mac on 2017/9/28.
//  Copyright © 2017年 JackyZhou. All rights reserved.
//

#import "WTBaseRequest.h"
#import "WSLoginVC.h"
#define signatureKey  @"4C05F6866713455AA720F1DD558F7"

@interface WTBaseRequest()
@property(nonatomic,strong)NSURLSessionDataTask *task;
@end

@implementation WTBaseRequest
- (instancetype)init
{
    if (self = [super init]) {
        self.isNotNeedTokenLegalShowLoginVC = YES;
    }
    return self;
}
- (NSMutableDictionary *)agrs
{
    if (!_agrs) {
        _agrs = [[NSMutableDictionary alloc]init];
    }
    return _agrs;
}
/**
 *  取消请求
 */
- (void)cancelRequest
{
    [self.task cancel];
    self.task = nil;
}
/**
 *  挂起请求
 */
- (void)suspendRequest
{
    [self.task suspend];
}
/**
 *  继续请求
 */
- (void)resumeRequest
{
    [self.task resume];
}
/**
 *  设置请求头
 */
- (NSMutableDictionary *)getHttpHeaders
{
    NSMutableDictionary *header = [NSMutableDictionary new];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [header setObject:version forKey:@"clientVersion"];
    [header setObject:@"metaapp" forKey:@"invokePoolCode"];
    [header setObject:[NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    [header setObject:[ToolClass getToken] forKey:@"token"];
    
    NSString *signatureStr = [NSString stringWithFormat:@"invokePoolCode=metaapp&timestamp=%@&token=%@%@",[NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]],[ToolClass getToken],signatureKey];
    NSString *signature = [ToolClass md5:signatureStr];
    [header setObject:signature forKey:@"signature"];
    [header setObject:@"1" forKey:@"source"];
    [header setObject:@"iphone" forKey:@"platform"];
    return header;
}

/**
 *  图片上传
 *  @param imageDatas 图片data数组
 *  @param names 图片名参数数组
 *  @param block 回调
 */
- (void)startUploadImage:(NSArray *)imageDatas names:(NSArray *)names requestBlock:(RequestResultBlock)block
{
    self.callBackBlock = block;
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.host, self.actionKey];
    //需要传userId
    if (_needUserId) {
        NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_dic"];
        NSString *userId =userDic[@"id"];
        if (userId) {
            [self.agrs setObject:userId forKey:@"userId"];
        }
    }
    if (!self.requestMethod) {
        [self callRequestBlock:block andData:nil andMsg:@"请传入请求方式" andState:500];
        return;
    }
    WTHttpClient *httpClient = [WTHttpClient sharedInstance];
    NSDictionary *header = [self getHttpHeaders];
    self.task = [httpClient uploadImageRequest:urlString Headers:header Parameters:self.agrs ImageDatas:imageDatas ImagesNames:names completion:^(id result, NSError *error) {
        [self analysisUserCenterData:result andError:error andRequestBlock:block];
    }];
}

/**
 *  文件上传
 *  @param fileData data
 *  @param progress 回调
 */
- (void)startUploadFile:(NSData *)fileData fileName:(NSString *)fileName mimeType:(NSString *)mimeType progress:(void(^)(NSProgress * _Nonnull uploadProgress))progress requestBlock:(RequestResultBlock)block
{
    self.callBackBlock = block;
    self.requestMethod = @"POST";
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.host, self.actionKey];
    if (!self.requestMethod) {
        [self callRequestBlock:block andData:nil andMsg:@"请传入请求方式" andState:500];
        return;
    }
    
    WTHttpClient *httpClient = [WTHttpClient sharedInstance];
    NSDictionary *header = [self getHttpHeaders];
    self.task = [httpClient uploadFileRequest:urlString Headers:header Parameters:self.agrs fileData:fileData fileName:fileName mimeType: mimeType progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } completion:^(id result, NSError *error) {
        [self analysisUserCenterData:result andError:error andRequestBlock:block];
    }];
    [self.task resume];
}


/**
 *  用户中心接口请求
 *  @param block 请求数据回调block
 */
- (void)startUserCenterRequest:(RequestResultBlock)block
{
    self.callBackBlock = block;
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.host, self.actionKey];
    //需要传userId
    if (_needUserId) {
        NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_dic"];
        NSString *userId =userDic[@"id"];
        if (userId) {
            [self.agrs setObject:userId forKey:@"userId"];
        }
    }
    if (!self.requestMethod) {
        [self callRequestBlock:block andData:nil andMsg:@"请传入请求方式" andState:500];
        return;
    }
    WTHttpClient *httpClient = [WTHttpClient sharedInstance];
    NSMutableDictionary *header = [self getHttpHeaders];
    if ([self.contentType isNotBlank]) {
        [header setObject:self.contentType forKey:@"Content-Type"];
    }else{
        [header setObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    }

    WTSLog(@"startUserCenterRequest ---- 请求链接：%@，参数%@，token=%@ ",urlString,self.agrs,[ToolClass getToken]);
    self.task = [httpClient requestWithMethod:self.requestMethod Headers:header UrlString:urlString Parameters:self.agrs completion:^(id result, NSError *error) {
        [self analysisUserCenterData:result andError:error andRequestBlock:block];
    }];
    
}

- (void)callRequestBlock:(RequestResultBlock)block andData:(id)data andMsg:(NSString *)msg andState:(int)state{
    dispatch_main_async_safe(^{
        block(data, msg, state);
    });
}

- (void)startRequestWithBody:(RequestResultBlock)block {
    self.callBackBlock = block;
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.host, self.actionKey];
    //需要传userId
    if (_needUserId) {
        NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_dic"];
        NSString *userId =userDic[@"id"];
        if (userId) {
            [self.agrs setObject:userId forKey:@"userId"];
        }
    }
    if (!self.requestMethod) {
        [self callRequestBlock:block andData:nil andMsg:@"请传入请求方式" andState:500];
        return;
    }
    id object = self.agrs;
    NSData *data =  [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingFragmentsAllowed error:nil];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                         timeoutInterval:20];
    [request setAllHTTPHeaderFields:[self getHttpHeaders]];
    if ([self.contentType isNotBlank]) {
        [request setValue:self.contentType forHTTPHeaderField:@"Content-Type"];
    }else{
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    [request setHTTPMethod:@"POST"];
    if (data) {
        [request setHTTPBody:data];
    }
//    WTSLog(@" url=%@, method:%@,  contentType=%@,  \r\n header=%@ , \r\n data:%@---", self.actionKey,@"POST", self.contentType,  [self getHttpHeaders], self.agrs);
    NSURLSessionDataTask *tast=[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable result, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self analysisUserCenterData:result andError:error andRequestBlock:block];
    }];
    [tast resume];
}

/**
 *  解析用户中心接口数据
 *  @param result 返回的数据
 */
- (void)analysisUserCenterData:(id)result andError:(NSError *)resultError andRequestBlock:(RequestResultBlock)block
{
    if (!result) {
        NSString *msg = resultError ? resultError.localizedDescription : nil;
        [self callRequestBlock:block andData:nil andMsg:msg andState:500];
        return;
    }
    
    NSError *error = nil;
    id jsonObject = result ? [NSJSONSerialization JSONObjectWithData:result
                                                    options:NSJSONReadingAllowFragments
                                                               error:&error] : nil;

    NSString *url = self.actionKey;
    NSString *requestMethod = self.requestMethod;
    NSDictionary *agrs = self.agrs;
    @weakify(self)
    void (^callCallDoBlock)(int, NSDictionary *) = ^(int code, NSDictionary *dic){
        @strongify(self)
        NSString *msg = [dic[@"msg"] description];
        
        WTSLog(@"api url=%@, method=%@, params=%@, state = %d,  msg = %@ \n  ",url,requestMethod, agrs, code, msg);//不打印data
        if (code == 0) {
            //成功
            id data = [self filterDictionary:dic];
            [self callRequestBlock:block andData:data andMsg:nil andState:code];
        }
        else{
            if (code == 2002 || code == 2003||code == 301) {
                [ToolClass userLoginQuitEndHandler];
                if (code==2002 || code==2003) {
                    msg = @"";
                    @weakify(self)
                    dispatch_main_async_safe(^{
                        @strongify(self)
                        AppDelegate *appDelete =  (AppDelegate *)[UIApplication sharedApplication].delegate;
                        UIViewController *topVC = [self currentViewController];
                        NSString *topVCClassStr = NSStringFromClass([topVC class]);
                        WTTabbarController *tabbarVC = [AppDelegate delegate].tabbar;
                        UIViewController *tab0VC = tabbarVC.viewControllers[0];

                        [WTAlterActionsView showWithTitle:code==2003?@"已禁用":@"不存在" andTopImage:[UIImage imageNamed:@"icon_alter_nouser"] andDes: code==2003?@"用户已禁用，暂时无法使用":@"用户不存在，暂时无法使用" andAction1Title: topVC==tab0VC ? @"我知道了" : @"回到首页" andAction2Title:nil andActionCall:^(NSInteger index, NSString * _Nonnull action) {
                            
                            if ([topVCClassStr isEqualToString:@"WSLoginVC"] || [topVCClassStr isEqualToString:@"WSVerificationCodeVC"]) {
                                [topVC dismissViewControllerAnimated:YES completion:nil];
                            }
                            BOOL isTopUnityVC =(class_getSuperclass([topVC class]) ==  NSClassFromString(@"WTBaseUnityVC")) || [topVCClassStr isEqualToString:@"UnityDefaultViewController"];
                            if (isTopUnityVC) {
//                                [[WTUnitySDK sharedSDK] showNativeWindow];
                            }
                            [appDelete showTabbarController:0];
                            [tabbarVC.viewControllers[tabbarVC.selectedIndex].navigationController popViewControllerAnimated:NO];
                        }];
                    });
                }
//                   //需要重新登录
//                   if (!self.isNotNeedTokenLegalShowLoginVC) {//默认验证token
//                       UIViewController *vc = [self currentViewController];
//                       WSLoginVC *login = [[WSLoginVC alloc]init];
//                       BaseNavigationController *nav = [[BaseNavigationController alloc]initWithRootViewController:login];
//                       nav.modalPresentationStyle = UIModalPresentationFullScreen;
//                       [vc presentViewController:nav animated:YES completion:nil];
//                   }
            }
            id data = [self filterDictionary:dic];
            [self callRequestBlock:block andData:data andMsg:msg andState:code];
        }
    };
    
    if (![jsonObject isEqual:[NSNull null]]&&[jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = jsonObject;
        if ([dic.allKeys containsObject:@"state"]) {
            int state = [dic[@"state"] intValue];
            callCallDoBlock(state, dic);
        }
        else if ([dic.allKeys containsObject:@"code"]) {
            int code = [dic[@"code"] intValue];
            callCallDoBlock(code, dic);
        }
        else{
            [self callRequestBlock:block andData:nil andMsg:@"服务异常,请重试" andState:500];
        }
    }
    else{
        [self callRequestBlock:block andData:nil andMsg:@"请求失败,请重试" andState:500];
    }
}


#pragma mark--私有方法
/**
 *  过滤数据空指针
 *  @param object 原始数据
 *  @return 过滤后的数据
 */
- (id)filterOjectData:(id)object{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        return [self filterDictionary:object];
    }
    else if([object isKindOfClass:[NSArray class]])
    {
        return [self filterArray:object];
    }
    else if([object isKindOfClass:[NSString class]])
    {
        return object;
    }
    else if([object isKindOfClass:[NSNull class]])
    {
        return @"";
    }
    else
    {
        return object;
    }
}
/**
 *  过滤字典空指针
 *  @param dic 原始字典
 *  @return 过滤后的字典
 */
- (NSDictionary *)filterDictionary:(NSDictionary *)dic
{
    NSArray *keyArr = [dic allKeys];
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < keyArr.count; i ++)
    {
        id obj = [dic objectForKey:keyArr[i]];
        obj = [self filterOjectData:obj];
        [resDic setObject:obj forKey:keyArr[i]];
    }
    return resDic;
}

/**
 *  过滤字典空指针
 *  @param array 原始数组
 *  @return 过滤后的数组
 */
- (NSArray *)filterArray:(NSArray *)array
{
    NSMutableArray *resArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < array.count; i ++)
    {
        id obj = array[i];
        
        obj = [self filterOjectData:obj];
        [resArr addObject:obj];
    }
    return resArr;
}

- (UIViewController*)currentViewController{
    //获得当前活动窗口的根视图
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1)
    {
        //根据不同的页面切换方式，逐步取得最上层的viewController
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}
@end

