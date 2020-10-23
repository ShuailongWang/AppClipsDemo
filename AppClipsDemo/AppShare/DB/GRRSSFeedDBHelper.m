//
//  GRRSSFeedDBHelper.m
//  GreenRSS
//
//  Created by wangshuailong on 2020/8/28.
//

#import "GRRSSFeedDBHelper.h"
#import "GRGreenRssDBHandle.h"

@implementation GRRSSFeedDBHelper

//查询推荐列表
+ (void)selectRecommendFeedItemWIthPage:(NSUInteger)page feeds:(NSArray*)feeds type:(HomeTypeCode)type complatiion:(ComplaItemBlack)complatiion{
    NSString *tbName = @"";
    if (type == HOME_SUBLINE) {
        tbName = kFeedItem_User_TBName;
    } else if (type == HOME_RECOMMEND) {
        tbName = kFeedItem_Recommend_TBName;
    }
    
    NSMutableString *strM = [NSMutableString string];
    if (feeds.count > 0) {
        [strM appendString:@" and ("];
        NSInteger index = 0;
        for (NSString *url in feeds) {
            [strM appendFormat:@"feedUrl='%@'", url];
            if (index < feeds.count-1) {
                [strM appendString:@" or "];
            }
            index++;
        }
        [strM appendString:@")"];
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE isdelete=0 %@ ORDER by pubDate desc LIMIT %@, 10", tbName, strM.copy, @(page * 10)];
    NSArray *resuults = [[GRGreenRssDBHandle shareInstance] selectTableWithModel:[GRFeedItemModel class] tableName:tbName sql:sql];
    
    //过滤不喜欢
    NSArray *resultArrs = [self checkNolikeContainWithItems:resuults];
    
    if (resultArrs.count == 0) {
        if (complatiion) {
            complatiion(resultArrs);
        }
    }
    
    //查黑
    [GRRSSFeedDBHelper getResultListWithList:resultArrs type:type complation:^(NSArray * _Nullable modelList) {
        if (complatiion) {
            complatiion(modelList);
        }
    }];
}

// 查黑
+ (void)getResultListWithList:(NSArray*)list type:(HomeTypeCode)type complation:(ComplaItemBlack)complation{
    if (complation) {
        complation(list);
    }
}

+ (void)selectRecommendFeeds:(NSArray*)feeds type:(HomeTypeCode)type complatiion:(ComplaItemBlack)complatiion{
    NSString *tbName = @"";
    if (type == HOME_SUBLINE) {
        tbName = kFeedItem_User_TBName;
    } else if (type == HOME_RECOMMEND) {
        tbName = kFeedItem_Recommend_TBName;
    }
    
    NSMutableString *strM = [NSMutableString string];
    if (feeds.count > 0) {
        [strM appendString:@" and ("];
        NSInteger index = 0;
        for (NSString *url in feeds) {
            [strM appendFormat:@"feedUrl='%@'", url];
            if (index < feeds.count-1) {
                [strM appendString:@" or "];
            }
            index++;
        }
        [strM appendString:@")"];
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE isdelete=0 %@ ORDER by pubDate desc", tbName, strM.copy];
    NSArray *resuults = [[GRGreenRssDBHandle shareInstance] selectTableWithModel:[GRFeedItemModel class] tableName:tbName sql:sql];
        
    //过滤不喜欢
    NSArray *resultArrs = [self checkNolikeContainWithItems:resuults];
    
    //返回
    if (complatiion) {
        complatiion(resultArrs);
    }
}

//插入推荐列表
+ (void)insertRecommendOrSubWithFeedmodel:(GRFeedContentModel*)feedModel type:(HomeTypeCode)type{
    
    NSString *feedTbName = @"";
    NSString *itemTbName = @"";
    if (type == HOME_SUBLINE) {
        feedTbName = kFeeds_User_TBName;
        itemTbName = kFeedItem_User_TBName;
    } else if (type == HOME_RECOMMEND) {
        feedTbName = kFeeds_Recommend_TBName;
        itemTbName = kFeedItem_Recommend_TBName;
    }
    
    GRGreenRssDBHandle *dbManager = [GRGreenRssDBHandle shareInstance];
    NSArray *list = [dbManager selectTableWithModel:[feedModel class] tableName:feedTbName where:[NSString stringWithFormat:@"feedUrl='%@'", feedModel.feedUrl]];
    
    NSInteger fid = 0;
    if (list.count > 0) {
        GRFeedContentModel *oldFeedModel = list.firstObject;
        fid = oldFeedModel.fid;
        
        //保留需要的东西
        feedModel.title = oldFeedModel.title;
        feedModel.feedUrl = oldFeedModel.feedUrl;
        feedModel.createdDate = oldFeedModel.createdDate;
        feedModel.randomId = oldFeedModel.randomId;
        if (oldFeedModel.imageUrl.length> 0) {
            feedModel.imageUrl = oldFeedModel.imageUrl;
        }
        
        [dbManager updateTableWithModel:feedModel tableName:feedTbName where:[NSString stringWithFormat:@"fid=%zd", fid]];
    } else {
        [dbManager insertTableWithModel:feedModel tableName:feedTbName complete:nil];
        NSArray *list = [dbManager selectTableWithModel:[feedModel class] tableName:feedTbName where:[NSString stringWithFormat:@"feedUrl='%@'", feedModel.feedUrl]];
        if (list.count > 0) {
            fid = [list.firstObject fid];
        }
    }
    
    //items
    if (feedModel.item.count > 0) {
        NSLog(@"111111111111 ==> %zd, Date:%@", feedModel.item.count, [NSDate date]);
        
        NSDate *date1 = [NSDate date];
        [[GRGreenRssDBHandle shareInstance].dbManager beginTransaction];
        
        @try {
            for (GRFeedItemModel *itemModel in feedModel.item) {
                itemModel.feedId = fid;
                itemModel.feedUrl = feedModel.feedUrl;
                itemModel.tipImgUrl = feedModel.imageUrl;
                
                //判断是否存在
                NSString *sql = [NSString stringWithFormat:@"select iid from %@ where link = '%@'", itemTbName, itemModel.link];
                NSArray *lItems = [dbManager selectTableWithModel:[itemModel class] tableName:itemTbName sql:sql];
                if (lItems.count > 0) {
                    //GRFeedItemModel *lastModel = lItems.firstObject;
                    //[dbManager updateTableWithModel:itemModel tableName:itemTbName where:[NSString stringWithFormat:@"link='%@' and iid=%zd", itemModel.link, lastModel.iid]];
                } else {
                    [dbManager insertTableWithModel:itemModel tableName:itemTbName complete:nil];
                }
            }
        } @catch (NSException *exception) {
            
        } @finally {
            [[GRGreenRssDBHandle shareInstance].dbManager commit];
        }
        NSDate *date2 = [NSDate date];
        NSLog(@"111111111111 ==> Date:%@", [NSDate date]);
        
        NSTimeInterval b = [date2 timeIntervalSince1970] - [date1 timeIntervalSince1970];
        NSLog(@"使用事务插入条数据用时%.3f秒",b);
    }
}

+ (void)insertHomeWithList:(NSArray*)list type:(HomeTypeCode)type{
    //开始插入数据库
    [self insertFeedModelWithFeedList:list type:type];
}

+ (void)insertFeedModelWithFeedList:(NSArray*)feedList type:(HomeTypeCode)type{
    NSString *feedTbName = @"";
    if (type == HOME_SUBLINE) {
        feedTbName = kCollection_TBName;
    } else if (type == HOME_RECOMMEND) {
        feedTbName = kFeeds_Recommend_TBName;
    }
    
    NSDate *date1 = [NSDate date];
    NSMutableArray *itemM = [NSMutableArray array];
    [[GRGreenRssDBHandle shareInstance].dbManager beginTransaction];
    
    @try {
        for (GRFeedContentModel *feedModel in feedList) {
            GRGreenRssDBHandle *dbManager = [GRGreenRssDBHandle shareInstance];
            NSArray *list = [dbManager selectTableWithModel:[feedModel class] tableName:feedTbName where:[NSString stringWithFormat:@"feedUrl='%@'", feedModel.feedUrl]];
            
            if (list.count > 0) {
                GRFeedContentModel *oldFeedModel = list.firstObject;
                
                //保留需要的东西
                feedModel.title = oldFeedModel.title;
                feedModel.feedUrl = oldFeedModel.feedUrl;
                feedModel.createdDate = oldFeedModel.createdDate;
                feedModel.randomId = oldFeedModel.randomId;
                if (oldFeedModel.imageUrl.length> 0) {
                    feedModel.imageUrl = oldFeedModel.imageUrl;
                }
                
                [dbManager updateTableWithModel:feedModel tableName:feedTbName where:[NSString stringWithFormat:@"fid=%zd", oldFeedModel.fid]];
            } else {
                [dbManager insertTableWithModel:feedModel tableName:feedTbName complete:nil];
            }
            
            //获取图标和feed源
            for (GRFeedItemModel *itemModel in feedModel.item) {
                //图片和源
                itemModel.feedUrl = feedModel.feedUrl;
                itemModel.tipImgUrl = feedModel.imageUrl;
                
                //add
                [itemM addObject:itemModel];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        [[GRGreenRssDBHandle shareInstance].dbManager commit];
        
        //items
        [self insertItemModelWithItemList:itemM.copy type:type];
    }
    
    NSDate *date2 = [NSDate date];
    NSTimeInterval b = [date2 timeIntervalSince1970] - [date1 timeIntervalSince1970];
    NSLog(@"11111111111111 Feed => 用时%.3f秒", b);
}

//插入items
+ (void)insertItemModelWithItemList:(NSArray*)itemList type:(HomeTypeCode)type{
    NSString *itemTbName = @"";
    if (type == HOME_SUBLINE) {
        itemTbName = kFeedItem_User_TBName;
    } else if (type == HOME_RECOMMEND) {
        itemTbName = kFeedItem_Recommend_TBName;
    }
    
    NSDate *date1 = [NSDate date];
    [[GRGreenRssDBHandle shareInstance].dbManager beginTransaction];
    
    @try {
        for (GRFeedItemModel *itemModel in itemList) {
            
            //判断是否存在
            NSString *sql = [NSString stringWithFormat:@"select iid from %@ where link = '%@'", itemTbName, itemModel.link];
            NSArray *lItems = [[GRGreenRssDBHandle shareInstance] selectTableWithModel:[itemModel class] tableName:itemTbName sql:sql];
            if (lItems.count > 0) {
                GRFeedItemModel *lastModel = lItems.firstObject;
                [[GRGreenRssDBHandle shareInstance] updateTableWithModel:itemModel tableName:itemTbName where:[NSString stringWithFormat:@"link='%@' and iid=%zd", itemModel.link, lastModel.iid]];
            } else {
                [[GRGreenRssDBHandle shareInstance] insertTableWithModel:itemModel tableName:itemTbName complete:nil];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        [[GRGreenRssDBHandle shareInstance].dbManager commit];
    }
    
    NSDate *date2 = [NSDate date];
    NSTimeInterval b = [date2 timeIntervalSince1970] - [date1 timeIntervalSince1970];
    NSLog(@"11111111111111 Item => 用时%.3f秒", b);
}

//删除推荐列表
+ (void)deleteRecommendSelItemWithModel:(GRFeedItemModel*)itemModel  type:(HomeTypeCode)type{
    NSString *itemTbName = @"";
    if (type == HOME_SUBLINE) {
        itemTbName = kFeedItem_User_TBName;
    } else if (type == HOME_RECOMMEND) {
        itemTbName = kFeedItem_Recommend_TBName;
    }
    
    [[GRGreenRssDBHandle shareInstance] deleteUpsignWithTableName:itemTbName where:[NSString stringWithFormat:@"iid=%zd", itemModel.iid]];
    [self insertNoLikeWithItemModel:itemModel];
}

//批量删除
+ (void)deleteItemListWithList:(NSArray*)list type:(HomeTypeCode)type{
    
    NSDate *date1 = [NSDate date];
    [[GRGreenRssDBHandle shareInstance].dbManager beginTransaction];
    
    @try {
        for (GRFeedItemModel *itemModel in list) {
            [self deleteRecommendSelItemWithModel:itemModel type:type];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        [[GRGreenRssDBHandle shareInstance].dbManager commit];
    }
    
    NSDate *date2 = [NSDate date];
    NSTimeInterval b = [date2 timeIntervalSince1970] - [date1 timeIntervalSince1970];
    NSLog(@"11111111111111 Delete => 用时%.3f秒", b);
}

//查询我的订阅列表
+ (NSArray*)selectMySublineList{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", kFeeds_User_TBName];
    NSArray *list = [[GRGreenRssDBHandle shareInstance] selectTableWithModel:[GRFeedItemModel class] tableName:kFeeds_User_TBName sql:sql];
    
    return list;
}


//detail查询
+ (void)selectDetailFeedItemWIthPage:(NSUInteger)page andUrl:(NSString *)url complatiion:(ComplaItemBlack)complatiion{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where feedUrl = '%@' and isdelete=0 ORDER by pubDate desc LIMIT %@, 8",kFeedList_TBName,url, @(page * 8)];
    NSArray *list = [[GRGreenRssDBHandle shareInstance] selectTableWithModel:[GRFeedItemModel class] tableName:kFeedList_TBName sql:sql];
    
    NSArray *resultArrs = [self checkNolikeContainWithItems:list];
    
    if (resultArrs.count == 0) {
        if (complatiion) {
            complatiion(resultArrs);
        }
    }
    
    //查黑
    [GRRSSFeedDBHelper getResultListWithList:resultArrs type:HOME_DETAILS complation:^(NSArray * _Nullable modelList) {
        if (complatiion) {
            complatiion(modelList);
        }
    }];
}


//detail插入
+ (void)insertWithDetailFeedmodel:(GRFeedContentModel*)feedModel andUrl:(NSString *)url{
    GRGreenRssDBHandle *dbManager = [GRGreenRssDBHandle shareInstance];
    
    [[GRGreenRssDBHandle shareInstance].dbManager beginTransaction];
    
    @try {
        for (GRFeedItemModel *itemModel in feedModel.item) {
            //保留的值
            itemModel.feedUrl = url;
            if (feedModel.imageUrl.length > 0) {
                itemModel.tipImgUrl = feedModel.imageUrl;
            }
            
            //
            //判断是否存在
            NSArray *lItems = [dbManager selectTableWithModel:[itemModel class] tableName:kFeedList_TBName sql:[NSString stringWithFormat:@"select iid from %@ where link = '%@'", kFeedList_TBName, itemModel.link]];
            if (lItems.count > 0) {
                GRFeedItemModel *oldModel = lItems.firstObject;
                [dbManager updateTableWithModel:itemModel tableName:kFeedList_TBName where:[NSString stringWithFormat:@"link='%@' and iid=%zd", itemModel.link, oldModel.iid]];
            } else {
                [dbManager insertTableWithModel:itemModel tableName:kFeedList_TBName complete:nil];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        [[GRGreenRssDBHandle shareInstance].dbManager commit];
    }
}

//删除feedList 数据
+ (void)deleteDetailFeedItemWithModel:(GRFeedItemModel*)itemModel{
    [[GRGreenRssDBHandle shareInstance] deleteUpsignWithTableName:kFeedList_TBName where:[NSString stringWithFormat:@"iid=%zd", itemModel.feedId]];
    [self insertNoLikeWithItemModel:itemModel];
}



//不喜欢列表
+ (void)insertNoLikeWithItemModel:(GRFeedItemModel*)itemModel{
    [[GRGreenRssDBHandle shareInstance] insertTableWithModel:itemModel tableName:kNoLike_TBName complete:nil];
}


//检查数据是否在不喜欢列表中
+ (NSArray*)checkNolikeContainWithItems:(NSArray*)items{
    NSMutableArray *arrM = [NSMutableArray array];
    
    for (GRFeedItemModel *model in items) {
        NSArray *list = [[GRGreenRssDBHandle shareInstance] selectTableWithModel:[GRFeedItemModel class] tableName:kNoLike_TBName where:[NSString stringWithFormat:@"link='%@'", model.link]];
        if (list.count == 0) {
            [arrM addObject:model];
        }
    }
    
    return arrM.copy;
}


@end
