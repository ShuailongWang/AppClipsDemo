//
//  GRGreenRssDBHandle.h
//  GreenRSS
//
//  Created by wangshuailong on 2020/8/28.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

NS_ASSUME_NONNULL_BEGIN


#define kFeeds_Recommend_TBName     @"recommendFeeds"       //推荐列表
#define kFeedItem_Recommend_TBName  @"recommendFeedItems"   //推荐item列表
#define kFeeds_User_TBName          @"userFeeds"            //用户列表, 拉去的数据
#define kFeedItem_User_TBName       @"userFeedsItems"       //用户item列表, 拉去的数据
#define kCollection_TBName          @"collection"           //收藏
#define kFeedList_TBName            @"feedList"             //详情页fedd表
#define kNoLike_TBName              @"nolike"               //不喜欢表格
#define kDown_TBName                @"down"                 //下载


typedef void(^dbSelComplete)(BOOL result) ;

@class GRBaseDBModel;
@interface GRGreenRssDBHandle : NSObject

@property (strong, nonatomic) FMDatabase *dbManager;

+ (instancetype)shareInstance;

- (void)execQueryBlock:(void(^)(void))block;

//
- (void)isHasUserColTableWithTableName:(NSString*)tableName;
- (void)isHasUserSubTableWithTableName:(NSString*)tableName;

//查询
- (NSArray *)selectTableWithModel:(Class)model tableName:(NSString*)tableName where:(NSString*)predicate;
- (NSArray *)selectTableWithModel:(Class)model tableName:(NSString*)tableName sql:(NSString*)sql;

//插入
- (void)insertTableWithModel:(GRBaseDBModel*)model tableName:(NSString*)tableName complete:(dbSelComplete __nullable)complete;

//更新
- (void)updateTableWithModel:(GRBaseDBModel*)model tableName:(NSString*)tableName where:(NSString*)predicate;

//删除, 按照条件删除
- (void)deleteTableWithTableName:(NSString*)tableName where:(NSString*)predicate;

//标记删除
- (void)deleteUpsignWithTableName:(NSString*)tableName where:(NSString*)predicate;

// 清表
- (void)clearTableWithTableName:(NSString*)tableName;

@end

NS_ASSUME_NONNULL_END
