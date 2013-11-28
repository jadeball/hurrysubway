//
//  StationView.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-7-7.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StationViewDelegate;
@class StationButton;
//选站 view
@interface StationView : UIView {
    id <StationViewDelegate> stationDelegate;
    StationButton *_stationBtn;
}

@property (nonatomic, assign) id <StationViewDelegate> stationDelegate;

- (void)setStationNo:(int)stationNo;
- (void)setStationNoBackgroundColor:(UIColor *)bgColor;
- (void)setStationName:(NSString *)strStationName;
- (void)setStartStatusWithFlag:(int)flag;
- (void)resetStatus;

@end

@protocol StationViewDelegate <NSObject>

@optional
- (void)stationBtnisClicked:(StationView *)stationPlanView;
- (void)btnSearchisClicked:(StationView *)stationView;
- (void)btnGpsisClicked:(StationView *)stationView;
- (void)btnFavoriteisClicked:(StationView *)stationView;

@end
