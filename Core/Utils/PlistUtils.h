//
//  PlistUtils.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-19.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistUtils : NSObject{
    
    NSDictionary *alldic;
    NSDictionary *viewalldic;
    
}

-(id)init:(NSString *)info;
+(PlistUtils *)sharedPlistData;
-(NSDictionary *)getthisdictionary:(NSString *)sender;
-(NSString *)getusensstring:(NSString *)sender;
-(NSDictionary *)getviewdictionary:(NSString *)sender;
-(NSString *)getviewstring:(NSString *)sender;


@end
