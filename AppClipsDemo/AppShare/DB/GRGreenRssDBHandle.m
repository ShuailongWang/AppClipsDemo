//
//  GRGreenRssDBHandle.m
//  GreenRSS
//
//  Created by wangshuailong on 2020/8/28.
//

#import "GRGreenRssDBHandle.h"
#import <FMDB/FMDB.h>
#import "GRBaseDBModel.h"

#define PATH_OF_DOCUMENT        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define kSQL_PathName           @"GrenRSS"
#define kSQL_New_PathName       @".GrenRSS"
#define kSQL_DBName             @"GrenRSS.db"

#define kCellTBName             @"TBNAME"
#define kCellTBCreatSql         @"TBCREATSQL"
#define kCellTBALTERSql         @"TBALTERSQL"

static const NSInteger dbversion = 7;

@interface GRGreenRssDBHandle()

@property (strong, nonatomic) NSOperationQueue *dbQueue;
@property (strong, nonatomic) NSArray *tbList;

@end

@implementation GRGreenRssDBHandle

+ (instancetype)shareInstance{
    static GRGreenRssDBHandle *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GRGreenRssDBHandle alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        self.dbQueue = [[NSOperationQueue alloc] init];
        [self.dbQueue setMaxConcurrentOperationCount:1];
        
        [self creatTable];
    }
    return self;
}

- (void)creatTable{
    //判断文件是否存在
    NSString *path = [PATH_OF_DOCUMENT stringByAppendingPathComponent:kSQL_PathName];
    NSString *newPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:kSQL_New_PathName];
    
    //判断老文件夹是否存在，不存在创建新的路径文件夹
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        //创建一个隐藏的文件夹
        if ([[NSFileManager defaultManager] fileExistsAtPath:newPath] == NO) {
            [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    } else {
        //创建一个隐藏的文件夹
        if ([[NSFileManager defaultManager] fileExistsAtPath:newPath] == NO) {
            [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //如果老文件夹存在，把老文件夹中的所有文件移动新路径中
        NSArray *subPaths = [[NSFileManager defaultManager] subpathsAtPath:path];
        for (NSString *pathUrl in subPaths) {
            NSString *oldUrl = [NSString stringWithFormat:@"%@/%@", path, pathUrl];
            NSString *newUrl = [NSString stringWithFormat:@"%@/%@", newPath, pathUrl];
            
            NSError *error;
            [[NSFileManager defaultManager] moveItemAtPath:oldUrl toPath:newUrl error:&error];
            if (error) {
                NSLog(@"error => %@", error);
            }
        }
        
        //没有文件后删除
        if (subPaths.count == 0) {
            NSError *error;
            BOOL del = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:path] error:&error];
            NSLog(@"删除%@:%@", del ? @"成功" : @"失败", error);
        }
    }
    
    //数据库路径
    NSString *dbPath = [newPath stringByAppendingPathComponent:kSQL_DBName];
    
    self.dbManager = [FMDatabase databaseWithPath:dbPath];
    if ([self.dbManager open]) {
        [self initDataDBTable];
    }
}

- (NSArray *)tbList{
    if (!_tbList) {
        _tbList = @[
            //推荐feed列表
            @{
                kCellTBName:kFeeds_Recommend_TBName,
                kCellTBCreatSql:[NSString stringWithFormat:@"create table %@ (fid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,\
                                 title text,\
                                 link text,\
                                 imageUrl text,\
                                 details text,\
                                 copyright text,\
                                 managingEditor text,\
                                 feedUrl text, \
                                 pubDate integer, \
                                 randomId text, \
                                 createdDate integer)", kFeeds_Recommend_TBName],
                kCellTBALTERSql:@"",
            },
            
            //推荐feed流内容
            @{
                kCellTBName:kFeedItem_Recommend_TBName,
                kCellTBCreatSql:[NSString stringWithFormat:@"create table %@ (iid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,\
                                 feedId integer, \
                                 videoId text, \
                                 channelId text, \
                                 title text, \
                                 link text, \
                                 feedUrl text, \
                                 brief text, \
                                 details text,\
                                 category text, \
                                 author text, \
                                 pubDate text, \
                                 iconUrl text, \
                                 tipImgUrl text,\
                                 statistics text,\
                                 isdelete integer DEFAULT 0, \
                                 source text)", kFeedItem_Recommend_TBName],
                kCellTBALTERSql:@"statistics text",
            },
            //用户的订阅表
            @{
                kCellTBName:kFeeds_User_TBName,
                kCellTBCreatSql:[NSString stringWithFormat:@"create table %@ (fid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,\
                                 title text,\
                                 link text,\
                                 imageUrl text,\
                                 details text,\
                                 copyright text,\
                                 managingEditor text,\
                                 feedUrl text, \
                                 pubDate integer, \
                                 randomId text, \
                                 createdDate integer)", kFeeds_User_TBName],
                kCellTBALTERSql:@"",
                
            },
            //用户的订阅流内容
            @{
                kCellTBName:kFeedItem_User_TBName,
                kCellTBCreatSql:[NSString stringWithFormat:@"create table %@ (iid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,\
                                 feedId integer, \
                                 videoId text, \
                                 channelId text, \
                                 title text, \
                                 feedUrl text, \
                                 link text, \
                                 brief text, \
                                 details text,\
                                 category text, \
                                 author text, \
                                 pubDate text, \
                                 iconUrl text, \
                                 tipImgUrl text,\
                                 statistics text,\
                                 isdelete integer DEFAULT 0, \
                                 source text)", kFeedItem_User_TBName],
                kCellTBALTERSql:@"statistics text",
            },
            //收藏表
            @{
                kCellTBName:kCollection_TBName,
                kCellTBCreatSql:[NSString stringWithFormat:@"create table %@ (iid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,\
                                 title text, \
                                 link text, \
                                 brief text, \
                                 author text, \
                                 pubDate text, \
                                 iconUrl text, \
                                 feedUrl text, \
                                 tipImgUrl text,\
                                 videoId text,\
                                 statistics text,\
                                 createdDate integer)", kCollection_TBName],
                kCellTBALTERSql:@"tipImgUrl text,videoId text,statistics text",
            },
            //详情页fedd表
            @{
                kCellTBName:kFeedList_TBName,
                kCellTBCreatSql:[NSString stringWithFormat:@"create table %@ (iid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,\
                                 feedId integer, \
                                 videoId text, \
                                 channelId text, \
                                 title text, \
                                 link text, \
                                 brief text, \
                                 details text,\
                                 category text, \
                                 author text, \
                                 pubDate text, \
                                 iconUrl text, \
                                 isdelete integer DEFAULT 0, \
                                 feedUrl text, \
                                 tipImgUrl text,\
                                 statistics text,\
                                 source text)", kFeedList_TBName],
                kCellTBALTERSql:@"statistics text",
            },
            //不喜欢列表
            @{
                kCellTBName:kNoLike_TBName,
                kCellTBCreatSql:[NSString stringWithFormat:@"create table %@ (iid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,\
                                 feedId integer, \
                                 videoId text, \
                                 channelId text, \
                                 title text, \
                                 link text, \
                                 brief text, \
                                 details text,\
                                 category text, \
                                 author text, \
                                 pubDate text, \
                                 iconUrl text, \
                                 isdelete integer DEFAULT 0, \
                                 feedUrl text, \
                                 source text)", kNoLike_TBName],
                kCellTBALTERSql:@"",
            },
            //下载
            @{
                kCellTBName:kDown_TBName,
                kCellTBCreatSql:[NSString stringWithFormat:@"create table %@ (fid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,\
                                 downloadUrl text, \
                                 downloadCookie text, \
                                 downloadFileName text, \
                                 downloadType text, \
                                 downloadMd5 text, \
                                 downloadFilePath text, \
                                 downloadAlreadySize integer, \
                                 downloadTotleSize integer, \
                                 createdDate integer, \
                                 downloadStatus integer, \
                                 downloadRead integer, \
                                 downloadIsZip integer, \
                                 isSaved integer, \
                                 downloadIsZipDeleted integer, \
                                 downloadDate integer)", kDown_TBName],
                kCellTBALTERSql:@"",
            }
        ];
    }
    return _tbList;
}

- (void)initDataDBTable{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        uint32_t oldVer = [self.dbManager userVersion];
        if (oldVer < dbversion) {
            [self.dbManager beginTransaction];
            //版本号判断
            if (oldVer < dbversion) {
                //遍历表
                for (NSDictionary *tbDict in self.tbList) {
                    NSString *tbName = [tbDict objectForKey:kCellTBName];
                    NSString *tbCreatSql = [tbDict objectForKey:kCellTBCreatSql];
                    NSString *tbAddStr = [tbDict objectForKey:kCellTBALTERSql];
                    
                    //判断表是否存在
                    if ([self.dbManager tableExists:tbName]) {
                        //存在，判断是否需要更新字段
                        if (tbAddStr.length > 0) {
                            //获取字段
                            NSArray *listArr = [tbAddStr componentsSeparatedByString:@","];
                            for (NSString *result in listArr) {
                                NSArray *cloArr = [result componentsSeparatedByString:@" "];
                                NSString *colName = cloArr.firstObject;
                                
                                //判断字段是否存在
                                if ([self.dbManager columnExists:colName inTableWithName:tbName] == NO) {
                                    NSString *tabSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@", tbName, result];
                                    [self.dbManager executeUpdate:tabSql];
                                }
                            }
                        }
                    } else {
                        //不存在，创建表
                        [self.dbManager executeUpdate:tbCreatSql];
                    }
                }
                
                oldVer++;
            }
            
            [self.dbManager commit];
            [self.dbManager setUserVersion:oldVer];
        }
    }];
    
    [self.dbQueue addOperation:operation];
}


- (void)execQueryBlock:(void(^)(void))block {
    if ([[NSOperationQueue currentQueue] isEqual:self.dbQueue]) {
        block();
    } else {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
        [self.dbQueue addOperations:@[operation] waitUntilFinished:YES];
    }
}

//是否有订阅表
- (void)isHasUserSubTableWithTableName:(NSString*)tableName{
    if ([self checkTableName:tableName] == NO) {
        return;
    }
    
    //判断是否有表，没有创建表
    if ([self.dbManager tableExists:tableName] == NO) {
        NSString *feedSql = [NSString stringWithFormat:@"create table %@ (fid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,\
                             title text,\
                             link text,\
                             imageUrl text,\
                             details text,\
                             copyright text,\
                             managingEditor text,\
                             feedUrl text, \
                             pubDate integer, \
                             randomId text, \
                             createdDate integer)", tableName];
        [self.dbManager executeUpdate:feedSql];
    } else {
        //是否更新字段
    }
}

//是否有收藏表
- (void)isHasUserColTableWithTableName:(NSString*)tableName{
    if ([self checkTableName:tableName] == NO) {
        return;
    }
    
    //判断是否有表，没有创建表
    if ([self.dbManager tableExists:tableName] == NO) {
        NSString *itemSql = [NSString stringWithFormat:@"create table %@ (iid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,\
                             title text, \
                             link text, \
                             brief text, \
                             author text, \
                             pubDate text, \
                             iconUrl text, \
                             feedUrl text, \
                             tipImgUrl text,\
                             videoId text, \
                             statistics text, \
                             createdDate integer)", tableName];
        [self.dbManager executeUpdate:itemSql];
    } else {
        NSString *tbAddStr = @"tipImgUrl text,videoId text,statistics text";
        NSArray *listArr = [tbAddStr componentsSeparatedByString:@","];
        for (NSString *result in listArr) {
            NSArray *cloArr = [result componentsSeparatedByString:@" "];
            NSString *colName = cloArr.firstObject;
            
            //判断是否更新字段
            if ([self.dbManager columnExists:colName inTableWithName:tableName] == NO) {
                NSString *tabSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@", tableName, result];
                [self.dbManager executeUpdate:tabSql];
            }
        }
    }
}

//检查表是否存在
- (BOOL)checkTableName:(NSString*)tableName{
    if (tableName == nil || tableName.length == 0) {
        return NO;
    }
    return YES;
}

//查询
- (NSArray *)selectTableWithModel:(Class)model tableName:(NSString*)tableName sql:(NSString*)sql{
    if ([self checkTableName:tableName] == NO) {
        return nil;
    }
    NSMutableArray *arrM = [NSMutableArray array];
    if (self.dbManager) {
        [self execQueryBlock:^{
            FMResultSet *rs = [self.dbManager executeQuery:sql];
            while ([rs next]) {
                GRBaseDBModel *object = [[model alloc] init];
                Class entityClass = model;
                //根据查出来的数据转模型
                while ([entityClass isSubclassOfClass:([GRBaseDBModel class])]) {
                    unsigned int propertyCount = 0;
                    objc_property_t *properties = class_copyPropertyList(entityClass, &propertyCount);
                    for (int i = 0; i < propertyCount; i++) {
                        objc_property_t *property = properties++;
                        const char* propertyName = property_getName(*property);
                        NSString *propertyNameString = [NSString stringWithUTF8String:propertyName];
                        if (![[rs columnNameToIndexMap] objectForKey:[propertyNameString lowercaseString]]) {
                            continue;
                        }
                        
                        id valueForProperty = [self genValueByAttribute:*property withSet:rs];
                        if (valueForProperty) {
                            [object setValue:valueForProperty forKey:propertyNameString];
                        }
                    }
                    entityClass = [entityClass superclass];
                }
                [arrM addObject:object];
            }
            [rs close];
        }];
    }
    
    return arrM.copy;
}

- (NSArray *)selectTableWithModel:(Class)model tableName:(NSString*)tableName where:(NSString*)predicate{
    if ([self checkTableName:tableName] == NO) {
        return nil;
    }
    
    NSString *predicateString = @"";
    if (predicate) {
        predicateString = [NSString stringWithFormat:@"WHERE %@", predicate];
    }
    NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ %@", tableName, predicateString];
    
    NSArray *array = [self selectTableWithModel:model tableName:tableName sql:query];
    
    return array;
}


//插入
- (void)insertTableWithModel:(GRBaseDBModel*)model tableName:(NSString*)tableName complete:(dbSelComplete)complete{
    
    if (self.dbManager) {
        [self execQueryBlock:^{
            NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT INTO %@", tableName];
            
            // 拼接要插入的数据 SQL
            NSMutableString *keys = [NSMutableString stringWithFormat:@" ("];
            NSMutableString *values = [NSMutableString stringWithFormat:@" ("];
            NSMutableArray *arguments = [NSMutableArray array];
            
            Class entityClass = [model class];
            while ([entityClass isSubclassOfClass:([GRBaseDBModel class])]) {
                unsigned int propertyCount = 0;
                objc_property_t *properties = class_copyPropertyList(entityClass, &propertyCount);
                for (int i = 0; i < propertyCount; i++) {
                    objc_property_t *property = properties++;
                    const char* propertyName = property_getName(*property);
                    NSString *propertyNameString = [NSString stringWithUTF8String:propertyName];
                    
                    //获取属性和数据
                    id tmpValue = [model valueForKey:propertyNameString];
                    id valueForProperty = [self formularValue:(*property) withValue:tmpValue];
                    
                    if (valueForProperty) {
                        NSString *propStr = [NSString stringWithFormat:@"%@", propertyNameString];
                        //排除索引
                        if ([propStr isEqualToString:@"fid"] || [propStr isEqualToString:@"iid"]) {
                            continue;
                        }
                        //判断字段是否存在表中
                        if ([self.dbManager columnExists:propStr inTableWithName:tableName]) {
                            
                            [keys appendString:[NSString stringWithFormat:@"%@,", propertyNameString]];
                            [values appendString:@"?,"];
                            [arguments addObject:valueForProperty];
                        }
                    }
                }
                entityClass = [entityClass superclass];
            }
            [keys appendString:@")"];
            [values appendString:@")"];
            @autoreleasepool {
                [sql appendFormat:@"%@ VALUES%@", [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"], [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
            }
            
            BOOL result = [self.dbManager executeUpdate:sql withArgumentsInArray:arguments];
            
            if (complete) {
                complete(result);
            }
        }];
    }
}


//更新
- (void)updateTableWithModel:(GRBaseDBModel*)model tableName:(NSString*)tableName where:(NSString*)predicate{
    
    if (self.dbManager) {
        [self execQueryBlock:^{
            NSArray *columns = [self tableColumnsArr:tableName db:self.dbManager];//表字段
            NSDictionary *dict = [self getModelPropertyKeyValue:model];
            NSArray *allKeys = dict.allKeys;
            NSMutableArray *arguments = [NSMutableArray array];
            
            NSString *predicateString = @"";
            if (predicate) {
                predicateString = [NSString stringWithFormat:@" WHERE %@", predicate];
            }
            
            //
            NSMutableString *sqlM = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", tableName];
            for (NSString *key in allKeys) {
                if ([columns containsObject:key]) {
                    if ([key isEqualToString:@"fid"] || [key isEqualToString:@"iid"]) {
                        continue;
                    }
                    //判断字段是否存在表中
                    if ([self.dbManager columnExists:key inTableWithName:tableName]) {
                        [sqlM appendFormat:@"%@ = ?,", key];
                        [arguments addObject:[dict objectForKey:key]];
                    }
                }
            }
            [sqlM deleteCharactersInRange:NSMakeRange(sqlM.length - 1, 1)];
            [sqlM appendString:predicateString];
            
            [self.dbManager executeUpdate:sqlM.copy withArgumentsInArray:arguments];
            //NSLog(@"更新%@", result?@"成功":@"失败");
        }];
    }
}


//删除
- (void)deleteTableWithTableName:(NSString*)tableName where:(NSString*)predicate{
    
    NSString *predicateString = @"";
    if (predicate) {
        predicateString = [NSString stringWithFormat:@"WHERE %@", predicate];
    }
    NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ %@", tableName, predicateString];
    
    if (self.dbManager) {
        [self execQueryBlock:^{
            BOOL result = [self.dbManager executeUpdate:sql];
            NSLog(@"删除%@%@", tableName, result?@"成功":@"失败");
        }];
    }
}


//标记删除
- (void)deleteUpsignWithTableName:(NSString*)tableName where:(NSString*)predicate{
    
    NSString *predicateString = @"";
    if (predicate) {
        predicateString = [NSString stringWithFormat:@"WHERE %@", predicate];
    }
    
    if (self.dbManager) {
        [self execQueryBlock:^{
            NSString *sql = [NSString stringWithFormat:@"update %@ set isdelete = %@ %@", tableName, @(1), predicateString];
            BOOL result = [self.dbManager executeUpdate:sql];
            NSLog(@"删除标记:%@", result?@"成功":@"失败");
        }];
    }
}



// 清表
- (void)clearTableWithTableName:(NSString*)tableName{
    if ([self checkTableName:tableName] == NO) {
        return;
    }
    
    if (self.dbManager) {
        [self execQueryBlock:^{
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
            BOOL result = [self.dbManager executeUpdate:sql];
            NSLog(@"清表:%@-%@", tableName, result?@"成功":@"失败");
        }];
    }
}

#pragma mark - Helper

//得到表所有字段名
- (NSArray *)tableColumnsArr:(NSString *)tableName db:(FMDatabase *)db{
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:0];//table中的字段名
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while([resultSet next]){
        [columns addObject:[resultSet stringForColumn:@"name"]];//获得table中的字段名
    }
    [resultSet close];
    return columns;
}

//得到model属性的名称和值
- (NSMutableDictionary *)getModelPropertyKeyValue:(id)model{
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    u_int count;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    for (int i = 0; i < count; i++) {
        NSString *pName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        id pValue = [model valueForKey:pName];
        if (pValue) {
            [dictM setObject:pValue forKey:pName];
        }
    }
    free(properties);
    return dictM.copy;
}

// 根据查出来的数据，转OC数值
- (id)genValueByAttribute:(objc_property_t)property withSet:(FMResultSet *)rs{
    const char* propertyName = property_getName(property);
    NSString *propertyNameString = [NSString stringWithUTF8String:propertyName];
    char *propertyType = property_copyAttributeValue(property, "T");
    //
    switch (propertyType[0]) {
        case 'i': // int
        case 's': // short
        case 'l': // long
        case 'q': // long long
        case 'I': // unsigned int
        case 'S': // unsigned short
        case 'L': // unsigned long
        case 'Q': // unsigned long long
            return @([rs longLongIntForColumn:propertyNameString]);
        case 'B': // BOOL
        case 'c': // char
            return @([rs intForColumn:propertyNameString]);
        case 'f': // float
        case 'd': // double
            return @([rs doubleForColumn:propertyNameString]);
        case '@':
        {
            NSString *propertyTypeString = [NSString stringWithUTF8String:propertyType];
            if ([propertyTypeString isEqualToString:@"@\"NSString\""]) {
                return [rs stringForColumn:propertyNameString];
            }
            if ([propertyTypeString isEqualToString:@"@\"NSNumber\""]) {
                return @([rs doubleForColumn:propertyNameString]);
            }
            if ([propertyTypeString isEqualToString:@"@\"NSDate\""]) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
                [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
                NSString * uiDate = [rs stringForColumn:propertyNameString];
                NSDate *date=[formatter dateFromString:uiDate];
                return date;
            }
        }
    }
    return nil;
}

//
- (id)formularValue:(objc_property_t)property withValue:(id)value{
    char *propertyType = property_copyAttributeValue(property, "T");
    switch (propertyType[0]) {
        case 'i': // int
        case 's': // short
        case 'l': // long
        case 'q': // long long
        case 'I': // unsigned int
        case 'S': // unsigned short
        case 'L': // unsigned long
        case 'Q': // unsigned long long
        case 'B': // BOOL
        case 'f': // float
        case 'd': // double
        case 'c': // char
            return value;
        case '@':
        {
            NSString *propertyTypeString = [NSString stringWithUTF8String:propertyType];
            if ([propertyTypeString isEqualToString:@"@\"NSDate\""]) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
                [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
                NSString *destDateString = [formatter stringFromDate:value];
                return destDateString;
            }
            else if ([propertyTypeString isEqualToString:@"@\"NSString\""] || [propertyTypeString isEqualToString:@"@\"NSNumber\""]) {
                return value;
            }
        }
        default:
            return nil;
    }
    return nil;
}

@end
