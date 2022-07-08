//
//  BaseAPIConfig.h
//  TravelWorld
//
//  Created by mac on 2017/9/28.
//  Copyright © 2017年 JackyZhou. All rights reserved.
//

#ifndef BaseAPIConfig_h
#define BaseAPIConfig_h

/**
 * MLeaksFinder 配置
 */
#if DEBUG
    #define MEMORY_LEAKS_FINDER_ENABLED 0  //0: 关闭， 1: 开启 (默认：MLeaksFinder 默认只在 debug 下生效）
    //引进 MLeaksFinder 的代码后即可检测内存泄漏，是否。查找循环引用的功能
    #define MEMORY_LEAKS_FINDER_RETAIN_CYCLE_ENABLED 0 //(默认：0 关闭）
#else
   
#endif

//// dev 环境
//#define WTENV_Pro 0  //是否为线上  // 1: pro,  0: WTENV_Test
//#define WTENV_Test 0 //是否为测试  // 1: test, 0: dev

// test 环境
#define WTENV_Pro 0  //是否为线上  // 1: pro,  0: WTENV_Test
#define WTENV_Test 1 //是否为测试  // 1: test, 0: dev

// pro 环境 WTENV_Test 0、1 无所谓
//#define WTENV_Pro 0  //是否为线上  // 1: pro,  0: WTENV_Test
//#define WTENV_Test 1 //是否为测试  // 1: test, 0: dev


#if WTENV_Pro
    #define WEBURL @"https://h5.weitaikeji.com/meta/"      //外网 h5 pro线上地址
    #define APIIP @"https://meta-api.weitaikeji.com/"      //外网 api pro线上地址
#else
    #if WTENV_Test
        #define WEBURL @"http://meta-test-h5.crhlink.com/" //外网 h5 test地址
        #define APIIP @"http://meta-test-api.crhlink.com/" //外网 api test地址
    #else
        #define WEBURL @"http://meta-dev-h5.crhlink.com/"  //外网 h5 dev地址
        #define APIIP @"http://meta-dev-api.crhlink.com/"  //外网 api dev地址
    #endif
#endif


//app模块HOST
#define HOSTAPP [NSString stringWithFormat:@"%@app/",APIIP]
//banner模块HOST
#define HOSTBanner [NSString stringWithFormat:@"%@app/banner/",APIIP]
//用户中心模块HOST
#define HOSTUSER [NSString stringWithFormat:@"%@user/",APIIP]
//订单模块HOST
#define HOSTORDER [NSString stringWithFormat:@"%@app/order/",APIIP]
//3d形象模块HOST
#define HOSTImage [NSString stringWithFormat:@"%@app/image/",APIIP]
//3d预约模块HOST
#define HOSTReserve3D [NSString stringWithFormat:@"%@app/reserve/",APIIP]
//3d素材模块HOST
#define HOSTMaterial [NSString stringWithFormat:@"%@app/material/",APIIP]
// app 官方教程
#define HostCommunity [NSString stringWithFormat:@"%@app/community/",APIIP]
//#define HostCommunityNOApp [NSString stringWithFormat:@"%@community/",APIIP]

// 获取七牛token
#define HostQiNiu [NSString stringWithFormat:@"%@console/",APIIP]



#endif /* BaseAPIConfig_h */

