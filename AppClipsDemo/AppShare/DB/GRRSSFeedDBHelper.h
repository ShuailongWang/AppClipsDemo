//
//  GRRSSFeedDBHelper.h
//  GreenRSS
//
//  Created by wangshuailong on 2020/8/28.
//

#import <Foundation/Foundation.h>
#import "GRFeedContentModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, HomeTypeCode) {
    HOME_RECOMMEND = 0,   //推荐
    HOME_SUBLINE,         //订阅
    HOME_DETAILS,         //详情
};

typedef void(^ComplaItemBlack)(NSArray * _Nullable modelList);
typedef void(^ComplListBlack)(NSArray * _Nullable modelList, NSInteger page);

@interface GRRSSFeedDBHelper : NSObject

//查询推荐或者订阅列表
+ (void)selectRecommendFeedItemWIthPage:(NSUInteger)page feeds:(NSArray*)feeds type:(HomeTypeCode)type complatiion:(ComplaItemBlack)complatiion;
+ (void)selectRecommendFeeds:(NSArray*)feeds type:(HomeTypeCode)type complatiion:(ComplaItemBlack)complatiion;

//插入推荐或者订阅列表
+ (void)insertRecommendOrSubWithFeedmodel:(GRFeedContentModel*)feedModel type:(HomeTypeCode)type;
+ (void)insertHomeWithList:(NSArray*)list type:(HomeTypeCode)type;


//根据传入的类型删除推荐或者订阅
+ (void)deleteRecommendSelItemWithModel:(GRFeedItemModel*)itemModel  type:(HomeTypeCode)type;
//批量删除
+ (void)deleteItemListWithList:(NSArray*)list type:(HomeTypeCode)type;

//查询我的订阅列表
+ (NSArray*)selectMySublineList;


//detail feedList查询
+ (void)selectDetailFeedItemWIthPage:(NSUInteger)page andUrl:(NSString *)url complatiion:(ComplaItemBlack)complatiion;

//detail feedList插入
+ (void)insertWithDetailFeedmodel:(GRFeedContentModel*)feedModel andUrl:(NSString *)url;
//删除feedList 数据
+ (void)deleteDetailFeedItemWithModel:(GRFeedItemModel*)itemModel;

//不喜欢列表
+ (void)insertNoLikeWithItemModel:(GRFeedItemModel*)itemModel;


@end

NS_ASSUME_NONNULL_END
