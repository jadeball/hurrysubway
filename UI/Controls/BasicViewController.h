//
//  BasicViewController.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-26.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kOAuthConsumerKey @"2488797" //test data
#define kOAuthConsumerSecret @"9a9716106a7b205fc07083d9c28f0b3c" //test data
#define kTestUrl @"www.sina.com.cn"

@interface BasicViewController : UIViewController{
    
    UIView *_vTopBar;
	UIImageView *_imgvTopBarBg;
	UILabel *_lblTitle;
    UIImageView *imgvBg;
    BOOL _bHasRetBtn;
}

@property (nonatomic, retain) UIImageView *imgvBg;
@property (nonatomic, assign) BOOL hasRetBtn;

- (void)setTopBarBgImage:(UIImage *)img; //set background image for top bar
- (void)setTopTitle:(NSString *)strTitle; //set title for top bar
- (NSString *)getCurrentTime;
- (void)btnRetClick:(UIButton *)btn;

@end
