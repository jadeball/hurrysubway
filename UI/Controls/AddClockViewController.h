//
//  AddClockViewController.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-26.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "BasicViewController.h"
#import "ViewController.h"
#import "StationView.h"

@interface AddClockViewController : BasicViewController<UITextFieldDelegate,StationViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>{
    ViewController *_viewController;
    UIView *_vStation;
    UIScrollView *scroll;
    UIPickerView *_pickervStations;
    NSArray *_arrayLines;
    NSArray *_arrayCurrentLine;
    int _intClickedLineBtn;
    int _intLineStart;
    int _intLineEnd;
    int _intStationStart;
    int _intStationEnd;
    int _intSelectedRowInComponent0;
    
    int _updateLocationTime;
    
    NSString *name;
    NSString *done;
}

@property (nonatomic, retain) ViewController *viewController;

@end
