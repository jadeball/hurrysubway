//
//  MyLoadingView.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-26.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import <UIKit/UIKit.h>



//加载等待页面
@interface MyLoadingView : UIView {
    UIActivityIndicatorView *_activityIndicator;
}

- (id)initWithFrame:(CGRect)frame andFlag:(BOOL)isWhite;

@end
