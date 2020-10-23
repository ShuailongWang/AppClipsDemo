//
//  GRFeedContentModel.m
//  GreenRSS
//
//  Created by wangshuailong on 2020/8/26.
//

#import "GRFeedContentModel.h"
#import <Ono/Ono.h>
#import <MJExtension/MJExtension.h>
#import "GTMBase64.h"

@implementation GRFeedContentModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
        @"item"   : [GRFeedItemModel class],
        @"author" : [GRFeedAuthorModel class],
    };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"item"    : @"items",
        @"details" : @"description",
        @"link"    : @"home_page_url",
    };
}

+ (GRFeedContentModel*)defauleFeedModel{
    GRFeedContentModel *feedModel = [[GRFeedContentModel alloc] init];
    feedModel.title = @"";
    feedModel.link = @"";
    feedModel.details = @"";
    feedModel.copyright = @"";
    feedModel.managingEditor = @"";
    feedModel.imageUrl = @"";
    feedModel.pubDate = @"";
    feedModel.feedUrl = @"";
    feedModel.randomId = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    feedModel.createdDate = [[NSDate date] timeIntervalSince1970];
    return feedModel;
}

//json
+ (GRFeedContentModel *)getFedListWithJsonDict:(NSDictionary *)jsonDict{
    GRFeedContentModel *feedModel = [GRFeedContentModel mj_objectWithKeyValues:jsonDict];
    feedModel.randomId = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    feedModel.createdDate = [[NSDate date] timeIntervalSince1970];
    return feedModel;
}


//xml
+ (GRFeedContentModel *)getFedListWithData:(NSData *)data{
    ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:data error:nil];
        
    //model
    GRFeedContentModel *feedModel = [GRFeedContentModel defauleFeedModel];
    
    //解析
    NSMutableArray *itemArray = [NSMutableArray array];
    for (ONOXMLElement *element in document.rootElement.children) {
        //rss
        if ([element.tag isEqualToString:@"channel"]) {
            for (ONOXMLElement *channelChild in element.children) {
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"title"]) {
                    feedModel.title = [self removeSpaceAndNewline:channelChild.stringValue];
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"link"]) {
                    feedModel.link = [self removeSpaceAndNewline:channelChild.stringValue];
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"description"]) {
                    feedModel.details = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"copyright"]) {
                    feedModel.copyright = [self removeSpaceAndNewline:channelChild.stringValue];
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"managingEditor"]) {
                    feedModel.managingEditor = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"pubdate"] ||
                    [self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"lastBuildDate"] ) {
                    feedModel.pubDate = [self removeSpaceAndNewline:channelChild.stringValue];
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"image"]) {
                    for (ONOXMLElement *channelImage in channelChild.children) {
                        if ([self isEqualToWithDoNotCareLowcaseString:channelImage.tag compareString:@"url"]) {
                            if (channelImage.stringValue.length > 0) {
                                feedModel.imageUrl = [self removeSpaceAndNewline:channelImage.stringValue];;
                            }
                        }
                    }
                }
                
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"item"]) {
                    GRFeedItemModel *itemModel = [[GRFeedItemModel alloc] init];
                    for (ONOXMLElement *channelItem in channelChild.children) {
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"title"]) {
                            itemModel.title = [self removeSpaceAndNewline:channelItem.stringValue];
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"link"]) {
                            itemModel.link = [self removeSpaceAndNewline:channelItem.stringValue];
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"author"] ||
                            [self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"creator"] ||
                            [self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"copyright"]) {
                            itemModel.author = [self removeSpaceAndNewline:channelItem.stringValue];
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"category"]) {
                            itemModel.category = [self removeSpaceAndNewline:channelItem.stringValue];
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"pubdate"]) {
                            itemModel.pubDate = [self removeSpaceAndNewline:channelItem.stringValue];;
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"description"]) {
                            itemModel.details = channelItem.stringValue;
                            //图片
                            if (itemModel.iconUrl.length == 0) {
                                itemModel.iconUrl = [self getImgWithContent:itemModel.details];
                            }
                            //简介
                            if (itemModel.brief.length == 0) {
                                itemModel.brief = [self removeTheHtmlFromString:itemModel.details];
                            }
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"source"]) {
                            itemModel.source = [self removeSpaceAndNewline:channelItem.stringValue];
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"encoded"]) {  //content:encoded
                            itemModel.content = channelItem.stringValue;
                            
                            //图片
                            if (itemModel.iconUrl.length == 0) {
                                itemModel.iconUrl = [self getImgWithContent:itemModel.details];
                            }
                            if (itemModel.iconUrl.length == 0) {
                                itemModel.iconUrl = [self getImgWithContent:itemModel.content];
                            }
                            
                            //简介
                            if (itemModel.content.length > 0) {
                                itemModel.brief = [self removeTheHtmlFromString:itemModel.content];
                            }
                        }
                    }
                    
                    //判读是否有o作者
                    if (itemModel.author.length == 0) {
                        itemModel.author = feedModel.title;
                    }
                    
                    //添加
                    [itemArray addObject:itemModel];
                }
            }
        }
        
        //atom类型的处理
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"title"]) {
            feedModel.title = element.stringValue;
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"subtitle"]) {
            feedModel.details = element.stringValue;
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"link"]) {
            feedModel.link = (NSString *)[element valueForAttribute:@"href"];
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"rights"]) {
            feedModel.copyright = element.stringValue;
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"published"]) {
            feedModel.pubDate = element.stringValue;
        }
        if ([element.tag isEqualToString:@"entry"]) {
            GRFeedItemModel *itemModel = [[GRFeedItemModel alloc] init];
            for (ONOXMLElement *entryChild in element.children) {
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"title"]) {
                    itemModel.title = entryChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"link"]) {
                    itemModel.link = (NSString *)[entryChild valueForAttribute:@"href"];
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"author"]) {
                    for (ONOXMLElement *authorChild in entryChild.children) {
                        if ([self isEqualToWithDoNotCareLowcaseString:authorChild.tag compareString:@"name"]) {
                            if (authorChild.stringValue.length > 0) {
                                itemModel.author = authorChild.stringValue;
                            }
                        }
                    }
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"updated"]) {
                    itemModel.pubDate = entryChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"content"]) {
                    itemModel.details = entryChild.stringValue;
                    
                    //图片
                    if (itemModel.iconUrl.length == 0) {
                        itemModel.iconUrl = [self getImgWithContent:itemModel.details];
                    }
                    //简介
                    if (itemModel.brief.length == 0) {
                        itemModel.brief = [self removeTheHtmlFromString:itemModel.details];
                    }
                }
                //youtube
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"videoId"]) {
                    itemModel.videoId = entryChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"channelId"]) {
                    itemModel.channelId = entryChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"group"]) {
                    for (ONOXMLElement *groupChild in entryChild.children) {
                        if ([self isEqualToWithDoNotCareLowcaseString:groupChild.tag compareString:@"thumbnail"]) {
                            itemModel.iconUrl = (NSString *)[groupChild valueForAttribute:@"url"];
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:groupChild.tag compareString:@"description"]) {
                            itemModel.details = groupChild.stringValue;
                            itemModel.brief = itemModel.details;
                        }
                        
                        //数量
                        if ([self isEqualToWithDoNotCareLowcaseString:groupChild.tag compareString:@"community"]) {
                            for (ONOXMLElement *communChild in groupChild.children) {
                                if ([self isEqualToWithDoNotCareLowcaseString:communChild.tag compareString:@"statistics"]) {
                                    NSDictionary *dict = communChild.attributes;
                                    NSArray *allKeys = communChild.attributes.allKeys;
                                    NSString *statistics = (NSString*)[dict objectForKey:allKeys.firstObject];
                                    
                                    itemModel.statistics = [[NSMutableString stringWithFormat:@"%@", statistics] copy];
                                }
                            }
                        }
                    }
                }
            }
            //添加
            [itemArray addObject:itemModel];
        }
    }
    
    feedModel.item = itemArray.copy;
    
    if (feedModel.title.length == 0 && feedModel.link.length == 0) {
        return nil;
    }
    
    return feedModel;
}



#pragma mark - Helper
+ (BOOL)isEqualToWithDoNotCareLowcaseString:(NSString *)string compareString:(NSString *)compareString {
    if ([string.lowercaseString isEqualToString:compareString.lowercaseString]) {
        return YES;
    }
    return NO;
}

//获取内容的第一张图片
+ (NSString *)getImgWithContent:(NSString*)html{
    if (html.length == 0) {
        return @"";
    }
    
    NSString *imgUrl = @"";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<(img|IMG)(.*?)(/>|>|>)" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    
    NSArray *result = [regex matchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(0, html.length)];
    if (result.count > 0) {
        NSTextCheckingResult *item = result.firstObject;
        NSString *imgHtml = [html substringWithRange:[item rangeAtIndex:0]];
        
        NSArray *tmpArray = nil;
        if ([imgHtml rangeOfString:@"src=\""].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src=\""];
        } else if ([imgHtml rangeOfString:@"src="].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src="];
        }
        if (tmpArray.count >= 2) {
            NSString *src = tmpArray[1];
            NSUInteger loc = [src rangeOfString:@"\""].location;
            
            if (loc != NSNotFound) {
                imgUrl = [src substringToIndex:loc];
            }
        }
    }
    
    NSArray *urlList = [imgUrl componentsSeparatedByString:@"?"];
    NSString *urlStr = urlList.firstObject;
    
    return urlStr;
}

//去掉标签
+ (NSString *)removeTheHtmlFromString:(NSString *)htmlString {
    if (htmlString.length == 0) {
        return @"";
    }
    //去掉html标签
    NSScanner * scanner = [NSScanner scannerWithString:htmlString];
    NSString * text = nil;
    while([scanner isAtEnd]==NO) {
        @autoreleasepool {
            //找到标签的起始位置
            [scanner scanUpToString:@"<" intoString:nil];
            //找到标签的结束位置
            [scanner scanUpToString:@">" intoString:&text];
            //替换字符
            htmlString = [htmlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
        }
    }
    //去掉换行
    @autoreleasepool {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    return htmlString;
}

//去除字符串首尾的空格和换行符
+ (NSString *)removeSpaceAndNewline:(NSString*)string{
    NSString *temp = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *text = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    return text;
}


#pragma mark - Upload

// 获取云端的订阅列表
+ (void)getDownSUblineWithList:(NSArray*)list{

}

//把本地表数据插入到用户表中
+ (void)addLoaceToUserTable{

}


// 获取订阅列表，同步云端
+ (NSString*)getUpdateSublineJson{
    return @"";
}


@end

@implementation GRFeedItemModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"details" : @"content_html",
        @"pubDate" : @"date_published",
        @"link"    : @"url",
    };
}



+ (GRFeedItemModel*)defaultMyCollectionModel{
    GRFeedItemModel *model = [[GRFeedItemModel alloc] init];
    model.title = @"";
    model.link = @"";
    model.brief = @"";
    model.author = @"";
    model.pubDate = @"";
    model.iconUrl = @"";
    model.feedUrl = @"";
    model.videoId = @"";
    model.channelId = @"";
    model.randomId = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    model.createdDate = [[NSDate date] timeIntervalSince1970];
    return model;
}


// 获取云端的收藏列表, 保存到用户表中
+ (void)getDownCollectionWithList:(NSArray*)list{

}

//本地数据同步到用户表中
+ (void)addLocalSubToUserTable{

}


// 获取收藏列表，同步云端
+ (NSString *)getUpdateCollectionJson{
    return @"";
}





@end

@implementation GRFeedAuthorModel

@end
