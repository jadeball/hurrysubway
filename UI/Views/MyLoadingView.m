//
//  MyLoadingView.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-26.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "MyLoadingView.h"

@implementation MyLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.center = CGPointMake(frame.size.width*0.5, frame.size.height*0.5);
        [self addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andFlag:(BOOL)isWhite {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (isWhite) {
            _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        }else {
            _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _activityIndicator.center = CGPointMake(frame.size.width*0.5, frame.size.height*0.5);
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
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

- (void)dealloc
{
    [_activityIndicator release];
    [super dealloc];
}

@end
