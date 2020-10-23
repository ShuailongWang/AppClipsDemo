//
//  ACNavigationController.m
//  AppClipsDemo
//
//  Created by wangshuailong on 2020/10/22.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#import "ACNavigationController.h"

@interface ACNavigationController ()

@end

@implementation ACNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        [viewController setHidesBottomBarWhenPushed:YES];
    }
    [super pushViewController:viewController animated:animated];
}

@end
