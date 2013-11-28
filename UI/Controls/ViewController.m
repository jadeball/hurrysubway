//
//  ViewController.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-12.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "ViewController.h"
#import "IndexViewController.h"

#define kStart 100
#define degreesToRadian(x) (M_PI * (x) / 180.0f)

@interface ViewController ()

@end

@implementation ViewController
@synthesize arrayVCs = _arrayVCs;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIImageView *imgvBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
//    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"index-bg" ofType:@"jpg"];
//    imgvBg.image = [UIImage imageWithContentsOfFile:strPath];
//    [self.view addSubview:imgvBg];
//    self.view.hidden = FALSE;
//    [imgvBg release];
    
    
//    NSDictionary *switchdic=[[PlistData sharedPlistData] getthisdictionary:@"Switch"];
    UIImageView *imgvBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"index-bg" ofType:@"png"];
    imgvBg.image = [UIImage imageWithContentsOfFile:strPath];
    [self.view addSubview:imgvBg];
    [imgvBg release];
    //add five tab view controllers
    IndexViewController *indexViewController = [[IndexViewController alloc] init];
    indexViewController.viewController = self;
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:indexViewController];
    navController1.navigationBar.hidden = YES;
    navController1.view.frame = CGRectMake(0, 0, 320, 460);
    [self.view addSubview:navController1.view];
    [indexViewController release];
    
    _arrayVCs = [[NSArray alloc] initWithObjects:navController1,nil];
    [navController1 release];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc
{
    
    [_arrayVCs release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    for (UINavigationController *naVc in _arrayVCs) {
        [naVc viewWillAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    for (UINavigationController *naVc in _arrayVCs) {
        [naVc viewWillDisappear:animated];
    }
}



@end
