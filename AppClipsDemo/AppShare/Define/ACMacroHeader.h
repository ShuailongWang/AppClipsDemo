//
//  ACMacroHeader.h
//  AppClipsDemo
//
//  Created by wangshuailong on 2020/10/23.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#ifndef ACMacroHeader_h
#define ACMacroHeader_h


#define GRScreenW               ([[UIScreen mainScreen] bounds].size.width)
#define GRScreenH               ([[UIScreen mainScreen] bounds].size.height)
#define GRStatusBarH            [[UIApplication sharedApplication] statusBarFrame].size.height
#define kGR_ScreenWidth         MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)
#define kGR_ScreenHeight        MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)


#define ScaleTo375(x)           (CGFloat)((x) * (GRScreenW / 375.0f))
#define IS_IPHONEXR             (GRScreenW == 414.f && GRScreenH == 896.f ? YES : NO)
#define IS_IPHONEX              (GRScreenW == 375.f && GRScreenH == 812.f ? YES : NO)
#define SafeAreaBottomHeight    (IS_IPHONEX || IS_IPHONEXR ? 34 : 0)
#define GRNavigationBarHeight   (44.0f + GRStatusBarH)
#define kSlideViewWidth         (GRScreenW * 0.8)    //slide宽
#define kBtHeight               (58)
#define kBottomBarHeight        (kBtHeight + SafeAreaBottomHeight)

#pragma mark - 字体
#define Font(x)     [UIFont systemFontOfSize:Fix(x)]
#define MedFont(x)  [UIFont systemFontOfSize:Fix(x) weight:UIFontWeightMedium]
#define BoldFont(x) [UIFont systemFontOfSize:Fix(x) weight:UIFontWeightSemibold]

#pragma mark - Color
#define GR_RGB(__r, __g, __b)       [UIColor colorWithRed:(__r / 255.0) green:(__g / 255.0) blue:(__b / 255.0) alpha:1]
#define GR_RGBA(__r, __g, __b, __a) [UIColor colorWithRed:(__r / 255.0) green:(__g / 255.0) blue:(__b / 255.0) alpha:__a]

#define GR_HEXCOLOR(rgbValue)       [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define GR_HEXCOLORA(rgbValue,__a)  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:__a]

#pragma mark - 设备
#define IsPad               (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kAPP_Version        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define OverIPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})


#pragma mark - NSLog
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...)
#endif



#endif /* ACMacroHeader_h */
