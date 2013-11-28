//
//  LineLabel.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-7-7.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "LineLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "PlistUtils.h"

@interface LineLabel ()

- (UIColor *)getColorForLineNo:(int)lineNo;

@end

@implementation LineLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textAlignment = UITextAlignmentCenter;
        self.layer.cornerRadius = 3.0;
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setLineNo:(int)lineNo withFlag:(BOOL)isLongName {
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"addClock"];
    self.backgroundColor = [self getColorForLineNo:lineNo];
    if (isLongName) {
        NSString * line=[localdic objectForKey:@"line"];
        if (line.length >2) {
            self.text = [NSString stringWithFormat:@"%@%d",line,lineNo];
        }else{
            self.text = [NSString stringWithFormat:@"%d%@",lineNo,line];
        }
        
    }else {
        self.text = [NSString stringWithFormat:@"%d",lineNo];
    }
}

- (UIColor *)getColorForLineNo:(int)lineNo {
    UIColor *color = nil;
    switch (lineNo) {
        case 1:
            color = [UIColor redColor];
            break;
        case 2:
            color = [UIColor colorWithRed:119/255.0f green:204/255.0f blue:51/255.0f alpha:1.0];
            break;
        case 3:
            color = [UIColor colorWithRed:255/255.0f green:204/255.0f blue:0/255.0f alpha:1.0];
            break;
        case 4:
            color = [UIColor colorWithRed:102/255.0f green:51/255.0f blue:204/255.0f alpha:1.0];
            break;
        case 5:
            color = [UIColor colorWithRed:166/255.0f green:79/255.0f blue:255/255.0f alpha:1.0];
            break;
        case 6:
            color = [UIColor colorWithRed:255/255.0f green:0/255.0f blue:153/255.0f alpha:1.0];
            break;
        case 7:
            color = [UIColor colorWithRed:255/255.0f green:102/255.0f blue:0/255.0f alpha:1.0];
            break;
        case 8:
            color = [UIColor colorWithRed:51/255.0f green:153/255.0f blue:255/255.0f alpha:1.0];
            break;
        case 9:
            color = [UIColor colorWithRed:136/255.0f green:196/255.0f blue:255/255.0f alpha:1.0];
            break;
        case 10:
            color = [UIColor colorWithRed:204/255.0f green:153/255.0f blue:255/255.0f alpha:1.0];
            break;
        case 11:
            color = [UIColor colorWithRed:102/255.0f green:0/255.0f blue:0/255.0f alpha:1.0];
            break;
        default:
            break;
    }
    return color;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)dealloc
{
    [super dealloc];
}

@end
