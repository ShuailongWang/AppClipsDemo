//
//  AppDelegate.m
//  ClipsPackExtension
//
//  Created by wangshuailong on 2020/10/22.
//

#import "AppDelegate.h"
#import "ACTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setWindowUI];
    
    
    return YES;
}


//widnow
- (void)setWindowUI{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[ACTabBarController alloc] init];
    [self.window makeKeyAndVisible];
}



- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
    
    NSLog(@"webpageURL ==> %@", userActivity.webpageURL.absoluteString);
    
    return YES;
}


@end
