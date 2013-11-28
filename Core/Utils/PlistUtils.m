//
//  PlistUtils.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-19.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "PlistUtils.h"

@implementation PlistUtils

static PlistUtils *sharedPlistData=nil;
+(PlistUtils *)sharedPlistData{
    @synchronized(self) {
		if (sharedPlistData == nil) {
			sharedPlistData = [[super allocWithZone:NULL] init];
		}
	}
    return sharedPlistData;
}
+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		return [[self sharedPlistData] retain];
	}
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}
- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (oneway void)release {
	
}


- (id)retain {
	return self;
}

-(id)autorelease{
    return self;
}
-(id)init:(NSString *)info{
    if ((self=[super init])) {
        NSString *path=[[NSBundle mainBundle] pathForResource:@"DataInfo.plist" ofType:nil];
        NSDictionary * dicall=[[NSDictionary alloc] initWithContentsOfFile:path];
        alldic=[[dicall objectForKey:info] retain];
        NSString *paths=[[NSBundle mainBundle] pathForResource:@"objectcen.plist" ofType:nil];
        NSDictionary *viewdic=[[NSDictionary alloc] initWithContentsOfFile:paths];
        viewalldic=[[viewdic objectForKey:info] retain];
    }
    return self;
}

-(NSDictionary *)getthisdictionary:(NSString *)sender{
    NSDictionary * viewdic=[alldic objectForKey:sender];
    return  viewdic;
}
-(NSString *)getusensstring:(NSString *)sender{
    NSString *string=[alldic objectForKey:sender];
    return string;
}
-(NSDictionary *)getviewdictionary:(NSString *)sender{
    NSDictionary *viewdic=[viewalldic objectForKey:sender];
    return viewdic;
}
-(NSString *)getviewstring:(NSString *)sender{
    NSString *str=[viewalldic objectForKey:sender];
    return str;
}
- (void)dealloc {
    
    [super dealloc];
}



@end
