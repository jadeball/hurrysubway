//
//  HelpViewController.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-6-25.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "HelpViewController.h"
#import "PlistUtils.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

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
    self.hasRetBtn = YES;
    [super viewDidLoad];
    NSString *str=@"帮助";
    helpdic=[[PlistUtils sharedPlistData] getthisdictionary:str];
    [self setTopTitle:[helpdic objectForKey:@"Toptitle"]];
    
    
    NSString *bgimag=[helpdic objectForKey:@"backgroundimage"];
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, 367)];
    scroll.contentSize = CGSizeMake(320, 480);
    [self.view addSubview:scroll];
    UIImageView *imgvHelp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    NSString *strImgHelpPath = [[NSBundle mainBundle] pathForResource:bgimag ofType:@"png"];
    imgvHelp.image = [UIImage imageWithContentsOfFile:strImgHelpPath];
    [scroll addSubview:imgvHelp];
    [imgvHelp release];
    
    [scroll release];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
