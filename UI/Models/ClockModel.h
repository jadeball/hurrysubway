//
//  ClockModel.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-8-2.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClockModel : NSObject{
    
    NSString *repeatStr;
    NSString *startStation;
    NSString *endStation;
    NSString *clockTime;
    NSString *clockVoice;
    BOOL isShake;
}

@property(nonatomic,retain)NSString *repeatStr;
@property(nonatomic,retain)NSString *startStation;
@property(nonatomic,retain)NSString *endStation;
@property(nonatomic,retain)NSString *clockTime;
@property(nonatomic,retain)NSString *clockVoice;
@property(nonatomic)BOOL isShake;

@end
