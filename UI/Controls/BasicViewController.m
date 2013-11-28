//
//  BasicViewController.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-26.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "BasicViewController.h"
#import "PlistUtils.h"

@interface BasicViewController ()

@end

@implementation BasicViewController
@synthesize hasRetBtn = _bHasRetBtn;

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
    //init
    
    imgvBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    NSString *strImgHelpPath = [[NSBundle mainBundle] pathForResource:@"index-bg" ofType:@"png"];
    imgvBg.image = [UIImage imageWithContentsOfFile:strImgHelpPath];
    imgvBg.tag = 999;
    [self.view addSubview:imgvBg];
    
    _vTopBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _vTopBar.backgroundColor = [UIColor blackColor];
    
    _imgvTopBarBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _imgvTopBarBg.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_vTopBar addSubview:_imgvTopBarBg];
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"barnav" ofType:@"png"];
    [self setTopBarBgImage:[UIImage imageWithContentsOfFile:strPath]];
    
    _lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _lblTitle.numberOfLines=0;
    _lblTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _lblTitle.backgroundColor = [UIColor clearColor];
    _lblTitle.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20.0];
    _lblTitle.textColor = [UIColor whiteColor];
    _lblTitle.textAlignment = UITextAlignmentCenter;
    _lblTitle.shadowOffset = CGSizeMake(0, -1);
    _lblTitle.shadowColor = [UIColor blackColor];
    [_vTopBar addSubview:_lblTitle];
    NSString *btnimage=[[PlistUtils sharedPlistData] getusensstring:@"basic"];
    NSArray *imageary=[btnimage componentsSeparatedByString:@","];
//    if (_bHasRetBtn) {
//        UIButton *btnRet = [[UIButton alloc] initWithFrame:CGRectMake(6, 6, 31, 31)];
//        NSString *strBtnRetPath = [[NSBundle mainBundle] pathForResource:[imageary objectAtIndex:0] ofType:@"png"];
//        [btnRet setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnRetPath] forState:UIControlStateNormal];
//        NSString *strBtnRetHighlightedPath = [[NSBundle mainBundle] pathForResource:[imageary objectAtIndex:1] ofType:@"png"];
//        [btnRet setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnRetHighlightedPath] forState:UIControlStateHighlighted];
//        [btnRet addTarget:self action:@selector(btnRetClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_vTopBar addSubview:btnRet];
//        [btnRet release];
//        
//    }
    [self.view addSubview:_vTopBar];
    
    
}




-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSString *btnimage=[[PlistUtils sharedPlistData] getusensstring:@"basic"];
    NSArray *imageary=[btnimage componentsSeparatedByString:@","];
    if (_bHasRetBtn) {
        UIButton *btnRet = [[UIButton alloc] initWithFrame:CGRectMake(6, 6, 32, 32)];
        NSString *strBtnRetPath = [[NSBundle mainBundle] pathForResource:[imageary objectAtIndex:0] ofType:@"png"];
        [btnRet setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnRetPath] forState:UIControlStateNormal];
        NSString *strBtnRetHighlightedPath = [[NSBundle mainBundle] pathForResource:[imageary objectAtIndex:1] ofType:@"png"];
        [btnRet setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnRetHighlightedPath] forState:UIControlStateHighlighted];
        [btnRet addTarget:self action:@selector(btnRetClick:) forControlEvents:UIControlEventTouchUpInside];
        [_vTopBar addSubview:btnRet];
        [btnRet release];
        
    }
    
}

- (void)btnRetClick:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setTopTitle:(NSString *)strTitle {
    _lblTitle.text = strTitle;
    
    if (strTitle.length >23) {
        _lblTitle.frame=CGRectMake(45, -6, 270, 49);
        _lblTitle.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0];
    }
    
}

- (void)setTopBarBgImage:(UIImage *)img {
    _imgvTopBarBg.image = img;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSString *)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *cnLocal = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formatter setLocale:cnLocal];
    [formatter setDateFormat:@"yyyy.MM.dd"];
	NSString *strDate = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    [cnLocal release];
    return strDate;
}


-(void)dealloc{
    
    [_vTopBar release];
    [_imgvTopBarBg release];
    [_lblTitle release];
    self.imgvBg = nil;
    [super dealloc];
    
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


@end
