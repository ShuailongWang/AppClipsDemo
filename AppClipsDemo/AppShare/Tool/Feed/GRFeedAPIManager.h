//
//  GRFeedAPIManager.h
//  GreenRSS
//
//  Created by wangshuailong on 2020/8/26.
//

#import <UIKit/UIKit.h>
#import "GRRSSFeedDBHelper.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ComplationTaskBlack)(void);
typedef void(^ComplFeedBlack)(GRFeedContentModel * _Nullable feedModel, NSError * _Nullable error);

@interface GRFeedAPIManager : NSObject

+ (GRFeedAPIManager *)shareInstance;

- (void)fetchAllFeedWithModelArray:(NSArray *)listArray type:(HomeTypeCode)type complation:(ComplationTaskBlack)complation;
- (void)fecthGetListWithUrl:(NSString*)url imgUrl:(NSString*)imgUrl complation:(ComplFeedBlack)complation;

- (void)cancel;
- (void)cancelAll;

@end

NS_ASSUME_NONNULL_END
