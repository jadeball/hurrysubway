//
//  Database.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-7-7.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "Database.h"
#import "NSString+CompareInNum.h"
#import "PlistUtils.h"
#define kDataBaseNameNew @"subway.sqlite"
@interface Database ()

-(NSString *)getDataBaseFilePathNew;
- (NSArray *)getStationsWithLineNo:(int)lineNo;
- (NSString *)getNameCnWithStatId:(NSString *)strStatId;
- (NSDictionary *)getAllTransferStats;

- (NSString *)getTransferStatsWithTransferStats:(NSString *)strTransfers stations:(NSArray *)arrayStats andTransferStations:(NSArray *)arrayTransfers;

@end

@implementation Database
@synthesize dbs, dicSetting;
@synthesize arrayLine;
@synthesize intStartLineNo = _intStartLineNo;
@synthesize intEndLineNo = _intEndLineNo;
@synthesize strIoStat = _strIoStat, strOiStat = _strOiStat, strStartName = _strStartName, strEndName = _strEndName;
@synthesize dictTransfers;
@synthesize isWeiboBinded;
@synthesize strTokenKey, strTokenSecret, strTokenUserID;
@synthesize bHasSetStart,bHasSetEnd;
@synthesize arraySpecialNodes;
@synthesize dictSpecials;
@synthesize marrayNetMapImages = _marrayNetMapImages;

static Database *sharedDatabase = nil;

+ (Database *)sharedDatabase {
	@synchronized(self) {
		if (sharedDatabase == nil) {
			sharedDatabase = [[super allocWithZone:NULL] init];
		}
	}
	return sharedDatabase;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		return [[self sharedDatabase] retain];
	}
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (oneway void)release {
	
}

- (id)autorelease {
	return self;
}

- (id)init {
	if ((self = [super init])) {
        if (sqlite3_open([[self getDataBaseFilePathNew] UTF8String], &dbs) != SQLITE_OK) {
			sqlite3_close(dbs);
			NSAssert(0, @"Failed to open database");
		}
        self.arrayLine =[self getAllLines];
        self.dictTransfers = [self getAllTransferStats];
        self.intStartLineNo = 1;
        self.intEndLineNo = 1;
        self.strIoStat = @"0111";
        self.strOiStat = @"0111";
        self.strStartName = @"莘庄";
        self.strEndName = @"莘庄";
        self.bHasSetStart = NO;
        self.bHasSetEnd = NO;
        NSString *strSpecial = [[NSBundle mainBundle] pathForResource:@"specialnodes" ofType:@"plist"];
        self.dictSpecials = [NSDictionary dictionaryWithContentsOfFile:strSpecial];
        self.arraySpecialNodes = [[self.dictSpecials allKeys] sortedArrayUsingSelector:@selector(compareNumInString:)];
        self.marrayNetMapImages = [NSMutableArray array];
        localdic=[[NSDictionary alloc] init];
        localdic=[[PlistUtils sharedPlistData] getviewdictionary:@"DataBase"];
	}
	return self;
}

- (void)dealloc {
    sqlite3_close(dbs);
	self.dicSetting = nil;
    self.arrayLine = nil;
    self.strEndName = nil;
    self.strStartName = nil;
    self.strIoStat = nil;
    self.strOiStat = nil;
    self.dictTransfers = nil;
    self.strTokenKey = nil;
    self.strTokenSecret = nil;
    self.strTokenUserID = nil;
    self.arraySpecialNodes = nil;
    self.dictSpecials = nil;
    self.marrayNetMapImages = nil;
	[super dealloc];
}

-(NSString *)getDataBaseFilePathNew{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *docPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Caches"];
	NSString *lvmmPath = [docPath stringByAppendingPathComponent:@"subway"];
	NSString *sqlPath = [lvmmPath stringByAppendingPathComponent:@"sql"];
	NSString *databasePath = [sqlPath stringByAppendingPathComponent:kDataBaseNameNew];
    
	return databasePath;
}
- (void)exchangeStartAndEndInfo {
    int _intTmp = self.intStartLineNo;
    self.intStartLineNo = self.intEndLineNo;
    self.intEndLineNo = _intTmp;
    
    NSString *strTmp = [self.strIoStat retain];
    self.strIoStat = self.strOiStat;
    self.strOiStat = strTmp;
    [strTmp release];
    
    strTmp = [self.strStartName retain];
    self.strStartName = self.strEndName;
    self.strEndName = strTmp;
    [strTmp release];
    
    BOOL tmp = bHasSetStart;
    bHasSetStart = bHasSetEnd;
    bHasSetEnd = tmp;
}
- (NSDictionary *)getSettingData {
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
    NSString *query = @"select * from setting";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int count = sqlite3_column_count(statement);
            for (int i = 0; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
        }
    }
    sqlite3_finalize(statement);
    NSDictionary *dictRet = [NSDictionary dictionaryWithDictionary:mdict];
    [mdict release];
    return dictRet;
}
/*
 - (void)disableDisclaimer {
 
 if (sqlite3_open([[self getDataBaseFilePath] UTF8String], &db) != SQLITE_OK) {
 sqlite3_close(db);
 NSAssert(0, @"Failed to open database");
 }
 
 NSString *update = @"update setting set disabledisclaimer=1";
 char * errorMsg;
 
 if (sqlite3_exec(db, [update UTF8String], NULL,NULL, &errorMsg) != SQLITE_OK)
 {
 sqlite3_close(db);
 NSAssert1(0, @"Error update setting : %@", [NSString stringWithUTF8String:errorMsg]);
 
 }
 }
 */
-(NSArray *)getalllinesTobtncount{
    NSMutableArray *marray=[[NSMutableArray alloc] init];
    NSString *query=[NSString stringWithFormat:@"SELECT name_cn, name_en FROM metro_lines"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil)==SQLITE_OK) {
        while (sqlite3_step(statement)==SQLITE_ROW) {
            NSMutableDictionary *medict=[[NSMutableDictionary alloc] init];
            int count=sqlite3_column_count(statement);
            for (int i=0; i<count; i++) {
                char *columnName=(char *)sqlite3_column_name(statement, i);
                char *columnData=(char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [medict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            [marray addObject:medict];
            [medict release];
        }
    }
    
    NSMutableArray *lineary=[[NSMutableArray alloc] init];
    for (int k=0; k<[marray count]; k++) {
        NSString *names=[[marray objectAtIndex:k] objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]];
        [lineary addObject:names];
        [names release];
    }
    sqlite3_finalize(statement);
    NSArray *arrayRet=[NSArray arrayWithArray:lineary];
    [lineary release];
    return arrayRet;
}

- (NSArray *)getStationsWithLineNo:(int)lineNo {
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"select stat_id, name_cn, name_en,toilet_inside,longitude, latitude, lines from metro_stations where stat_id like '%02d%%' and type=1 order by stat_id asc",lineNo];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            [marray addObject:mdict];
            [mdict release];
        }
    }
    sqlite3_finalize(statement);
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
}

- (NSArray *)getAllLines {
    localdic=[[PlistUtils sharedPlistData] getviewdictionary:@"DataBase"];
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSString *query = @"select count(line_id) from metro_lines order by line_id asc";
    int count = 0;
    sqlite3_stmt *statement;
    NSInteger intTip = sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil);
    if (intTip == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
    } else {
        NSString *strTip = [NSString stringWithFormat:@"%@ %d",[localdic objectForKey:@"string1"],intTip];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[localdic objectForKey:@"point"] message:strTip delegate:nil cancelButtonTitle:[[PlistUtils sharedPlistData] getviewstring:@"done"]otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    
    
    sqlite3_finalize(statement);
    for (int i = 0; i < count; i++) {
        NSArray *array = [self getStationsWithLineNo:(i+1)];
        [marray addObject:array];
    }
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
}

- (NSArray *)getAllStations {
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithString:@"select stat_id, name_cn, name_en, x, y, lines from metro_stations where type=1"];
    sqlite3_stmt *statement;
    NSInteger intTip = sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil);
    if (intTip ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            [marray addObject:mdict];
            [mdict release];
        }
    } else {
        NSString *strTip = [NSString stringWithFormat:@"%@ %d",[localdic objectForKey:@"string1"],intTip];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[localdic objectForKey:@"point"] message:strTip delegate:nil cancelButtonTitle:[[PlistUtils sharedPlistData]getviewstring:@"done"] otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    sqlite3_finalize(statement);
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
}


- (NSDictionary *)getAllTransferStats {
    NSMutableDictionary *mdictTransferStats = [[NSMutableDictionary alloc] init];
    NSString *query = [NSString stringWithString:@"select stat_id, name_cn,name_en  from metro_stations where lines like '%%,%%' and type=1"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            NSMutableArray *marray = [mdictTransferStats objectForKey:[mdict objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]];
            if (marray == nil) {
                marray = [[NSMutableArray alloc] init];
                [mdictTransferStats setObject:marray forKey:[mdict objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]];
                [marray addObject:[mdict objectForKey:@"stat_id"]];
                [marray release];
            }else {
                [marray addObject:[mdict objectForKey:@"stat_id"]];
            }
            [mdict release];
        }
    }
    sqlite3_finalize(statement);
    NSDictionary *dictRet = [NSDictionary dictionaryWithDictionary:mdictTransferStats];
    [mdictTransferStats release];
    return dictRet;
}
#pragma -----------
#pragma Transfer_stations
-(NSArray *)getlinesStat:(NSString *)name{
    NSMutableArray *marray=[[NSMutableArray alloc] init];
    NSString *query=[NSString stringWithFormat:@"SELECT stat_id FROM metro_stations where %@='%@'",[[PlistUtils sharedPlistData] getviewstring:@"name"], name];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
                NSString *str=[mdict objectForKey:@"stat_id"];
                [marray addObject:str];
            }
        }
    }
    sqlite3_finalize(statement);
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
}
-(NSArray *)getTheStats:(NSString *)linestat{
    NSString *query=[NSString stringWithFormat:@"SELECT %@  FROM metro_stations where stat_id='%@'",[[PlistUtils sharedPlistData] getviewstring:@"name"], linestat];
    sqlite3_stmt *statement;
    NSString *namestr;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            namestr=[mdict objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]];
        }
    }
    NSArray *marry=[self getlinesStat:namestr];
    sqlite3_finalize(statement);
    NSArray *arrayret=[NSArray arrayWithArray:marry];
    return arrayret;
    
}
-(NSString *)getrowid:(NSString *)strstat{
    NSString *query=[NSString stringWithFormat:@"select seq_no  from stat_seq where stat_id='%@'",strstat];
    sqlite3_stmt *statement;
    NSString *str;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            str=[mdict objectForKey:@"seq_no"];
        }
    }
    sqlite3_finalize(statement);
    NSString *rowid=[NSString stringWithFormat:@"%@",str];
    return rowid;
    
}
-(NSString *)getfree:(NSString *)strIorow end:(NSString *)stroirow{
    NSString *col_id=[NSString stringWithFormat:@"col_%@",stroirow];
    NSString *query=[NSString stringWithFormat:@"select %@  from fee where rowid='%@'",col_id,strIorow];
    sqlite3_stmt *statement;
    NSString *str;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            str=[mdict objectForKey:[NSString stringWithFormat:@"col_%@",stroirow]];
        }
    }
    sqlite3_finalize(statement);
    NSString *free=[NSString stringWithFormat:@"%@",str];
    return free;
    
}
-(NSString *)getTime:(NSString *)strstat Group:(NSString *)strGroup {
    NSString *query=[NSString stringWithFormat:@"select first_run from metro_first_end_run where stat_end_id='%@' and stat_id='%@'",strGroup,strstat];
    NSMutableArray *marray=[[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    NSString *str;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
                NSString *strtime=[mdict objectForKey:@"first_run"];
                [marray addObject:strtime];
            }
        }
    }
    str=[marray objectAtIndex:0];
    sqlite3_finalize(statement);
    [marray release];
    NSString *times=[NSString stringWithFormat:@"%@",str];
    return times;
    
}
-(NSDictionary *)getFirstAndEndTime:(NSString *)strstat Group:(NSString *)strGroup {
    NSString *query=[NSString stringWithFormat:@"select first_run,end_run from metro_first_end_run where stat_end_id='%@' and stat_id='%@'",strGroup,strstat];
    sqlite3_stmt *statement;
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
        }
    }
    sqlite3_finalize(statement);
    NSLog(@"%@",mdict);
    return mdict;
    
}

//判断如何取时间
-(int )UseringSwitchTime:(NSString *)strIOStat end:(NSString *)stroiStat lint:(int )line{
    int intIOStat=[strIOStat intValue];
    int intOiStat=[stroiStat intValue];
    int stat1,stat2,time,times=0;
    localdic=[[PlistUtils sharedPlistData] getviewdictionary:@"DataBase"];
    NSString *StrGroup;
    NSArray *statGroup1,*statGroup2,*statGroup3,*statGroup4;
    NSArray *timeary2,*timeary1;
    int  Group1one,Group1two,Group2one,Group2two,Group3one,Group3two,Group4one,Group4two;
    NSArray *LineStat=[[localdic objectForKey:@"TimeGroup"] objectForKey:[NSString stringWithFormat:@"%d",line]];
    if (line==2 || line ==1) {
        statGroup1=[[LineStat objectAtIndex:0] componentsSeparatedByString:@","];
        statGroup2=[[LineStat objectAtIndex:1] componentsSeparatedByString:@","];
        statGroup3=[[LineStat objectAtIndex:2] componentsSeparatedByString:@","];
        statGroup4=[[LineStat objectAtIndex:3] componentsSeparatedByString:@","];
        Group1one=[[statGroup1 objectAtIndex:0] intValue];
        Group1two=[[statGroup1 objectAtIndex:1] intValue];
        Group2one=[[statGroup2 objectAtIndex:0] intValue];
        Group2two=[[statGroup2 objectAtIndex:1] intValue];
        Group3one=[[statGroup3 objectAtIndex:0] intValue];
        Group3two=[[statGroup3 objectAtIndex:1] intValue];
        Group4one=[[statGroup4 objectAtIndex:0] intValue];
        Group4two=[[statGroup4 objectAtIndex:1] intValue];
        if (intIOStat>=Group1one && intIOStat <=Group1two && intOiStat>Group1two) {
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup1 objectAtIndex:2]];
            timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
            if (intOiStat >Group1two && intOiStat <=Group2two) {
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup2 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
            }else if(intOiStat >Group2two && intOiStat <=Group3two){
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup2 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:[statGroup2 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup3 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup3 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
            }else if (intOiStat >Group3two && intOiStat <=Group4two){
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup2 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:[statGroup2 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup3 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup3 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:[statGroup3 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup4 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup4 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
            }
            
            
        }else if(intIOStat>=Group2one && intIOStat <=Group2two && intOiStat>Group3one ){
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
            timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:[statGroup2 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
            if (intOiStat >Group3one && intOiStat<=Group3two ) {
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup3 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup3 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
            }else if (intOiStat >Group4one && intOiStat<=Group4two){
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup3 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup3 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:[statGroup3 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup3 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup4 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
            }
            
        }
        else if (intIOStat >=Group3one && intIOStat <=Group3two && intOiStat >Group3two){
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup3 objectAtIndex:2]];
            timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:[statGroup3 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
            
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup4 objectAtIndex:2]];
            timeary1=[[self getTime:[statGroup4 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
            
        }
        else if (intOiStat>=Group1one && intOiStat <=Group1two && intIOStat>Group1two){
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup1 objectAtIndex:2]];
            timeary1=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
        }//两个站点在同一个组内
        else if ( intIOStat>=Group1one && intIOStat <=Group1two && intOiStat>=Group1one && intOiStat <=Group1two ){
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup1 objectAtIndex:2]];
            timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
        }
        else if ( intIOStat>=Group2one && intIOStat <=Group2two && intOiStat>=Group2one && intOiStat <=Group2two ){
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
            timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
        } else if ( intIOStat>=Group3one && intIOStat <=Group3two && intOiStat>=Group3one && intOiStat <=Group3two ){
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup3 objectAtIndex:2]];
            timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
        } else if ( intIOStat>=Group4one && intIOStat <=Group4two && intOiStat>=Group4one && intOiStat <=Group4two ){
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup4 objectAtIndex:2]];
            timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
        }
        
    }else if(line==4){
        statGroup1=[[LineStat objectAtIndex:0] componentsSeparatedByString:@","];
        statGroup2=[[LineStat objectAtIndex:1] componentsSeparatedByString:@","];
        Group1one=[[statGroup1 objectAtIndex:0] intValue];
        Group1two=[[statGroup1 objectAtIndex:1] intValue];
        Group2one=[[statGroup2 objectAtIndex:0] intValue];
        Group2two=[[statGroup2 objectAtIndex:1] intValue];
        if (intIOStat>=Group1one && intIOStat <=Group1two && intOiStat>Group1two) {
            if (sqrt(pow(intIOStat-intOiStat, 2)) > sqrt(pow(Group1one-Group2two, 2))/2 ) {
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup1 objectAtIndex:2]];
                timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:[statGroup1 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup2 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
            }else{
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup1 objectAtIndex:2]];
                timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
            }
        }else if (intOiStat>=Group1one && intOiStat <=Group1two && intIOStat>Group1two){
            if (sqrt(pow(intIOStat-intOiStat, 2)) > sqrt(pow(Group1one-Group2two, 2))/2 ) {
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup1 objectAtIndex:2]];
                timeary1=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:[statGroup1 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup2 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
            }else {
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup1 objectAtIndex:2]];
                timeary1=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
            }
        }
        else if ( intIOStat>=Group1one && intIOStat <=Group1two && intOiStat>=Group1one && intOiStat <=Group1two ){
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup1 objectAtIndex:2]];
            timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
            
        }else if (intIOStat>=Group2one && intIOStat <=Group2two && intOiStat>=Group2one && intOiStat <=Group2two ){
            if (sqrt(pow(intIOStat-intOiStat, 2)) > sqrt(pow(Group1one-Group2two, 2))/2 ) {
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
                timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
                timeary1=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:[statGroup2 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
                timeary1=[[self getTime:[statGroup1 objectAtIndex:0] Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
                
            }
            else{
                StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
                timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
                timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
                stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
                stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
                NSLog(@"%@ %@ ",timeary1,timeary2);
                time=sqrt(pow(stat1-stat2, 2));
                times=times+time;
                
            }
            
        }
        
        
    }else{
        statGroup1=[[LineStat objectAtIndex:0] componentsSeparatedByString:@","];
        statGroup2=[[LineStat objectAtIndex:1] componentsSeparatedByString:@","];
        Group1one=[[statGroup1 objectAtIndex:0] intValue];
        Group1two=[[statGroup1 objectAtIndex:1] intValue];
        Group2one=[[statGroup2 objectAtIndex:0] intValue];
        Group2two=[[statGroup2 objectAtIndex:1] intValue];
        if (intIOStat>=Group1one && intIOStat <=Group1two && intOiStat>Group1two) {
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup1 objectAtIndex:2]];
            timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
            
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
            timeary1=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
            
        }else if (intOiStat>=Group1one && intOiStat <=Group1two && intIOStat>Group1two){
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup1 objectAtIndex:2]];
            timeary1=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
            
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
            timeary1=[[self getTime:[statGroup1 objectAtIndex:1] Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
        }
        else if ( intIOStat>=Group1one && intIOStat <=Group1two && intOiStat>=Group1one && intOiStat <=Group1two ){
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup1 objectAtIndex:2]];
            timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
            
        }else if (intIOStat>=Group2one && intIOStat <=Group2two && intOiStat>=Group2one && intOiStat <=Group2two ){
            StrGroup=[NSString stringWithFormat:@"%@",[statGroup2 objectAtIndex:2]];
            timeary1=[[self getTime:strIOStat Group:StrGroup] componentsSeparatedByString:@":"];
            timeary2=[[self getTime:stroiStat Group:StrGroup] componentsSeparatedByString:@":"];
            stat1=[[timeary1 objectAtIndex:0] intValue] *60 +[[timeary1 objectAtIndex:1] intValue];
            stat2=[[timeary2 objectAtIndex:0] intValue] *60 +[[timeary2 objectAtIndex:1] intValue];
            NSLog(@"%@ %@ ",timeary1,timeary2);
            time=sqrt(pow(stat1-stat2, 2));
            times=times+time;
            
        }
        
    }
    
    return times;
}
-(NSDictionary *)GetNOtices:(NSString *)type{
    NSString * query=[NSString stringWithFormat:@"select line_path_up_en,line_path_down_en,line_path_up_cn,line_path_down_cn from line_path where line_id='%@'",type];
    sqlite3_stmt *statement;
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
        }
    }
    sqlite3_finalize(statement);
    NSDictionary *arrayret=[NSDictionary dictionaryWithDictionary:mdict];
    [mdict release];
    return arrayret;
    
}
-(NSString *)GetNotices:(NSString *)strIostat end:(NSString *)strOiStat andType:(int)type{
    localdic=[[PlistUtils sharedPlistData] getviewdictionary:@"DataBase"];
    NSArray *NoticeTextAry=[[localdic objectForKey:@"notices"] componentsSeparatedByString:@","];//请选择。。。方向的。。。。
    NSDictionary *NoticeDirectionDic=[localdic objectForKey:@"noticesAry"];//方向
    NSDictionary *TimeF_eDic=[localdic objectForKey:@"Timef_e"];//断点
    //每一条线路的 dic
    NSDictionary *NoticsDirDicline=[NoticeDirectionDic objectForKey:[NSString stringWithFormat:@"%d",[strIostat intValue]/100]];
    NSDictionary *TimeF_elineDic=[TimeF_eDic objectForKey:[NSString stringWithFormat:@"%d",[strIostat intValue]/100]];//每一条线路的 断点信息
    
    NSDictionary *F_ETimeAry;
    int NoticeStat=0;
    NSString *Notices;
    NSString *Group;
    //    NSDictionary *DirectionDic=[[NSDictionary alloc] init];
    //    if ([strIostat intValue]/100 ==1 || [strIostat intValue ]/100 == 3 ) {
    //        DirectionDic = [self GetNOtices:[NSString stringWithFormat:@"%d",[strIostat intValue]/100]];
    //        if ([strIostat intValue] - [strOiStat intValue] <0) {///由小到大
    //            if (([strOiStat intValue]-[strIostat intValue])<(426-401)/2) {
    //                Group=[TimeF_elineDic objectForKey:@"end"];
    //            }else{
    //                Group=[TimeF_elineDic objectForKey:@"star"];
    //            }
    //
    //            F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
    //            Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"end"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
    //        }else{
    //
    //        }
    //
    //    }else if ([strIostat intValue]/100 ==2){
    //
    //    }else if ([strIostat intValue]/100 == 10 || [strIostat intValue]/100 == 11){
    //
    //    }else {
    //
    //    }
    if ([strIostat intValue]/100 ==7 || [strIostat intValue]/100==10 || [strIostat intValue]/100==11|| [strIostat intValue]/100 ==4) {
        switch ([strIostat intValue]/100) {
            case 4:{
                if ([strIostat intValue] - [strOiStat intValue] <0) {
                    if (([strOiStat intValue]-[strIostat intValue])<(426-401)/2) {
                        Group=[TimeF_elineDic objectForKey:@"end"];
                    }else{
                        Group=[TimeF_elineDic objectForKey:@"star"];
                    }
                    F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                    Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"end"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                    
                }else{
                    if (([strIostat intValue]-[strOiStat intValue])<(426-401)/2) {
                        Group=[TimeF_elineDic objectForKey:@"star"];
                    }else{
                        Group=[TimeF_elineDic objectForKey:@"end"];
                    }
                    F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                    Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"end"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                    
                }
            }
                break;
            case 7:{
                NoticeStat=[[TimeF_elineDic objectForKey:@"star_2"] intValue];
                if ([strIostat intValue] - [strOiStat intValue] <0) {
                    Group=[TimeF_elineDic objectForKey:@"end"];
                    F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                    Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"end"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                }
                else{
                    if ([strOiStat intValue] <=NoticeStat) {
                        Group=[TimeF_elineDic objectForKey:@"star_2"];
                        F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                        Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@(%@/%@) ",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"star_2"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                    }else{
                        Group=[TimeF_elineDic objectForKey:@"star_1"];
                        F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                        Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"star_1"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                    }
                }
            }
                break;
            case 10:{
                NoticeStat=[[TimeF_elineDic objectForKey:@"star_2"] intValue];
                if ([strIostat intValue] - [strOiStat intValue] <0) {
                    Group=[TimeF_elineDic objectForKey:@"end"];
                    F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                    Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"end"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                }
                else{
                    if ([strOiStat intValue] >=NoticeStat) {
                        Group=[TimeF_elineDic objectForKey:@"star_1"];
                        F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                        Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@ ",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"star_1"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                    }else{
                        Group=[TimeF_elineDic objectForKey:@"star_2"];
                        F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                        Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@(%@/%@)",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"star_2"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                    }
                    
                }
                
            }
                break;
            case 11:{
                NoticeStat=[[TimeF_elineDic objectForKey:@"star"] intValue];
                int noticesStat=[[TimeF_elineDic objectForKey:@"star_2"] intValue];
                if ([strIostat intValue] - [strOiStat intValue] <0) {//由小到大
                    Group=[TimeF_elineDic objectForKey:@"end"];
                    F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                    Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"end"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                }
                else{
                    if ([strOiStat intValue] <noticesStat) {
                        Group=[TimeF_elineDic objectForKey:@"star_1"];
                        F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                        Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@ ",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"star_1"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                    }else if ([strOiStat intValue]<NoticeStat && [strOiStat intValue]>=noticesStat ){
                        Group=[TimeF_elineDic objectForKey:@"star_2"];
                        F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                        Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@ ",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"star_2"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                    }
                    else{
                        Group=[TimeF_elineDic objectForKey:@"star_2"];
                        F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                        Group=[TimeF_eDic objectForKey:@"star_1"];
                        NSDictionary *F_ETimeAryS=[self getFirstAndEndTime:strIostat Group:Group];
                        Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@(%@/%@)",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"star"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"],[F_ETimeAryS objectForKey:@"first_run"],[F_ETimeAryS objectForKey:@"end_run"]];
                    }
                }
            }
                break;
            default:
                break;
        }
        
    }else{
        NoticeStat=[[TimeF_elineDic objectForKey:@"end_2"] intValue];
        if ([strIostat intValue] - [strOiStat intValue] <0) {//小到大
            NSLog(@"%d",NoticeStat);
            if ([[NoticeDirectionDic allKeys] count]>2 && [strOiStat intValue] <= NoticeStat) {
                if ([strOiStat intValue]/100==2) {
                    Group=[TimeF_elineDic objectForKey:@"end_2"];
                    F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                    Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"end_1"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                }else{
                    Group=[TimeF_elineDic objectForKey:@"end_1"];
                    F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                    Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@(%@/%@)",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"end_1"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                    
                }
            }
            else{
                if ([strOiStat intValue]/100==2) {
                    NSArray *noticearry=[[NoticsDirDicline objectForKey:@"end_2"] componentsSeparatedByString:@","];
                    Notices=[NSString stringWithFormat:@"%@\n%@",[noticearry objectAtIndex:0],[noticearry objectAtIndex:1]];
                    
                }else{
                    Group=[TimeF_elineDic objectForKey:@"end_2"];
                    F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                    Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"end_2"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                }
            }
        }
        else{
            if ([[NoticeDirectionDic allKeys] count]>2 && [strOiStat intValue] >= NoticeStat) {
                Group=[TimeF_elineDic objectForKey:@"end_2"];
                F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"star"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                
            }else{
                if ([strOiStat intValue]/100==2) {
                    NSArray *noticearry=[[NoticsDirDicline objectForKey:@"star_2"] componentsSeparatedByString:@","];
                    Notices=[NSString stringWithFormat:@"%@\n%@",[noticearry objectAtIndex:0],[noticearry objectAtIndex:1]];
                }else{
                    Group=[TimeF_elineDic objectForKey:@"star"];
                    F_ETimeAry=[self getFirstAndEndTime:strIostat Group:Group];
                    Notices=[NSString stringWithFormat:@"%@%@%@\n%@%@/%@",[NoticeTextAry objectAtIndex:0],[NoticsDirDicline objectForKey:@"star"],[NoticeTextAry objectAtIndex:1],[NoticeTextAry objectAtIndex:2],[F_ETimeAry objectForKey:@"first_run"],[F_ETimeAry objectForKey:@"end_run"]];
                }
                
            }
        }
    }
    return Notices;
}
-(NSString *)GetStations:(NSString *)strIostat end:(NSString *)stroistat{
    NSString *query;
    NSMutableArray *StringQuery=[[NSMutableArray alloc] init];
    if ([strIostat intValue]/100 ==4) {
        if (sqrt(pow(([stroistat intValue] - [strIostat intValue]), 2)) > (426-401)/2 ) {
            if ([stroistat intValue] <[strIostat intValue]) {//由大到小
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where stat_id>='%@' and stat_id<='0426' order by stat_id asc",strIostat];
                [StringQuery addObject:query];
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where sstat_id <='%@'and stat_id>='0401' order by stat_id asc",stroistat];
                [StringQuery addObject:query];
                
            }else{
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where stat_id<='%@' and stat_id>='0401' order by stat_id desc",strIostat];
                [StringQuery addObject:query];
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where stat_id >='%@' and stat_id<='0426' order by stat_id desc",stroistat];
                [StringQuery addObject:query];
            }
            
        }else{
            if ([strIostat intValue] <=[stroistat intValue]) {
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where stat_id >='%@' and stat_id<='%@'order by stat_id asc",strIostat,stroistat];
                [StringQuery addObject:query];
            }else{
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where stat_id >='%@' and stat_id<='%@'order by stat_id desc",stroistat,strIostat];
                [StringQuery addObject:query];
            }
        }
    }
    else if ([strIostat intValue]/100==10){
        
        if ([stroistat intValue] <[strIostat intValue]) {//由大到小
            if ([stroistat intValue]<=1020 && [strIostat intValue] >1045) {
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where (stat_id <='1020' and stat_id>='%@') or (stat_id >='1045' and stat_id <= '%@') order by stat_id desc",stroistat,strIostat];
                [StringQuery addObject:query];
                
            }else{
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where stat_id <='%@' and stat_id>='%@'order by stat_id desc",strIostat,stroistat];
                [StringQuery addObject:query];
                
            }
        }else{
            if ([strIostat intValue]<=1020 && [stroistat intValue] >1045) {
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where (stat_id <='1020' and stat_id>='%@') or (stat_id >='1045' and stat_id <= '%@') order by stat_id asc",strIostat,stroistat];
                [StringQuery addObject:query];
                
            }else{
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where stat_id <='%@' and stat_id>='%@'order by stat_id asc",stroistat,strIostat];
                [StringQuery addObject:query];
                
            }
        }
    }
    else if ([strIostat intValue]/100==11){
        if ([stroistat intValue] <[strIostat intValue]) {
            if ([stroistat intValue]<=1120 && [strIostat intValue] >=1134) {
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where (stat_id <='1120' and stat_id>='%@') or (stat_id >='1134' and stat_id <= '%@') order by stat_id desc",stroistat,strIostat];
                [StringQuery addObject:query];
                
            }else{
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where stat_id <='%@' and stat_id>='%@'order by stat_id desc",strIostat,stroistat];
                [StringQuery addObject:query];
                
            }
        }else{
            if ([strIostat intValue]<=1120 && [stroistat intValue] >1134) {
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where (stat_id <='1120' and stat_id>='%@' )or  (stat_id >='1134' and stat_id <= '%@') order by stat_id asc",strIostat,stroistat];
                [StringQuery addObject:query];
                
            }else{
                query=[NSString stringWithFormat:@"select stat_id  from metro_stations where stat_id <='%@' and stat_id>='%@'order by stat_id asc",strIostat,stroistat];
                [StringQuery addObject:query];
            }
        }
    }
    else{
        if ([stroistat intValue] <[strIostat intValue]) {
            query=[NSString stringWithFormat:@"select stat_id  from metro_stations where stat_id <='%@' and stat_id>='%@'order by stat_id desc",strIostat,stroistat];
            [StringQuery addObject:query];
        }else{
            query=[NSString stringWithFormat:@"select stat_id  from metro_stations where stat_id >='%@' and stat_id<='%@'order by stat_id asc",strIostat,stroistat];
            [StringQuery addObject:query];
        }
    }
    sqlite3_stmt *statement;
    NSMutableDictionary *mdict;
    NSString *Stations=nil;
    for (int k=0; k<[StringQuery count]; k++) {
        NSString *querys=[StringQuery objectAtIndex:k];
        if (sqlite3_prepare_v2(dbs, [querys UTF8String], -1, &statement, nil) ==SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                mdict = [[NSMutableDictionary alloc] init];
                int count = sqlite3_column_count(statement);
                for (int i = 0 ; i < count; i++) {
                    char *columnName = (char *)sqlite3_column_name(statement, i);
                    char *columnData = (char *)sqlite3_column_text(statement, i);
                    if (columnData) {
                        [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                    }
                    NSString *str=[mdict objectForKey:@"stat_id"];
                    if (Stations==nil) {
                        Stations=[NSString stringWithFormat:@"%@",str];
                    }else{
                        Stations=[NSString stringWithFormat:@"%@,%@",Stations,str];
                    }
                    
                }
            }
        }
        
    }
    sqlite3_finalize(statement);
    [StringQuery release];
    return Stations;
}
//查找lines
-(NSArray *)getlieswithStart:(NSString *)stroistat{
    NSArray *marray=[[NSArray alloc] init];
    NSString *query=[NSString stringWithFormat:@"select lines from metro_stations where stat_id='%@' ",stroistat];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            marray=[[mdict objectForKey:@"lines"] componentsSeparatedByString:@","];
        }
    }
    sqlite3_finalize(statement);
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
    
}
- (NSArray *)getPlanListWithStart:(NSString *)strIoStat end:(NSString *)strOiStat andType:(int)type {
    NSMutableArray *marray=[[NSMutableArray alloc] init];
    NSString *query=[NSString stringWithFormat:@"select  transfer_stats,lines from travel_plans where io_stat ='%@' and oi_stat ='%@' and (type =%d or type =2) ",strIoStat,strOiStat,type];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            NSArray *TimeTransferAry=[self getAllTime];
            NSArray * transferary= nil;
            if ([[mdict objectForKey:@"transfer_stats"] length]) {
                transferary= [[mdict objectForKey:@"transfer_stats"] componentsSeparatedByString:@","];
            } else {
                transferary = [NSArray array];
            }
            
            NSString *transfer_count=[NSString stringWithFormat:@"%d",[transferary count]];
            NSMutableArray *arys;
            arys=[NSMutableArray arrayWithArray:transferary];
            [arys addObject:strOiStat];
            NSString *statstr,*timestr,*stations;
            int stat_count=0;
            int time,times=0;
            NSString *NoticesStr;
            // NSArray *StatOilines=[self getlieswithStart:strOiStat];
            if ([transferary count]==0) {
                int statcount=sqrt(pow(([strIoStat intValue]-[strOiStat intValue]), 2));
                statstr=[NSString stringWithFormat:@"%d",statcount];
                transfer_count=@"0";
                times=[self UseringSwitchTime:strIoStat end:strOiStat lint:[strIoStat intValue]/100];
                NoticesStr=[self GetNotices:strIoStat end:strOiStat andType:[strIoStat intValue]/100];
                timestr=[NSString stringWithFormat:@"%d",times];
                stations=[self GetStations:strIoStat end:strOiStat];
            }else{
                NSString *StationAdd ,*NoticeAdd;
                for (int k=0; k<[transferary count] +1; k++) {
                    int counts;
                    if (k==0) {
                        counts=sqrt(pow(([strIoStat intValue]-[[transferary objectAtIndex:k] intValue]), 2));
                        time=[self UseringSwitchTime:strIoStat end:[transferary objectAtIndex:k] lint:[strIoStat intValue]/100];
                        NoticeAdd=[self GetNotices:strIoStat end:[transferary objectAtIndex:k] andType:[strIoStat intValue]/100];
                        
                        StationAdd=[self GetStations:strIoStat end:[transferary objectAtIndex:k]];
                    }else if(k>0 && k<=[transferary count]){
                        NSArray *arystat=[self getTheStats:[transferary objectAtIndex:k-1]];
                        int statio;
                        int statoi;
                        NSString *strStat,*strStarStat;
                        if (k==[transferary count]) {
                            statoi=[strOiStat intValue];
                            strStat=strOiStat;
                        }
                        else{
                            statoi=[[transferary objectAtIndex:k] intValue];
                            strStat=[transferary objectAtIndex:k];
                            
                        }
                        for (int ff=0; ff<[arystat count]; ff++) {
                            int statline;
                            statline=[[arystat objectAtIndex:ff] intValue];
                            if (statline/100==statoi/100) {
                                strStarStat=[arystat objectAtIndex:ff];
                                statio=statline;
                                break;
                            }
                        }
                        time=[self UseringSwitchTime:strStarStat end:strStat lint:[strStat intValue]/100];
                        StationAdd=[self GetStations:strStarStat end:strStat];
                        NoticeAdd=[self GetNotices:strStarStat end:strStat andType:[strStat intValue]/100];
                        counts=sqrt(pow((statoi-statio), 2));
                    }
                    NSString *transferTime;
                    for (int kk=0; kk<[TimeTransferAry count]; kk++) {
                        NSDictionary *timeAry=[TimeTransferAry objectAtIndex:kk];
                        NSString *timeStat_id=[timeAry objectForKey:@"stat_id"];
                        int timeLine=[[timeAry objectForKey:@"transfer_lines"] intValue];
                        transferTime=[timeAry objectForKey:@"transfer_times"];
                        if (k==[transferary count]-1) {
                            if ([timeStat_id isEqualToString:[transferary objectAtIndex:k]] && timeLine==[strOiStat intValue]/100) {
                                break;
                            }
                            
                        }else if (k<[transferary count]-1){
                            if ([timeStat_id isEqualToString:[transferary objectAtIndex:k]] && timeLine==[[transferary objectAtIndex:k+1] intValue]/100) {
                                break;
                            }
                        }
                    }
                    //int  smallTime=[[transferTime stringByReplacingOccurrencesOfString:@"分钟" withString:@""] intValue];
                    
                    int  smallTime=[transferTime intValue];
                    
                    stat_count=stat_count+counts;
                    statstr=[NSString stringWithFormat:@"%d",stat_count];
                    times=times+time+smallTime;
                    smallTime=0;
                    timestr=[NSString stringWithFormat:@"%d",times];
                    if (k==0) {
                        NoticesStr=[NSString stringWithFormat:@"%@",NoticeAdd];
                        stations=[NSString stringWithFormat:@"%@",StationAdd];
                    }else{
                        stations=[NSString stringWithFormat:@"%@,%@",stations,StationAdd];
                        NoticesStr=[NSString stringWithFormat:@"%@,%@",NoticesStr,NoticeAdd];
                    }
                }
            }
            
            NSString *strTransferStats = [mdict objectForKey:@"transfer_stats"];
            NSString *strStats =[NSString stringWithFormat:@"%@",stations];
            NSString *strLines = [mdict objectForKey:@"lines"];
            NSArray *arrayLines = [strLines componentsSeparatedByString:@","];
            
            NSArray *arrayTransferStats = [strTransferStats componentsSeparatedByString:@","];
            NSArray *arrayStats = [strStats componentsSeparatedByString:@","];
            int intRemove = 0;
            if ([arrayStats indexOfObject:[arrayTransferStats objectAtIndex:0]] == 0) {
                
                if ([arrayLines count] == 1) {
                    NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayLines objectAtIndex:0]];
                    strLines = [strLines substringFromIndex:[strReplace length]];
                }else {
                    NSString *strReplace = [NSString stringWithFormat:@"%@,", [arrayLines objectAtIndex:0]];
                    strLines = [strLines substringFromIndex:[strReplace length]];
                }
                
                if ([arrayStats count] == 1) {
                    NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayStats objectAtIndex:0]];
                    strStats = [strStats substringFromIndex:[strReplace length]];
                }else {
                    NSString *strReplace = [NSString stringWithFormat:@"%@,", [arrayStats objectAtIndex:0]];
                    strStats = [strStats substringFromIndex:[strReplace length]];
                }
                
                if ([arrayTransferStats count] == 1) {
                    NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayTransferStats objectAtIndex:0]];
                    strTransferStats = [strTransferStats substringFromIndex:[strReplace length]];
                }else {
                    NSString *strReplace = [NSString stringWithFormat:@"%@,", [arrayTransferStats objectAtIndex:0]];
                    strTransferStats = [strTransferStats substringFromIndex:[strReplace length]];
                }
                
                intRemove++;
            }
            int statCount = [arrayStats count];
            if ([arrayStats indexOfObject:[arrayTransferStats lastObject]] == (statCount -2)) {
                
                if ([arrayLines count] == (1+intRemove)) {
                    NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayLines lastObject]];
                    strLines = [strLines substringToIndex:[strLines length]-[strReplace length]];
                }else {
                    NSString *strReplace = [NSString stringWithFormat:@",%@", [arrayLines lastObject]];
                    strLines = [strLines substringToIndex:[strLines length]-[strReplace length]];
                }
                
                if ([arrayStats count] == (1+intRemove)) {
                    NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayStats lastObject]];
                    strStats = [strStats substringToIndex:[strStats length]-[strReplace length]];
                }else {
                    NSString *strReplace = [NSString stringWithFormat:@",%@", [arrayStats lastObject]];
                    strStats = [strStats substringToIndex:[strStats length]-[strReplace length]];
                }
                
                if ([arrayTransferStats count] == (1+intRemove)) {
                    NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayTransferStats lastObject]];
                    strTransferStats = [strTransferStats substringToIndex:[strTransferStats length]-[strReplace length]];
                }else {
                    NSString *strReplace = [NSString stringWithFormat:@",%@", [arrayTransferStats lastObject]];
                    strTransferStats = [strTransferStats substringToIndex:[strTransferStats length]-[strReplace length]];
                }
                
                intRemove++;
            }
            int intTransferCount =[transfer_count intValue];
            int intStatCount = [statstr intValue];
            //intStatCount = intStatCount - intTransferCount;
            
            
            NSString *statiorow=[self getrowid:strIoStat];
            NSString *statoirow=[self getrowid:strOiStat];
            NSString *free=[self getfree:statiorow end:statoirow];
            [mdict setObject:strTransferStats forKey:@"transfer_stats"];
            [mdict setObject:strLines forKey:@"lines"];
            [mdict setObject:[NSString stringWithFormat:@"%d", (intTransferCount-intRemove)] forKey:@"transfer_count"];
            [mdict setObject:[NSString stringWithFormat:@"%d",intStatCount] forKey:@"stat_count"];
            [mdict setObject:free forKey:@"fee"];
            [mdict setObject:timestr forKey:@"time"];
            [mdict setObject:NoticesStr forKey:@"notes"];
            [mdict setObject:strStats forKey:@"stations"];
            [marray addObject:mdict];
            [mdict release];
            NSLog(@"get plan list end");
        }
    }
    sqlite3_finalize(statement);
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
    
}
/*
 - (NSArray *)getPlanListWithStart:(NSString *)strIoStat end:(NSString *)strOiStat andType:(int)type {
 NSMutableArray *marray = [[NSMutableArray alloc] init];
 NSString *query = [NSString stringWithFormat:@"select transfer_count, transfer_stats, lines, notes, stat_count, stations, time, fee from travel_plans where io_stat = '%@' and oi_stat = '%@' and (type = %d or type = 2) order by seq_id asc limit 3", strIoStat, strOiStat, type];
 sqlite3_stmt *statement;
 if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
 while (sqlite3_step(statement) == SQLITE_ROW) {
 NSLog(@"get plan list");
 NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
 int count = sqlite3_column_count(statement);
 for (int i = 0 ; i < count; i++) {
 char *columnName = (char *)sqlite3_column_name(statement, i);
 char *columnData = (char *)sqlite3_column_text(statement, i);
 if (columnData) {
 [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
 }
 }
 NSString *strTransferCount = [mdict objectForKey:@"transfer_count"];
 //   NSString *strTransferCount = @"4";
 NSString *strTransferStats = [mdict objectForKey:@"transfer_stats"];
 NSString *strStatCount = [mdict objectForKey:@"stat_count"];
 NSString *strStats = [mdict objectForKey:@"stations"];
 NSString *strLines = [mdict objectForKey:@"lines"];
 NSArray *arrayLines = [strLines componentsSeparatedByString:@","];
 
 NSArray *arrayTransferStats = [strTransferStats componentsSeparatedByString:@","];
 NSArray *arrayStats = [strStats componentsSeparatedByString:@","];
 int intRemove = 0;
 if ([arrayStats indexOfObject:[arrayTransferStats objectAtIndex:0]] == 0) {
 if ([arrayLines count] == 1) {
 NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayLines objectAtIndex:0]];
 strLines = [strLines substringFromIndex:[strReplace length]];
 }else {
 NSString *strReplace = [NSString stringWithFormat:@"%@,", [arrayLines objectAtIndex:0]];
 strLines = [strLines substringFromIndex:[strReplace length]];
 }
 
 if ([arrayStats count] == 1) {
 NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayStats objectAtIndex:0]];
 strStats = [strStats substringFromIndex:[strReplace length]];
 }else {
 NSString *strReplace = [NSString stringWithFormat:@"%@,", [arrayStats objectAtIndex:0]];
 strStats = [strStats substringFromIndex:[strReplace length]];
 }
 
 if ([arrayTransferStats count] == 1) {
 NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayTransferStats objectAtIndex:0]];
 strTransferStats = [strTransferStats substringFromIndex:[strReplace length]];
 }else {
 NSString *strReplace = [NSString stringWithFormat:@"%@,", [arrayTransferStats objectAtIndex:0]];
 strTransferStats = [strTransferStats substringFromIndex:[strReplace length]];
 }
 
 intRemove++;
 }
 int statCount = [arrayStats count];
 if ([arrayStats indexOfObject:[arrayTransferStats lastObject]] == (statCount -2)) {
 
 if ([arrayLines count] == (1+intRemove)) {
 NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayLines lastObject]];
 strLines = [strLines substringToIndex:[strLines length]-[strReplace length]];
 }else {
 NSString *strReplace = [NSString stringWithFormat:@",%@", [arrayLines lastObject]];
 strLines = [strLines substringToIndex:[strLines length]-[strReplace length]];
 }
 
 if ([arrayStats count] == (1+intRemove)) {
 NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayStats lastObject]];
 strStats = [strStats substringToIndex:[strStats length]-[strReplace length]];
 }else {
 NSString *strReplace = [NSString stringWithFormat:@",%@", [arrayStats lastObject]];
 strStats = [strStats substringToIndex:[strStats length]-[strReplace length]];
 }
 
 if ([arrayTransferStats count] == (1+intRemove)) {
 NSString *strReplace = [NSString stringWithFormat:@"%@", [arrayTransferStats lastObject]];
 strTransferStats = [strTransferStats substringToIndex:[strTransferStats length]-[strReplace length]];
 }else {
 NSString *strReplace = [NSString stringWithFormat:@",%@", [arrayTransferStats lastObject]];
 strTransferStats = [strTransferStats substringToIndex:[strTransferStats length]-[strReplace length]];
 }
 
 intRemove++;
 }
 int intStatCount = [strStatCount intValue];
 int intTransferCount = [strTransferCount intValue];
 intStatCount = intStatCount - intTransferCount;
 
 
 [mdict setObject:strTransferStats forKey:@"transfer_stats"];
 [mdict setObject:strLines forKey:@"lines"];
 [mdict setObject:strStats forKey:@"stations"];
 [mdict setObject:[NSString stringWithFormat:@"%d",intStatCount] forKey:@"stat_count"];
 [mdict setObject:[NSString stringWithFormat:@"%d", (intTransferCount-intRemove)] forKey:@"transfer_count"];
 [marray addObject:mdict];
 [mdict release];
 NSLog(@"get plan list end");
 }
 }
 sqlite3_finalize(statement);
 NSArray *arrayRet = [NSArray arrayWithArray:marray];
 [marray release];
 return arrayRet;
 }
 */
- (NSString *)getTransferStatsWithTransferStats:(NSString *)strTransfers stations:(NSArray *)arrayStats andTransferStations:(NSArray *)arrayTransfers {
    NSString *strRet = strTransfers;
    
    for (int i = 0; i < [arraySpecialNodes count]; i++) {
        NSString *strNode = [arraySpecialNodes objectAtIndex:i];
        NSUInteger _intIndex = [arrayStats indexOfObject:strNode];
        if ((_intIndex != NSNotFound)&&(_intIndex < ([arrayStats count] - 1))&&(_intIndex > 0)) {
            int type = [[self.dictSpecials objectForKey:strNode] intValue];
            if (type == 0) {
                if (([arrayTransfers count] == 1)&&([[arrayTransfers objectAtIndex:0] isEqualToString:@""])) {
                    strRet =[strRet stringByAppendingString:strNode];
                }else {
                    for (int j = 0; j < [arrayTransfers count]; j++) {
                        NSString *strTransfer = [arrayTransfers objectAtIndex:j];
                        if ([strTransfer hasPrefix:[strNode substringToIndex:2]]) {
                            NSUInteger _indexTransfer = [arrayStats indexOfObject:[arrayTransfers objectAtIndex:j]];
                            if (_intIndex < _indexTransfer) {
                                strRet = [strRet stringByReplacingOccurrencesOfString:strTransfers withString:[NSString stringWithFormat:@"%@,%@", strNode, strTransfers]];
                                break;
                            }
                        }
                        if (j == ([arrayTransfers count] - 1)) {
                            strRet = [strRet stringByAppendingString:[NSString stringWithFormat:@",%@", strNode]];
                        }
                    }
                }
                
            }else if ((type == 1)&&(([[arrayStats objectAtIndex:(_intIndex+1)] intValue] < [strNode intValue]))) {
                if (([arrayTransfers count] == 1)&&([[arrayTransfers objectAtIndex:0] isEqualToString:@""])) {
                    strRet =[strRet stringByAppendingString:strNode];
                }else {
                    for (int j = 0; j < [arrayTransfers count]; j++) {
                        NSString *strTransfer = [arrayTransfers objectAtIndex:j];
                        if ([strTransfer hasPrefix:[strNode substringToIndex:2]]) {
                            NSUInteger _indexTransfer = [arrayStats indexOfObject:[arrayTransfers objectAtIndex:j]];
                            if (_intIndex < _indexTransfer) {
                                strRet = [strRet stringByReplacingOccurrencesOfString:strTransfers withString:[NSString stringWithFormat:@"%@,%@", strNode, strTransfers]];
                                break;
                            }
                        }
                        if (j == ([arrayTransfers count] - 1)) {
                            strRet = [strRet stringByAppendingString:[NSString stringWithFormat:@",%@", strNode]];
                        }
                    }
                }
            }
        }
        
    }
    return strRet;
}

- (NSDictionary *)getPlanDetailWithPlan:(NSDictionary *)dictPlan andType:(int)type {
    NSString *strStats = [dictPlan objectForKey:@"stations"];
    NSArray *arrayStations = [strStats componentsSeparatedByString:@","];
    NSArray *arrayTransferStats = [[dictPlan objectForKey:@"transfer_stats"] componentsSeparatedByString:@","];
    NSMutableDictionary *mdictPlan = [[NSMutableDictionary alloc] initWithDictionary:dictPlan];
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSString *strCondition = [[NSString stringWithFormat:@"'%@'",strStats] stringByReplacingOccurrencesOfString:@"," withString:@"','"];
    NSString *query = [NSString stringWithFormat:@"select stat_id, name_cn, name_en,x, y from metro_stations where stat_id in (%@)", strCondition];
    NSMutableDictionary *mdictTmp = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            [mdictTmp setObject:mdict forKey:[mdict objectForKey:@"stat_id"]];
            [mdict release];
        }
    }
    sqlite3_finalize(statement);
    NSString *strNewTransferStats = [self getTransferStatsWithTransferStats:[dictPlan objectForKey:@"transfer_stats"]
                                                                   stations:arrayStations
                                                        andTransferStations:arrayTransferStats];
    arrayTransferStats = [strNewTransferStats componentsSeparatedByString:@","];
    [mdictPlan setObject:strNewTransferStats forKey:@"transfer_stats"];
    NSArray * transferary= nil;
    if ([strNewTransferStats length]) {
        transferary= [strNewTransferStats componentsSeparatedByString:@","];
    } else {
        transferary = [NSArray array];
    }
    
    for (int i = 0; i < [arrayStations count]; i++) {
        NSString *stat_id = [arrayStations objectAtIndex:i];
        NSMutableDictionary *mdict = [mdictTmp objectForKey:stat_id];
        int line_id = [[stat_id substringToIndex:2] intValue];
        int type;
        if (i == 0) {
            type = 0;
        }else if (i == ([arrayStations count]-1)) {
            type = 2;
        }else if ([arrayTransferStats indexOfObject:stat_id] != NSNotFound) {
            type = 1;
        }else {
            type = 3;
        }
        [mdict setObject:[NSString stringWithFormat:@"%d",line_id] forKey:@"line_id"];
        [mdict setObject:[NSString stringWithFormat:@"%d",type] forKey:@"type"];
        [marray addObject:mdict];
    }
    NSString *strIoStat=[[marray objectAtIndex:0] objectForKey:@"stat_id"];
    NSString *strOiStat=[[marray lastObject] objectForKey:@"stat_id"];
    NSString *NoticesStr;
    if ([transferary count]==0) {
        NoticesStr=[self GetNotices:strIoStat end:strOiStat andType:[strIoStat intValue]/100];
    }else{
        NSString *NoticeAdd;
        for (int k=0; k<[transferary count] +1; k++) {
            if (k==0) {
                //NSLog(@"%@",[transferary objectAtIndex:k]);
                NoticeAdd=[self GetNotices:strIoStat end:[transferary objectAtIndex:k] andType:[strIoStat intValue]/100];
            }else if(k>0 && k<=[transferary count]){
                NSArray *arystat=[self getTheStats:[transferary objectAtIndex:k-1]];
                int statio;
                int statoi;
                NSString *strStat,*strStarStat;
                if (k==[transferary count]) {
                    statoi=[strOiStat intValue];
                    strStat=strOiStat;
                }
                else{
                    statoi=[[transferary objectAtIndex:k] intValue];
                    strStat=[transferary objectAtIndex:k];
                    
                }
                for (int ff=0; ff<[arystat count]; ff++) {
                    int statline;
                    statline=[[arystat objectAtIndex:ff] intValue];
                    if (statline/100==statoi/100) {
                        strStarStat=[arystat objectAtIndex:ff];
                        statio=statline;
                        break;
                    }
                }
                NSLog(@"%@ %@",strStarStat,strStat);
                NoticeAdd=[self GetNotices:strStarStat end:strStat andType:[strStat intValue]/100];
            }
            if (k==0) {
                NoticesStr=[NSString stringWithFormat:@"%@",NoticeAdd];
            }else{
                NoticesStr=[NSString stringWithFormat:@"%@,%@",NoticesStr,NoticeAdd];
            }
        }
    }
    [mdictTmp release];
    [mdictPlan setObject:NoticesStr forKey:@"notes"];
    [mdictPlan setObject:marray forKey:@"stations"];
    [marray release];
    NSDictionary *dictRet = [NSDictionary dictionaryWithDictionary:mdictPlan];
    [mdictPlan release];
    return dictRet;
}

- (NSArray *)getAllLinesInfo {
    localdic=[[PlistUtils sharedPlistData] getviewdictionary:@"DataBase"];
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSString *query = @"select line_id, stations, type  from metro_lines order by seq_id";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            [marray addObject:mdict];
            [mdict release];
        }
    }
    sqlite3_finalize(statement);
    for (int i = 0; i < [marray count]; i++) {
        NSDictionary *dictStart = [[self.arrayLine objectAtIndex:i] objectAtIndex:0];
        NSDictionary *dictEnd = [[self.arrayLine objectAtIndex:i] lastObject];
        NSMutableDictionary *mdict = [marray objectAtIndex:i];
        if ((i == 0)||(i == 1)||(i == 2)||(i == 5)||(i == 6)||(i == 7)||(i == 9)||(i == 10))
        {
            NSString *strStart = nil;
            NSString *strEnd = nil;
            if (i == 9)
            {
                strStart = [NSString stringWithFormat:@"%@\\%@",[dictStart objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]],[localdic objectForKey:@"hongqiao"]];
                [mdict setObject:strStart forKey:@"startname"];
                [mdict setObject:[dictEnd objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]] forKey:@"endname"];
            }
            else if (i == 10)
            {
                strStart = [NSString stringWithFormat:@"%@\\%@",[dictStart objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]],[localdic objectForKey:@"jiading"]];
                [mdict setObject:strStart forKey:@"startname"];
                [mdict setObject:[dictEnd objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]] forKey:@"endname"];
            }
            else if (i == 0)
            {
                strEnd = [NSString stringWithFormat:@"%@\\%@",[localdic objectForKey:@"shanghaih"],[dictEnd objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]];
                [mdict setObject:[dictStart objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]] forKey:@"startname"];
                [mdict setObject:strEnd forKey:@"endname"];
            }
            else if (i == 2)
            {
                strEnd = [NSString stringWithFormat:@"%@\\%@",[localdic objectForKey:@"changjiang"],[dictEnd objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]];
                [mdict setObject:[dictStart objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]] forKey:@"startname"];
                [mdict setObject:strEnd forKey:@"endname"];
            }
            if (i == 7)
            {
                strStart = [NSString stringWithFormat:@"%@\\%@",[dictStart objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]],[localdic objectForKey:@"dongfang"]];
                [mdict setObject:strStart forKey:@"startname"];
                [mdict setObject:[dictEnd objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]] forKey:@"endname"];
            }
            if (i == 6)
            {
                strStart = [NSString stringWithFormat:@"%@\\%@",[dictStart objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]],[localdic objectForKey:@"shanghaiun"]];
                [mdict setObject:strStart forKey:@"startname"];
                [mdict setObject:[dictEnd objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]] forKey:@"endname"];
            }
            if (i == 5)
            {
                strStart = [NSString stringWithFormat:@"%@\\%@",[dictStart objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]],[localdic objectForKey:@"gaoqing"]];
                strEnd = [NSString stringWithFormat:@"%@\\%@",[localdic objectForKey:@"jufeng"],[dictEnd objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]];
                [mdict setObject:strStart forKey:@"startname"];
                [mdict setObject:strEnd forKey:@"endname"];
                
                
            }
            if (i == 1)
            {
                strStart = [NSString stringWithFormat:@"%@\\%@",[dictStart objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]],[localdic objectForKey:@"songhong"]];
                strEnd = [NSString stringWithFormat:@"%@ - \%@",[localdic objectForKey:@"guanglan"],[dictEnd objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]];
                [mdict setObject:strStart forKey:@"startname"];
                [mdict setObject:strEnd forKey:@"endname"];
            }
            
        }
        else
        {
            [mdict setObject:[dictStart objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]] forKey:@"startname"];
            [mdict setObject:[dictEnd objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]] forKey:@"endname"];
            
        }
    }
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
}

- (NSArray *)getStationListWithLineNo:(int)lineNo {
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"select stat_id, name_cn, name_en, toilet_inside,lines from metro_stations where stat_id like '%02d%%' and type=1 order by stat_id asc",lineNo];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            [marray addObject:mdict];
            [mdict release];
        }
    }
    sqlite3_finalize(statement);
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
}

- (NSArray *)getStationNameListWithLineNo:(int)lineNo {
    
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"select name_cn ,name_en from metro_stations where stat_id like '%02d%%' and type=1 order by stat_id asc",lineNo];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    NSString *lineId = [NSString stringWithFormat:@"%d",lineNo];
                    NSString *stationName = [NSString stringWithUTF8String:columnData];
                    stationName = [stationName stringByAppendingString:lineId];
                    [mdict setObject:stationName forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            [marray addObject:mdict];
            [mdict release];
        }
    }
    sqlite3_finalize(statement);
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
    
}

- (NSString *)getNameCnWithStatId:(NSString *)strStatId {
    int line_id = [[strStatId substringToIndex:2] intValue]-1;
    NSArray *array = [self.arrayLine objectAtIndex:line_id];
    NSString *strRet = @"";
    for (int i = 0; i < [array count]; i++) {
        if ([[[array objectAtIndex:i] objectForKey:@"stat_id"] isEqualToString:strStatId]) {
            strRet = [[array objectAtIndex:i] objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]];
            break;
        }
    }
    return strRet;
}


- (NSDictionary *)getStationInfoWithStationId:(NSString *)strStatId {
    NSMutableDictionary *mdictStat = [[NSMutableDictionary alloc] init];
    NSString *query = [NSString stringWithFormat:@"select * from metro_stations where stat_id = '%@'",strStatId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int count = sqlite3_column_count(statement);
            for (int i = 0; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdictStat setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
        }
    }
    sqlite3_finalize(statement);
    
    NSMutableArray *marrayFirstEndRun = [[NSMutableArray alloc] init];
    NSString *query1 = nil;
    if ([self.dictTransfers objectForKey:[mdictStat objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]]) {//is transfer station
        NSMutableString *mstr = [NSMutableString string];
        NSArray *arrayStatIds = [self.dictTransfers objectForKey:[mdictStat objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]];
        for (int i = 0; i < [arrayStatIds count]; i++) {
            if (i == 0) {
                [mstr appendFormat:@"'%@'",[arrayStatIds objectAtIndex:i]];
            }else {
                [mstr appendFormat:@",'%@'",[arrayStatIds objectAtIndex:i]];
            }
        }
        query1 = [NSString stringWithFormat:@"select line_id, stat_end_id, first_run, end_run from metro_first_end_run where stat_id in (%@) order by stat_id asc",mstr];
    }else {
        query1 = [NSString stringWithFormat:@"select line_id, stat_end_id, first_run, end_run from metro_first_end_run where stat_id = '%@'",strStatId];
    }
    
    sqlite3_stmt *statement1;
    if (sqlite3_prepare_v2(dbs, [query1 UTF8String], -1, &statement1, nil) == SQLITE_OK) {
        while (sqlite3_step(statement1) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement1);
            for (int i = 0 ; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement1, i);
                char *columnData = (char *)sqlite3_column_text(statement1, i);
                if (columnData) {
                    NSString *strColumnName = [NSString stringWithUTF8String:columnName];
                    if ([strColumnName isEqualToString:@"stat_end_id"]) {
                        if ([[mdict objectForKey:@"line_id"] isEqualToString:@"4"]) {
                            //                            if ([[NSString stringWithUTF8String:columnData] isEqualToString:@"0402"]) {
                            //                                [mdict setObject:[self getNameCnWithStatId:[NSString stringWithUTF8String:columnData]] forKey:strColumnName];
                            //                            }else {
                            [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:strColumnName];
                            //                            }
                        }else {
                            [mdict setObject:[self getNameCnWithStatId:[NSString stringWithUTF8String:columnData]] forKey:strColumnName];
                        }
                        
                    }else {
                        [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:strColumnName];
                    }
                }
            }
            [marrayFirstEndRun addObject:mdict];
            [mdict release];
        }
    }
    sqlite3_finalize(statement1);
    [mdictStat setObject:marrayFirstEndRun forKey:@"firstendrun"];
    [marrayFirstEndRun release];
    NSDictionary *dictRet = [NSDictionary dictionaryWithDictionary:mdictStat];
    [mdictStat release];
    return dictRet;
}

- (NSDictionary *)getSearchList {
    NSMutableDictionary *mdictList = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *mdictTmp = [[NSMutableDictionary alloc] init];
    NSString *query = [NSString stringWithFormat:@"select stat_id, name_en, name_cn,pinyin, lines from metro_stations where type=1"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            if ([mdictTmp objectForKey:[mdict objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]] == nil) {
                NSString *strFirstLetter = [[[mdict objectForKey:@"pinyin"] substringToIndex:1] uppercaseString];
                NSMutableArray *marray = [mdictList objectForKey:strFirstLetter];
                if (marray == nil) {
                    marray = [[NSMutableArray alloc] init];
                    [marray addObject:mdict];
                    [mdictList setObject:marray forKey:strFirstLetter];
                    [marray release];
                }else {
                    [marray addObject:mdict];
                }
                [mdictTmp setObject:mdict forKey:[mdict objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]];
            }
            [mdict release];
        }
    }
    sqlite3_finalize(statement);
    NSDictionary *dictRet = [NSDictionary dictionaryWithDictionary:mdictList];
    [mdictTmp release];
    [mdictList release];
    return dictRet;
}



-(NSArray*)getAllCoordinate
{
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSMutableDictionary *mdictTmp = [[NSMutableDictionary alloc] init];
    NSString *query = [NSString stringWithFormat:@"select stat_id, name_cn,name_en, lines, longitude,latitude from metro_stations where type=1"];
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while(sqlite3_step(statement) ==SQLITE_ROW)
        {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            if ([mdictTmp objectForKey:[mdict objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]] == nil) {
                [marray addObject:mdict];
                [mdictTmp setObject:mdict forKey:[mdict objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]];
            }
            [mdict release];
        }
    }
    sqlite3_finalize(statement);
    [mdictTmp release];
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
}


- (NSArray *)getsearchResultWith:(NSString *)strKeyWord {
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSMutableDictionary *mdictTmp = [[NSMutableDictionary alloc] init];
    NSString *query = [NSString stringWithFormat:@"select stat_id, name_en, name_cn, lines from metro_stations where (name_cn like '%@%%' or (name_en like '%@%%') or (pinyin like '%@%%') or (fullpinyin like '%@%%')) and type=1",strKeyWord, strKeyWord, strKeyWord, strKeyWord];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            if ([mdictTmp objectForKey:[mdict objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]] == nil) {
                [marray addObject:mdict];
                [mdictTmp setObject:mdict forKey:[mdict objectForKey:[[PlistUtils sharedPlistData] getviewstring:@"name"]]];
            }
            [mdict release];
        }
    }
    sqlite3_finalize(statement);
    [mdictTmp release];
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
}


- (NSArray *)getAllTime
{
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithString:@"select * from transfer_stat"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbs, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count(statement);
            for (int i = 0; i < count; i++) {
                char *columnName = (char *)sqlite3_column_name(statement, i);
                char *columnData = (char *)sqlite3_column_text(statement, i);
                if (columnData) {
                    [mdict setObject:[NSString stringWithUTF8String:columnData] forKey:[NSString stringWithUTF8String:columnName]];
                }
            }
            [marray addObject:mdict];
            [mdict release];
        }
    }
    sqlite3_finalize(statement);
    NSArray *arrayRet = [NSArray arrayWithArray:marray];
    [marray release];
    return arrayRet;
}

@end
