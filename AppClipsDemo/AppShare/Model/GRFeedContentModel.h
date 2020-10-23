//
//  GRFeedContentModel.h
//  GreenRSS
//
//  Created by wangshuailong on 2020/8/26.
//

#import "GRBaseDBModel.h"

NS_ASSUME_NONNULL_BEGIN

@class GRFeedAuthorModel;
@interface GRFeedContentModel : GRBaseDBModel

@property (nonatomic, assign) NSUInteger fid;           //ID
@property (nonatomic, copy) NSString *title;            //名称
@property (nonatomic, copy) NSString *link;             //链接
@property (nonatomic, copy) NSString *feedUrl;          //feed源
@property (nonatomic, copy) NSString *details;          //简介
@property (nonatomic, copy) NSString *copyright;        //版权
@property (nonatomic, copy) NSString *managingEditor;   //
@property (nonatomic, copy) NSString *imageUrl;         //图标
@property (nonatomic, copy) NSString *pubDate;          //日期
@property (nonatomic, copy) NSString *randomId;         //随机数
@property (nonatomic, assign) double createdDate;       //创建时间
@property (nonatomic, strong) GRFeedAuthorModel *author;
@property (nonatomic, strong) NSArray *item;            //列表

+ (GRFeedContentModel*)defauleFeedModel;

//json
+ (GRFeedContentModel *)getFedListWithData:(NSData*)data;
//xml
+ (GRFeedContentModel *)getFedListWithJsonDict:(NSDictionary*)jsonDict;


// 获取云端的订阅列表
+ (void)getDownSUblineWithList:(NSArray*)list;

// 获取订阅列表，同步云端
+ (NSString*)getUpdateSublineJson;

@end

@interface GRFeedItemModel : GRBaseDBModel

@property (nonatomic, assign) NSUInteger iid;       //id
@property (nonatomic, assign) NSUInteger feedId;    //父ID
@property (nonatomic, copy) NSString *videoId;      //视频id
@property (nonatomic, copy) NSString *channelId;    //频道id
@property (nonatomic, copy) NSString *title;        //标题
@property (nonatomic, copy) NSString *link;         //链接
@property (nonatomic, copy) NSString *brief;        //简介
@property (nonatomic, copy) NSString *details;      //内容
@property (nonatomic, copy) NSString *content;      //内容
@property (nonatomic, copy) NSString *category;     //分类
@property (nonatomic, copy) NSString *author;       //作者
@property (nonatomic, copy) NSString *pubDate;      //日期
@property (nonatomic, copy) NSString *iconUrl;      //图标
@property (nonatomic, copy) NSString *tipImgUrl;    //图标
@property (nonatomic, copy) NSString *source;       //来源
@property (nonatomic, copy) NSString *feedUrl;      //博客feed的链接
@property (nonatomic, copy) NSString *randomId;     //随机数
@property (nonatomic, copy) NSString *statistics;   //
@property (nonatomic, assign) double createdDate;   //创建时间


+ (GRFeedItemModel*)defaultMyCollectionModel;

// 获取云端的收藏列表, 保存到用户表中
+ (void)getDownCollectionWithList:(NSArray*)list;

// 获取收藏列表，同步云端
+ (NSString *)getUpdateCollectionJson;

@end

@interface GRFeedAuthorModel : GRBaseDBModel

@property (nonatomic, copy) NSString *name;       //
@property (nonatomic, copy) NSString *url;        //
@property (nonatomic, copy) NSString *avatar;     //

@end

NS_ASSUME_NONNULL_END
