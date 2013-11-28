//
//  StationButton.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-7-7.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "StationButton.h"
#import <QuartzCore/QuartzCore.h>
#import "PlistUtils.h"


@implementation StationButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _lblStationNo = [[UILabel alloc] initWithFrame:CGRectMake(12, 9, 22, 21)];
        _lblStationNo.backgroundColor = [UIColor clearColor];
        _lblStationNo.textAlignment = UITextAlignmentCenter;
        _lblStationNo.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:13.0f];
        
        _lblStationNo.textColor = [UIColor whiteColor];
        [self addSubview:_lblStationNo];
        
        _lblStationName = [[UILabel alloc] initWithFrame:CGRectMake(40, 9, 100, 21)];
        _lblStationName.backgroundColor = [UIColor clearColor];
        _lblStationName.textColor = [UIColor blackColor];
        [self addSubview:_lblStationName];
        
//        NSString *strBtnStartOrEndPath = [[NSBundle mainBundle] pathForResource:@"btnstartorend" ofType:@"png"];
//        [self setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnStartOrEndPath] forState:UIControlStateNormal];
//        
//        NSString *strBtnStartOrEndHighlightedPath = [[NSBundle mainBundle] pathForResource:@"btnstartorendhighlighted" ofType:@"png"];
//        [self setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnStartOrEndHighlightedPath] forState:UIControlStateHighlighted];
    }
    return self;
}


- (void)setStartStatusWithFlag:(int)flag {
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"addClock"];
    
    _lblStationNo.textColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0];
    _lblStationNo.textAlignment = UITextAlignmentLeft;
    _lblStationNo.backgroundColor = [UIColor clearColor];
    _lblStationName.text = nil;
    if (flag == 0) {
        _lblStationNo.frame = CGRectMake(12, 9, 160, 21);
        _lblStationNo.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.0f];
        //PlistUtils *plistUtils= [PlistUtils sharedPlistData];
        _lblStationNo.text = [localdic objectForKey:@"qidianChoose"];
    }else if(flag == 1) {
        _lblStationNo.frame = CGRectMake(12, 9, 160, 21);
        _lblStationNo.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.0f];
        _lblStationNo.text = [localdic objectForKey:@"zhongdianChoose"];
        
    } else if(flag == 2){
        _lblStationNo.frame = CGRectMake(12, 9, 160, 21);
        _lblStationNo.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.0f];
        _lblStationNo.text = [localdic objectForKey:@"clockTimeChoose"];
    }
    

}

- (void)resetStatus {
    _lblStationNo.frame = CGRectMake(12, 9, 22, 21);
    _lblStationNo.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:13.0f];
    _lblStationNo.textColor = [UIColor whiteColor];
    _lblStationNo.textAlignment = UITextAlignmentCenter;
    _lblStationNo.text = @"";
}

- (void)setStationNo:(NSString *)strStationNo {
    
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"addClock"];
    
    if (_lblStationNo.textAlignment != UITextAlignmentCenter) {
        _lblStationNo.textAlignment = UITextAlignmentCenter;
    }
    _lblStationNo.text = strStationNo;
    if([_lblStationNo.text isEqualToString:[localdic objectForKey:@"tranfors"]])
    {
        _lblStationNo.textColor = [UIColor blackColor];
    }
    //    if ([_lblLineNo.text isEqualToString:@"Transfer station"]) {
    //        _lblLineNo.textColor = [UIColor blackColor];
    //    }
    CGSize sizeStationNo = [_lblStationNo sizeThatFits:CGSizeZero];
    CGRect rectStationNo = _lblStationNo.frame;
    rectStationNo.size.width = sizeStationNo.width+22;
    _lblStationNo.frame = rectStationNo;
    
}

- (void)setStationNoTextColor:(UIColor *)textColor {
    _lblStationNo.textColor = textColor;
}

- (void)setStationNoBackgroundColor:(UIColor *)bgColor {
    _lblStationNo.backgroundColor = bgColor;
}

- (void)setStationName:(NSString *)strStationName {
    
    _lblStationName.text = strStationName;
    _lblStationName.lineBreakMode = UILineBreakModeWordWrap;
    _lblStationName.numberOfLines = 0;
    
    //    if ([currentLanguages isEqualToString:@"en"]) {
    //         _lblStationName.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:13.0f];
    //        if (_lblStationName.text.length >11) {
    //             [_lblStationName setFrame:CGRectMake(40, 2, 100, 40)];
    //            _lblStationName.lineBreakMode = UILineBreakModeWordWrap;
    //            _lblStationName.numberOfLines = 2;
    //
    //        }
    //    }
    //    else{
    _lblStationName.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:13.0f];
    
    
    CGSize sizeName = [_lblStationName sizeThatFits:CGSizeZero];
    CGRect rectName = _lblStationName.frame;
    if ((_lblStationNo.frame.size.width+12+sizeName.width) < 202) {
        if (_lblStationNo.frame.origin.x+_lblStationNo.frame.size.width+12 < 80) {
            rectName.origin.x = 80;
        }else {
            rectName.origin.x = _lblStationNo.frame.origin.x+_lblStationNo.frame.size.width+12;
        }
        
        rectName.size.width = sizeName.width;
    }else {
        rectName.origin.x = _lblStationNo.frame.origin.x+_lblStationNo.frame.size.width+12;
        rectName.size.width = 202-rectName.origin.x;
    }
    _lblStationName.frame = rectName;
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
    [_lblStationNo release];
    [_lblStationName release];
    [super dealloc];
}

@end
