//
//  GRFeedAPIManager.m
//  GreenRSS
//
//  Created by wangshuailong on 2020/8/26.
//

#import "GRFeedAPIManager.h"
#import "GRHTTPFeedManager.h"

@interface GRFeedAPIManager()

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, assign) BOOL isCancel;

@end

@implementation GRFeedAPIManager

+ (GRFeedAPIManager *)shareInstance{
    static GRFeedAPIManager *_manager = nil;
    static dispatch_once_t __onceToken;
    dispatch_once(&__onceToken, ^{
        _manager = [[GRFeedAPIManager alloc] init];
    });
    return _manager;
}

- (void)fetchAllFeedWithModelArray:(NSArray *)listArray type:(HomeTypeCode)type complation:(ComplationTaskBlack)complation{
    if (listArray.count == 0) {
        if (complation) {
            complation();
        }
        return;
    }
    
    dispatch_queue_t fetchFeedQueue = dispatch_queue_create("com.star.fetchfeed.fetchfeed", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray *list = [NSMutableArray array];
    self.isCancel = NO;
    
    for (NSString *url in listArray) {
        if (self.isCancel) {
            return;
        }
        
        if (url.length > 0) {
            dispatch_group_enter(group);
            
            NSString *newUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            @autoreleasepool {
                newUrl = [newUrl stringByReplacingOccurrencesOfString:@" " withString:@""];  //去空格
            }
            [[GRHTTPFeedManager shareInstance] getRequestWithUrl:newUrl complation:^(NSError * _Nullable error, id  _Nullable responseObject, NSURLResponse * _Nullable response) {
                if (error) {
                    NSLog(@"Error: %@", error);
                }
                dispatch_async(fetchFeedQueue, ^{
                    GRFeedContentModel *feedModel = [self getModelWithResponse:responseObject];
                    feedModel.feedUrl = url;
                    
                    //
                    if (feedModel) {
                        [list addObject:feedModel];
                    }
                    
                    dispatch_group_leave(group);
                });
            }];
        }
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //
        [GRRSSFeedDBHelper insertHomeWithList:list type:type];

        if (complation) {
            complation();
        }
    });
}

- (void)fecthGetListWithUrl:(NSString*)url imgUrl:(NSString*)imgUrl complation:(ComplFeedBlack)complation{
    if (url.length == 0) {
        return;
    }
    
    NSString *newUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    @autoreleasepool {
        newUrl = [newUrl stringByReplacingOccurrencesOfString:@" " withString:@""];  //去空格
    }
    self.task = [[GRHTTPFeedManager shareInstance] getRequestWithUrl:newUrl complation:^(NSError * _Nullable error, id  _Nullable responseObject, NSURLResponse * _Nullable response) {
        
        if (error) {
            NSLog(@"error = %@", error);
            if (complation) {
                complation(nil, error);
            }
        } else {
            dispatch_queue_t fetchFeedQueue = dispatch_queue_create("get.fetchfeed.fetchfeed", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(fetchFeedQueue, ^{
                
                GRFeedContentModel *feedModel = [self getModelWithResponse:responseObject];
                feedModel.imageUrl = imgUrl;
                if (feedModel) {
                    [GRRSSFeedDBHelper insertWithDetailFeedmodel:feedModel andUrl:url];
                }
                
                //
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complation) {
                        complation(feedModel, nil);
                    }
                });
            });
        }
    }];
}

- (void)cancel{
    if (self.task) {
        if (self.task.state == NSURLSessionTaskStateRunning) {
            [self.task cancel];
            self.task = nil;
        }
    }
}

- (void)cancelAll{
    [[GRHTTPFeedManager shareInstance].sessionManager getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> * _Nonnull tasks) {
        for (NSURLSessionTask *task in tasks) {
            if (task.state == NSURLSessionTaskStateRunning) {
                [task cancel];
            }
        }
    }];
}

- (void)dealloc{
    NSLog(@"dealloc__dealloc");
}

#pragma mark - Helper
//解析model
- (GRFeedContentModel *)getModelWithResponse:(id  _Nullable)responseObject{
    if (nil == responseObject) {
        return nil;
    }
    
    GRFeedContentModel *feedModel;
    
    //判断一下json/xml
    NSData *responData = (NSData*)responseObject;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responData options:NSJSONReadingMutableContainers error:nil];
    if (resultDict) {
        feedModel = [GRFeedContentModel getFedListWithJsonDict:resultDict];
    } else {
        feedModel = [GRFeedContentModel getFedListWithData:responseObject];
    }
    return feedModel;
}

@end
