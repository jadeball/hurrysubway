//
//  PlanListCell.m
//  hurrysubway
//
//  Created by WangYuqiu on 13-9-16.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "PlanListCell.h"
#import "PlistUtils.h"

@interface PlanListCell ()


@property (nonatomic, retain) NSDictionary *dictPlan;

@end

@implementation PlanListCell
@synthesize dictPlan = _dictPlan;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dictPlan = nil;
        _imgvPlanNo = [[UIImageView alloc] initWithFrame:CGRectMake(20, 16, 27, 48)];
        [self addSubview:_imgvPlanNo];
        localdic=[[NSDictionary alloc] init];
        localdic=[[PlistUtils sharedPlistData] getviewdictionary:@"Planlistcell"];
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

+ (CGFloat)getHeightOfPlanListCellWith:(int)transferCount {
    int count = 0;
    if ((transferCount%3)==0) {
        count = transferCount/3;
    }else {
        count = (transferCount/3)+1;
    }
    if (count > 0) {
        return 16*(count-1)+80;
    }else {
        return 80;
    }
}

- (void)setPlan:(NSDictionary *)dict {
    if (![dict isEqual:self.dictPlan]) {
        [[self viewWithTag:300] removeFromSuperview];
        NSString *strLines = [dict objectForKey:@"lines"];
        NSArray *arrayLines = [strLines componentsSeparatedByString:@","];
        int count = 0;
        int transferCount = [arrayLines count];
        
        for(int i=0;i<transferCount;i++)
        {
            NSLog(@"[arrayLines objectAtIndex:i] %@",[arrayLines objectAtIndex:i]);
        }
        
        
        
        
        CGRect rectPlanNo = _imgvPlanNo.frame;
        CGFloat fHeight = [PlanListCell getHeightOfPlanListCellWith:transferCount];
        rectPlanNo.origin.y = (fHeight-40)*0.5;
        _imgvPlanNo.frame = rectPlanNo;
        
        CGRect rectFrame = self.frame;
        rectFrame.size.height = fHeight;
        self.frame = rectFrame;
        
        if ((transferCount%3)==0) {
            count = transferCount/3;
        }else {
            count = (transferCount/3)+1;
        }
        UIView *vTransferLines = [[UIView alloc] initWithFrame:CGRectMake(86, 10, 211, count*16)];
        vTransferLines.tag = 300;
        CGFloat fx = 0;
        CGFloat fy = count*16+10;
        //transfer lines
        for (int i = 0; i < transferCount; i++) {
            int line = i/3;
            if (i != 0) {
                fx = fx + 6;
                UILabel *lblChange;
                if (i%3 == 0) {
                    lblChange = [[UILabel alloc] initWithFrame:CGRectMake(fx, (line-1)*16+3, 16, 10)];
                }else {
                    lblChange = [[UILabel alloc] initWithFrame:CGRectMake(fx, line*16+3, 16, 10)];
                }
                
                lblChange.backgroundColor = [UIColor clearColor];
                lblChange.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:8];
                lblChange.textColor = [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0];
                lblChange.text =[localdic objectForKey:@"tranfer"];
                [vTransferLines addSubview:lblChange];
                [lblChange release];
                fx = fx + 16 + 6;
                if (i%3 == 0) {
                    fx = 0;
                }
                
            }
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(fx, line*16, 0, 16)];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = [UIColor blackColor];
            lbl.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14];
            lbl.text = [NSString stringWithFormat:@"%@ %@",[arrayLines objectAtIndex:i],[[PlistUtils sharedPlistData] getviewstring:@"line"]];
            [lbl sizeToFit];
            fx = fx + lbl.frame.size.width;
            [vTransferLines addSubview:lbl];
            [lbl release];
            
        }
        [self addSubview:vTransferLines];
        
        
        //add icon and content
        for (int i = 0; i < 5; i++) {
            UIImageView *imgvIcon = nil;
            UILabel *lblContent = nil;
            NSString *strContent = nil;
            lblContent.lineBreakMode = UILineBreakModeWordWrap;
            lblContent.numberOfLines = 0;
            
            switch (i) {
                case 0:
                    imgvIcon = [[UIImageView alloc] initWithFrame:CGRectMake(-20, 0, 14, 14)];
                    break;
                case 1:
                    fy = fy + 6;
                    imgvIcon = [[UIImageView alloc] initWithFrame:CGRectMake(-20, fy-10, 14, 14)];
                    lblContent = [[UILabel alloc] init];
                    //                    if ([currentLanguages isEqualToString:@"en"]) {
                    //                        [lblContent setFrame:CGRectMake(1, fy-15, 120, 35)];
                    //                        lblContent.lineBreakMode = UILineBreakModeWordWrap;
                    //                        lblContent.numberOfLines = 2;
                    //                        strContent = [NSString stringWithFormat:@"Is expected to \n drive for %@ hours", [dict objectForKey:@"time"]];
                    //                    }
                    //                    else{
                    NSArray *ary1=[[localdic objectForKey:@"string1"] componentsSeparatedByString:@","];
                    [lblContent setFrame:CGRectMake(1, fy-11, 120, 20)];
                    strContent = [NSString stringWithFormat:@"%@%@%@", [ary1 objectAtIndex:0],[dict objectForKey:@"time"],[ary1 objectAtIndex:1]];
                    //}
                    break;
                case 2:
                    imgvIcon = [[UIImageView alloc] initWithFrame:CGRectMake(119, fy-10, 14, 14)];
                    lblContent = [[UILabel alloc] initWithFrame:CGRectMake(140, fy-11, 75, 20)];
                    //                    if ([currentLanguages isEqualToString:@"en"]) {
                    //                        strContent = [NSString stringWithFormat:@"Fares %@ yuan", [dict objectForKey:@"fee"]];
                    //
                    //                    }
                    //                    else{
                    NSArray *ary2=[[localdic objectForKey:@"string2"] componentsSeparatedByString:@","];
                    strContent = [NSString stringWithFormat:@"%@%@%@",[ary2 objectAtIndex:0], [dict objectForKey:@"fee"],[ary2 objectAtIndex:1]];
                    
                    //}
                    break;
                case 3:
                    fy = fy + 20;
                    imgvIcon = [[UIImageView alloc] initWithFrame:CGRectMake(-20, fy-10, 14, 14)];
                    lblContent = [[UILabel alloc] init];
                    //                    if ([currentLanguages isEqualToString:@"en"]) {
                    //                        [lblContent setFrame:CGRectMake(1, fy-15, 120, 35)];
                    //                        lblContent.lineBreakMode = UILineBreakModeWordWrap;
                    //                        lblContent.numberOfLines = 2;
                    //                        strContent = [NSString stringWithFormat:@"By way of a total\n of %@ stations", [dict objectForKey:@"stat_count"]];
                    //                    }
                    //                    else{
                    NSArray *ary3=[[localdic objectForKey:@"string3"] componentsSeparatedByString:@","];
                    [lblContent setFrame:CGRectMake(1, fy-11, 120, 20)];
                    NSLog(@"%@",[dict objectForKey:@"stat_count"]);
                    strContent = [NSString stringWithFormat:@"%@%@%@",[ary3 objectAtIndex:0], [dict objectForKey:@"stat_count"],[ary3 objectAtIndex:1]];
                    
                    //}
                    break;
                case 4:
                    imgvIcon = [[UIImageView alloc] initWithFrame:CGRectMake(119, fy-10, 14, 14)];
                    lblContent = [[UILabel alloc] init];
                    //WithFrame:CGRectMake(140, fy-11, 85, 35)];
                    //                    if ([currentLanguages isEqualToString:@"en"]) {
                    //                        lblContent.lineBreakMode = UILineBreakModeWordWrap;
                    //                        lblContent.numberOfLines = 2;
                    //                        [lblContent setFrame:CGRectMake(140, fy-15, 85, 35)];
                    //                        strContent = [NSString stringWithFormat:@"Need to transfer \n%@ times", [dict objectForKey:@"transfer_count"]];
                    //                    }
                    //                    else{
                    NSArray *ary4=[[localdic objectForKey:@"string4"] componentsSeparatedByString:@","];
                    [lblContent setFrame:CGRectMake(140, fy-11, 85, 20)];
                    strContent = [NSString stringWithFormat:@"%@%@%@",[ary4 objectAtIndex:0], [dict objectForKey:@"transfer_count"],[ary4 objectAtIndex:1]];
                    // }
                    break;
                default:
                    break;
            }
            NSString *strName = [NSString stringWithFormat:@"planicon%d",i];
            NSString *strIconPath = [[NSBundle mainBundle] pathForResource:strName ofType:@"png"];
            imgvIcon.image = [UIImage imageWithContentsOfFile:strIconPath];
            [vTransferLines addSubview:imgvIcon];
            [imgvIcon release];
            
            if (lblContent) {
                lblContent.backgroundColor = [UIColor clearColor];
                //                if ([currentLanguages isEqualToString:@"en"]) {
                //                    lblContent.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:10];
                //                }
                //                else{
                lblContent.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
                //}
                lblContent.textColor = [UIColor blackColor];
                lblContent.text = strContent;
                [vTransferLines addSubview:lblContent];
                [lblContent release];
            } 
        }
        [vTransferLines release];
    } 
}

- (void)setPlanNo:(int)index {
    NSString *strName = [NSString stringWithFormat:@"planno%d",index+1];
    NSString *strPlanNoPath = [[NSBundle mainBundle] pathForResource:strName ofType:@"png"];
    _imgvPlanNo.image = [UIImage imageWithContentsOfFile:strPlanNoPath];
}

- (void)dealloc
{
    self.dictPlan = nil;
    [_imgvPlanNo release];
    [super dealloc];
}

@end
