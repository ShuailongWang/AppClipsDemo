//
//  RSSDetailModel.h
//  GreenRSS
//
//  Created by zhangzhenyun on 2020/8/2741.
//

#import <Foundation/Foundation.h>

@interface RSSDetailModel : NSObject
@property (nonatomic, assign) BOOL isSubcribed;//是否订阅
@property (nonatomic, strong) NSString *iconURL;//图标
@property (nonatomic, strong) NSString *title;//标题
@property (nonatomic, strong) NSString *info;//简介
@property (nonatomic, strong) NSString *link;//链接
@property (nonatomic, strong) NSString *imgName;//本地图片

@end

