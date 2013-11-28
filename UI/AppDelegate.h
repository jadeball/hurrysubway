//
//  AppDelegate.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-12.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockModel.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIImageView *_imgvLogo;
    
    ViewController *_switchVc;
    
    UIActivityIndicatorView *_indicatorv;
    
    ClockModel *clockModel;
    
}


@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) ViewController *switchVc;

@property(nonatomic,retain) ClockModel *clockModel;

@end
