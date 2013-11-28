//
//  IndexViewController.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-26.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "BasicViewController.h"

@class ViewController;



@interface IndexViewController : BasicViewController{
    
    
    ViewController *_viewController;
    UIView *_clockView;
    
    UIView *_clock;
    
    UIView *clockImage;
    
    UIView *_addClockView;
    
    
}

@property (nonatomic, retain) ViewController *viewController;

@end
