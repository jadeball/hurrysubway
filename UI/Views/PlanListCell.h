//
//  PlanListCell.h
//  hurrysubway
//
//  Created by WangYuqiu on 13-9-16.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

//点击  查询结果 进入的view
@interface PlanListCell : UIView {
    UIImageView *_imgvPlanNo;
    NSDictionary *_dictPlan;
    NSDictionary *localdic;
}

- (void)setPlan:(NSDictionary *)dict;
- (void)setPlanNo:(int)index;
+ (CGFloat)getHeightOfPlanListCellWith:(int)transferCount;

@end
