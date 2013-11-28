//
//  TouchLabel.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-7-16.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "TouchLabel.h"

@implementation TouchLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
        NSLog(@"touchLabel touch!!!!!!");
    
        self.backgroundColor = [UIColor blueColor];
    UITouch *touch = [touches anyObject];
    NSLog(@"####%d####",self.tag);
    
    
    
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
      self.backgroundColor = [UIColor clearColor];

}

@end
