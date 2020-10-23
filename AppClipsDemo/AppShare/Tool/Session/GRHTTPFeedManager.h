//
//  GRHTTPFeedManager.h
//  GreenRSS
//
//  Created by wangshuailong on 2020/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FeedComplationBlack)(NSError *__nullable error, id __nullable responseObject, NSURLResponse * _Nullable response);

@interface GRHTTPFeedManager : NSObject

@property (nonatomic, strong) NSURLSession *sessionManager;

+ (instancetype)shareInstance;

- (NSURLSessionDataTask *)getRequestWithUrl:(NSString*)url complation:(FeedComplationBlack)complation;

@end

NS_ASSUME_NONNULL_END
