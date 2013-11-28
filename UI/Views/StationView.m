//
//  StationView.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-7-7.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "StationView.h"
#import "StationButton.h"
#import "PlistUtils.h"


@implementation StationView
@synthesize stationDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _stationBtn = [[StationButton alloc] initWithFrame:CGRectMake(0, 4, 158, 39)];
        [_stationBtn addTarget:self action:@selector(stationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_stationBtn];
        
        
        
        //        UIButton *btnGps = [[UIButton alloc] initWithFrame:CGRectMake(80, (8+39+6), 74, 30)];
        //        NSString *strBtnGpsPath = [[NSBundle mainBundle] pathForResource:@"btnplangps" ofType:@"png"];
        //        [btnGps setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnGpsPath] forState:UIControlStateNormal];
        //        NSString *strBtnGpshHighlightedPath = [[NSBundle mainBundle] pathForResource:@"btnplangpshighlighted" ofType:@"png"];
        //        [btnGps setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnGpshHighlightedPath] forState:UIControlStateHighlighted];
        //        [btnGps addTarget:self action:@selector(btnGpsClick) forControlEvents:UIControlEventTouchUpInside];
        //        [self addSubview:btnGps];
        //        [btnGps release];
        
        //        UIButton *btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake(160, (8+39+6), 74, 30)];
        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)stationBtnClick:(StationButton *)btn {
    if ([stationDelegate respondsToSelector:@selector(stationBtnisClicked:)]) {
        [stationDelegate stationBtnisClicked:self];
    }
}



-(void)btnGpsClick
{
    if ([stationDelegate respondsToSelector:@selector(btnGpsisClicked:)]) {
        [stationDelegate btnGpsisClicked:self];
    }
}





- (void)setStationNo:(int)stationNo {
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"addClock"];
    NSString *_str = [localdic objectForKey:@"line"];
    if (stationNo > 0)
    {
        
        if (_str.length>2) {
            [_stationBtn setStationNo:[NSString stringWithFormat:@"%@ %d",_str,stationNo]];
            
        }else{
            [_stationBtn setStationNo:[NSString stringWithFormat:@"%d %@",stationNo,_str]];
            
        }
        
    }
    else if(stationNo <= 0)
    {
        //        if ([currentLanguages isEqualToString:@"en"]) {
        //            [_lineBtn setLineNo:@"Transfer station"];
        //        }
        
        [_stationBtn setStationNo:[localdic objectForKey:@"tranfors"]];
        
    }
    //  else
    //  {
    //      [_lineBtn setLineNo:@""];
    //  }
    
}

- (void)setStationNoBackgroundColor:(UIColor *)bgColor {
    [_stationBtn setStationNoBackgroundColor:bgColor];
}

- (void)setStationName:(NSString *)strStationName {
    [_stationBtn setStationName:strStationName];
}

- (void)setStartStatusWithFlag:(int)flag {
    [_stationBtn setStartStatusWithFlag:flag];
}

- (void)resetStatus {
    [_stationBtn resetStatus];
}

- (void)dealloc
{
    [_stationBtn release];
    [super dealloc];
}

@end
