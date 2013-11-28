//
//  RepeatViewController.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-6-26.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "BasicViewController.h"
#import "ViewController.h"

@interface RepeatViewController : BasicViewController <UITableViewDataSource,UITableViewDelegate>{
    ViewController *_viewController;
    NSArray *_dataList;
}

@property (nonatomic, retain) ViewController *viewController;

@property (nonatomic, retain) NSArray *dataList;
@property (nonatomic, retain) UITableView *myTableView;

@end
