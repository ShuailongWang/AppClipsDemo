//
//  GRHTTPFeedManager.m
//  GreenRSS
//
//  Created by wangshuailong on 2020/9/21.
//

#import "GRHTTPFeedManager.h"

@interface GRHTTPFeedManager() <NSURLSessionDelegate>

@end

@implementation GRHTTPFeedManager

+ (instancetype)shareInstance{
    static GRHTTPFeedManager *_manager = nil;
    static dispatch_once_t __onceToken;
    dispatch_once(&__onceToken, ^{
        _manager = [[GRHTTPFeedManager alloc] init];
    });
    return _manager;
}


- (NSURLSessionDataTask *)getRequestWithUrl:(NSString*)url complation:(FeedComplationBlack)complation{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.connectionProxyDictionary = @{};

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    //
    self.sessionManager = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
    
    //
    NSMutableURLRequest *requestM = [[NSMutableURLRequest alloc] init];
    [requestM setURL:[NSURL URLWithString:url]];
    [requestM setHTTPMethod:@"GET"];
    requestM.timeoutInterval = 15;
    
    //request
    NSURLSessionDataTask *task = [self.sessionManager dataTaskWithRequest:requestM completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (complation) {
            complation(error, data, response);
        }
        if (error) {
            NSLog(@"error == > %@", error);
        }
    }];
    [task resume];
    
    return task;
}


@end
