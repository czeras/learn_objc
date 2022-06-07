//
//  AppDelegate.m
//  LearnObjC
//
//  Created by czeras on 2022/6/5.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = naviVC;
    
    return YES;
}

@end
