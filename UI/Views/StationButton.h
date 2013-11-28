//
//  StationButton.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-7-7.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationButton : UIButton{
    UILabel *_lblStationNo;
    UILabel *_lblStationName;
}

- (void)setStationNo:(NSString *)strStationNo;
- (void)setStationNoTextColor:(UIColor *)textColor;
- (void)setStationNoBackgroundColor:(UIColor *)bgColor;
- (void)setStationName:(NSString *)strStationName;
- (void)resetStatus;
- (void)setStartStatusWithFlag:(int)flag;

@end
