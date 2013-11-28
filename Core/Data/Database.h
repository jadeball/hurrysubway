//
//  Database.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-7-7.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Database : NSObject {
    sqlite3 *dbs;
	NSDictionary *dicSetting;
    NSArray *arrayLine;
    NSDictionary *dictTransfers;
    int _intStartLineNo;
    int _intEndLineNo;
    NSString *_strIoStat;
    NSString *_strOiStat;
    NSString *_strStartName;
    NSString *_strEndName;
    BOOL bHasSetStart;
    BOOL bHasSetEnd;
    NSArray *arraySpecialNodes;
    NSDictionary *dictSpecials;
    
    BOOL isWeiboBinded;
    NSString *strTokenKey;
    NSString *strTokenSecret;
    NSString *strTokenUserID;
    NSMutableArray *_marrayNetMapImages;
    NSDictionary *localdic;
}

@property (nonatomic, readonly) sqlite3 *dbs;
@property (nonatomic, retain) NSDictionary *dicSetting;
@property (nonatomic, retain) NSArray *arrayLine;
@property (nonatomic, retain) NSDictionary *dictTransfers;
@property (nonatomic, assign) int intStartLineNo, intEndLineNo;
@property (nonatomic, retain) NSString *strIoStat, *strOiStat, *strStartName, *strEndName;
@property (nonatomic, assign) BOOL isWeiboBinded;
@property (nonatomic, retain) NSString *strTokenKey, *strTokenSecret, *strTokenUserID;
@property (nonatomic, assign) BOOL bHasSetStart, bHasSetEnd;
@property (nonatomic, retain) NSArray *arraySpecialNodes;
@property (nonatomic, retain) NSDictionary *dictSpecials;
@property (nonatomic, retain) NSMutableArray *marrayNetMapImages;


+ (Database *)sharedDatabase;

- (void)exchangeStartAndEndInfo;
-(NSArray *)getalllinesTobtncount;
- (NSArray *)getAllCoordinate;
- (NSArray *)getAllLines;
- (NSArray *)getAllStations;
- (NSArray *)getPlanListWithStart:(NSString *)strIoStat end:(NSString *)strOiStat andType:(int)type;
- (NSDictionary *)getPlanDetailWithPlan:(NSDictionary *)dictPlan andType:(int)type;
- (NSArray *)getAllLinesInfo;
- (NSArray *)getStationListWithLineNo:(int)lineNo;
- (NSDictionary *)getStationInfoWithStationId:(NSString *)strStatId;
- (NSDictionary *)getSearchList;
- (NSArray *)getsearchResultWith:(NSString *)strKeyWord;
- (NSDictionary *)getSettingData;
- (NSArray *)getAllTime;
- (NSArray *)getStationNameListWithLineNo:(int)lineNo;

@end
