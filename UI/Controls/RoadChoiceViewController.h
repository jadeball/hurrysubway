//
//  RoadChoiceViewController.h
//  hurrysubway
//
//  Created by WangYuqiu on 13-9-15.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "BasicViewController.h"
#import "ViewController.h"
#import "AddClockViewController.h"

@interface RoadChoiceViewController : BasicViewController <UITableViewDataSource, UITableViewDelegate> {
    AddClockViewController *_addClockViewController;
    ViewController *_viewController;
    NSArray *_dataList;
    
    NSString *strIoStat;
    NSString *strOiStat;
    NSString *strIoStatName;
    NSString *strOiStatName;
    UILabel *_lblStart;
    UILabel *_lblEnd;
    int intType ; //0:交通卡　1:单程票
    NSArray *_arrayPlans;
    UITableView *_tableView;
    NSDictionary *localdic;
}

@property (nonatomic, retain) ViewController *viewController;
@property(nonatomic,retain) AddClockViewController *addClockViewController;

@property (nonatomic, retain) NSArray *dataList;


@property (nonatomic, retain) NSString *strIoStat, *strOiStat, *strIoStatName, *strOiStatName;
@property (nonatomic, assign) int intType;


@end
