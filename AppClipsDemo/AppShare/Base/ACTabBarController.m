//
//  ACTabBarController.m
//  ClipsPackExtension
//
//  Created by wangshuailong on 2020/10/22.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#import "ACTabBarController.h"
#import "ACNavigationController.h"
#import "ACHomeViewController.h"
#import "ACPlanViewController.h"
#import "ACMineViewController.h"

@interface ACTabBarController ()

@end

@implementation ACTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self addChildWithController:[[ACHomeViewController alloc] init] title:@"推荐" imgName:@"home_sidebar_recomm_light"];
    [self addChildWithController:[[ACPlanViewController alloc] init] title:@"订阅" imgName:@"home_sidebar_subscribe_light"];
    [self addChildWithController:[[ACMineViewController alloc] init] title:@"我的" imgName:@"home_sidebar_collect_light"];
    
}

- (void)addChildWithController:(UIViewController*)controller title:(NSString*)title imgName:(NSString*)imgName{
    controller.tabBarItem.image = [UIImage imageNamed:imgName];
    controller.tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@_sel", imgName]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    controller.title = title;
//    [controller.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blueColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:12], NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    ACNavigationController *navigationVC = [[ACNavigationController alloc] initWithRootViewController:controller];
    [self addChildViewController:navigationVC];
}



@end
