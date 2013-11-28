//
//  IndexViewController.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-26.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "IndexViewController.h"
#import "MyLoadingView.h"
#import "PlistUtils.h"
#import "AddClockViewController.h"
#import "HelpViewController.h"

@interface IndexViewController ()




@end

@implementation IndexViewController

@synthesize viewController = _viewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    MyLoadingView *loading = [[MyLoadingView alloc] initWithFrame:CGRectMake(0, 45, 320, 386) andFlag:NO];
    loading.backgroundColor = [UIColor clearColor];
    loading.tag = 300;
    loading.hidden = YES;
    [self.view addSubview:loading];
    [loading release];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"index"];
    NSString *Toptitle=[localdic objectForKey:@"title"];
    [self setTopTitle:Toptitle];


    //set图按钮
    NSArray *Linemapary=[[localdic objectForKey:@"btn-set"] componentsSeparatedByString:@","];
    UIButton *btnLinemap = [[UIButton alloc] initWithFrame:CGRectMake(278, 7, 33, 31)];
    NSString *strBtnLinemapPath = [[NSBundle mainBundle] pathForResource:[Linemapary objectAtIndex:0] ofType:@"png"];
    [btnLinemap setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnLinemapPath] forState:UIControlStateNormal];
    NSString *strBtnLinemaHighlightedPath = [[NSBundle mainBundle] pathForResource:[Linemapary objectAtIndex:1] ofType:@"png"];
    [btnLinemap setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnLinemaHighlightedPath] forState:UIControlStateHighlighted];
    [btnLinemap addTarget:self action:@selector(btnSetClick:) forControlEvents:UIControlEventTouchUpInside];
    [_vTopBar addSubview:btnLinemap];
    [btnLinemap release];
    
    //帮助按钮
    NSArray *helpArray=[[localdic objectForKey:@"btn-help"] componentsSeparatedByString:@","];
    UIButton *btnHelp = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 33, 30)];
    NSString *strBtnHelpPath = [[NSBundle mainBundle] pathForResource:[helpArray objectAtIndex:0] ofType:@"png"];
    [btnHelp setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnHelpPath] forState:UIControlStateNormal];
    NSString *strBtnHelpHighlightedPath = [[NSBundle mainBundle] pathForResource:[helpArray objectAtIndex:1] ofType:@"png"];
    [btnHelp setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnHelpHighlightedPath] forState:UIControlStateHighlighted];
    [btnHelp addTarget:self action:@selector(btnHelpClick:) forControlEvents:UIControlEventTouchUpInside];
    [_vTopBar addSubview:btnHelp];
    [btnHelp release];
    
    //clock
    _clock = [[UIView alloc] initWithFrame:CGRectMake(10, 44, 305, 82)];
    _clock.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_clock];
    
    UIImageView *imgClock = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 305, 82)];
    
    NSString *clockBackground=[localdic objectForKey:@"clock-bg"];
    NSString *strClockPath = [[NSBundle mainBundle] pathForResource:clockBackground ofType:@"png"];
    NSLog (@"strClockPath is :%@", strClockPath);
    imgClock.image = [UIImage imageWithContentsOfFile:strClockPath];
    [_clock addSubview:imgClock];
    [imgClock release];
    
    //添加闹钟小图标
    
    clockImage = [[UIView alloc] initWithFrame:CGRectMake(48, 70, 30, 32)];
    clockImage.backgroundColor = [UIColor clearColor];
    [self.view addSubview:clockImage];
    UIImageView *clock = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 32)];
    NSString *clockImageName=[localdic objectForKey:@"clockImage"];

    
    NSString *strClockImagePath = [[NSBundle mainBundle] pathForResource:clockImageName ofType:@"png"];
    NSLog (@"strClockImagePath is :%@", strClockImagePath);
    clock.image = [UIImage imageWithContentsOfFile:strClockImagePath];
    [clockImage addSubview:clock];
    [clock release];

    
    UILabel *labelClock = [[UILabel alloc] initWithFrame:CGRectMake(88, 14, 140, 60)];
    labelClock.backgroundColor = [UIColor clearColor];
    labelClock.textColor = [UIColor grayColor];
    labelClock.shadowOffset = CGSizeMake(1, 1);
    labelClock.shadowColor = [UIColor grayColor];
    labelClock.textAlignment = UITextAlignmentCenter;
    labelClock.text = @"00:00";
    labelClock.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:48];
    
    [_clock addSubview:labelClock];
    [labelClock release];
    
    //初始背景view
    _clockView = [[UIView alloc] initWithFrame:CGRectMake(10, 120, 305, 272)];
    _clockView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_clockView];
    //背景图片
    UIImageView *imgvBgSearch = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 305, 272)];
    
    NSString *background=[localdic objectForKey:@"add-clock-bg"];
    NSString *strBgSearchPath = [[NSBundle mainBundle] pathForResource:background ofType:@"png"];
    imgvBgSearch.image = [UIImage imageWithContentsOfFile:strBgSearchPath];
    [_clockView addSubview:imgvBgSearch];
    [imgvBgSearch release];
    
    //添加闹钟clock
    
//    _addClockView = [[UIView alloc] initWithFrame:CGRectMake(40, 400, 100, 50)];
//    _addClockView.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:_addClockView];
    
//    UIImageView *imgAddClock = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    //帮助按钮
    NSArray *addClockArray=[[localdic objectForKey:@"btn-add-clock"] componentsSeparatedByString:@","];
    UIButton *btnAddClock = [[UIButton alloc] initWithFrame:CGRectMake(70, 405, 180, 35)];
    
    NSString *strBtnAddClockPath = [[NSBundle mainBundle] pathForResource:[addClockArray objectAtIndex:0] ofType:@"png"];
    [btnAddClock setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnAddClockPath] forState:UIControlStateNormal];
    
    NSString *strBtnAddClockHighlightedPath = [[NSBundle mainBundle] pathForResource:[addClockArray objectAtIndex:1] ofType:@"png"];
    [btnAddClock setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnAddClockHighlightedPath] forState:UIControlStateHighlighted];
    [btnAddClock addTarget:self action:@selector(btnAddClockClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnAddClock];
    [btnAddClock release];
    
//    NSString *addClockBackground=[localdic objectForKey:@"btn-add-clock"];
//    NSString *strAddClockPath = [[NSBundle mainBundle] pathForResource:addClockBackground ofType:@"png"];
//    imgAddClock.image = [UIImage imageWithContentsOfFile:strAddClockPath];
//    [_addClockView addSubview:imgAddClock];
//    [imgAddClock release];
    
    
    
}

-(void)btnSetClick:(UIButton *)btn{
    
    [self btnAddClockClick:btn];
    
}

-(void)btnAddClockClick:(UIButton *)btn{
    
    
    AddClockViewController *addClockVC = [[AddClockViewController alloc] init];
    addClockVC.hasRetBtn = YES;

    addClockVC.viewController = self.viewController;
    //netmapVc.intSearchType = [_segment getSelectedSegment];
    [self.navigationController pushViewController:addClockVC animated:YES];
    [addClockVC release];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)btnHelpClick:(UIButton *)btn {
    HelpViewController *helpVc = [[HelpViewController alloc] init];
    [self.navigationController pushViewController:helpVc animated:YES];
    [helpVc release];
}

- (void)dealloc
{

    [_clockView release];
    [clockImage release];
    [_clock release];
    [_addClockView release];
    self.viewController = nil;

    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
