//
//  ClockModel.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-8-2.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "ClockModel.h"

@implementation ClockModel

@synthesize repeatStr;
@synthesize startStation;
@synthesize endStation;
@synthesize clockTime;
@synthesize clockVoice;
@synthesize isShake;

-(id)init
{
    if(self = [super init]){
        self.repeatStr = [[NSString alloc] initWithString:@""];
    }
    return self;
}

@end
