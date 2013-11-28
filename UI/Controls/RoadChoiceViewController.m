//
//  RoadChoiceViewController.m
//  hurrysubway
//
//  Created by WangYuqiu on 13-9-15.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "RoadChoiceViewController.h"
#import "PlistUtils.h"
#import "Database.h"
#import "MyLoadingView.h"
#import "PlanListCell.h"

@interface RoadChoiceViewController ()
@property (nonatomic, retain) NSArray *arrayPlans;

@end

@implementation RoadChoiceViewController

@synthesize viewController = _viewController;
@synthesize addClockViewController = _addClockViewController;
@synthesize dataList = _dataList;

@synthesize strIoStat, strOiStat, strIoStatName, strOiStatName;
@synthesize intType;
@synthesize arrayPlans = _arrayPlans;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    self.intType = 0;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //NSString *str=@"乘车方案";
    
    //帮助按钮
    self.intType = 0;
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"index"];
    NSArray *helpArray=[[localdic objectForKey:@"btn-help"] componentsSeparatedByString:@","];
    UIButton *btnHelp = [[UIButton alloc] initWithFrame:CGRectMake(280, 7, 32, 32)];
    NSString *strBtnHelpPath = [[NSBundle mainBundle] pathForResource:[helpArray objectAtIndex:0] ofType:@"png"];
    [btnHelp setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnHelpPath] forState:UIControlStateNormal];
    NSString *strBtnHelpHighlightedPath = [[NSBundle mainBundle] pathForResource:[helpArray objectAtIndex:1] ofType:@"png"];
    [btnHelp setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnHelpHighlightedPath] forState:UIControlStateHighlighted];
    [btnHelp addTarget:self action:@selector(btnHelpClick:) forControlEvents:UIControlEventTouchUpInside];
    [_vTopBar addSubview:btnHelp];
    [btnHelp release];
    
    
//    UIImageView *backgroundView = [self.view viewWithTag:999];
//    backgroundView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background" ofType:@"png"]];
    
    
    
    NSString *str=@"乘车方案";
    [super viewDidLoad];
    //PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    localdic=[[[PlistUtils sharedPlistData] getthisdictionary:str] retain];
    NSString *Toptitle=[localdic objectForKey:@"Toptitle"];
    [self setTopTitle:Toptitle];
    UIImageView *imgvBar = [[UIImageView alloc] initWithFrame:CGRectMake(6, 44, 310, 50)];
    NSString *strImgvBarPath = [[NSBundle mainBundle] pathForResource:@"road_choice" ofType:@"jpg"];
    imgvBar.image = [UIImage imageWithContentsOfFile:strImgvBarPath];
    [self.view addSubview:imgvBar];
    
    _lblStart = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 152, 34)];
    _lblStart.backgroundColor = [UIColor clearColor];
    _lblStart.textColor = [UIColor whiteColor];
    _lblStart.shadowOffset = CGSizeMake(1, 1);
    _lblStart.shadowColor = [UIColor grayColor];
    _lblStart.textAlignment = UITextAlignmentCenter;
    _lblStart.text = self.strIoStatName;

    _lblEnd = [[UILabel alloc] initWithFrame:CGRectMake(164, 8, 152, 34)];
    _lblEnd.backgroundColor = [UIColor clearColor];
    _lblEnd.textColor = [UIColor whiteColor];
    _lblEnd.shadowOffset = CGSizeMake(1, 1);
    _lblEnd.shadowColor = [UIColor grayColor];
    _lblEnd.textAlignment = UITextAlignmentCenter;
    _lblStart.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
    _lblEnd.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
    _lblEnd.text = self.strOiStatName;
    [imgvBar addSubview:_lblStart];
    [imgvBar addSubview:_lblEnd];
    
    [imgvBar release];
    
    //去掉卡类型
    
//    UIImageView *imgvTypeBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 78, 320, 23)];
//    
//    NSString *strTypeBarName = [NSString stringWithFormat:@"%@%d",[localdic objectForKey:@"TayBarname"],intType];
//    //NSString *strTypeBarName = [NSString stringWithFormat:@"planlisttypebar%d",intType];
//    NSString *strTypeBarPath = [[NSBundle mainBundle] pathForResource:strTypeBarName ofType:@"png"];
//    imgvTypeBar.image = [UIImage imageWithContentsOfFile:strTypeBarPath];
//    [self.view addSubview:imgvTypeBar];
    
    //    UILabel *lblType = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 23)];
    //    lblType.backgroundColor = [UIColor clearColor];
    //    lblType.textColor = [UIColor colorWithRed:165/255.0f green:165/255.0f blue:165/255.0f alpha:1.0];
    //    lblType.shadowOffset = CGSizeMake(0, 1);
    //    lblType.shadowColor = [UIColor whiteColor];
    //    lblType.textAlignment = UITextAlignmentCenter;
    //    lblType.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    //    if (intType == 0) {
    //        lblType.text = @"持交通卡方案";
    //    }else {
    //        lblType.text = @"持单程票方案";
    //    }
    //    [imgvTypeBar addSubview:lblType];
    //    [lblType release];
    
//    [imgvTypeBar release];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 94, 320, 400)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    MyLoadingView *loading = [[MyLoadingView alloc] initWithFrame:CGRectMake(0, 44, 320, 367) andFlag:NO];
    loading.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    loading.backgroundColor = [UIColor whiteColor];
    loading.tag = 300;
    [self.view addSubview:loading];
    [loading release];
    
    [self performSelector:@selector(loadPlanList) withObject:nil afterDelay:0.1];
    
    
}

- (void)loadPlanList {
    Database *database = [Database sharedDatabase];
    self.arrayPlans = [database getPlanListWithStart:self.strIoStat end:self.strOiStat andType:self.intType];
    NSLog(@"get plan list end");
    [_tableView reloadData];
    
    [[self.view viewWithTag:300] setHidden:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITableView delegate and datasource method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayPlans count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    NSString *Notice=[localdic objectForKey:@"plannotice"];
    
        NSDictionary *dictPlan = [self.arrayPlans objectAtIndex:row];
        static NSString *tableViewPlanListIdentifier = @"tableViewPlanList";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: tableViewPlanListIdentifier];
        PlanListCell *plan;
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:tableViewPlanListIdentifier] autorelease];
            plan = [[PlanListCell alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
            plan.backgroundColor = [UIColor clearColor];
            plan.tag = 500;
            [cell.contentView addSubview:plan];
            [plan release];
        }else {
            plan = (PlanListCell *)[cell.contentView viewWithTag:500];
        }
        [plan setPlan:dictPlan];
        [plan setPlanNo:row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;

        NSDictionary *dictPlan = [self.arrayPlans objectAtIndex:row];
        NSString *strLines = [dictPlan objectForKey:@"lines"];
        NSArray *arrayLines = [strLines componentsSeparatedByString:@","];
        CGFloat fHeight = [PlanListCell getHeightOfPlanListCellWith:[arrayLines count]];
        return fHeight;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    if (row < [self.arrayPlans count]) {
//        PlanDetailController *planDetail = [[PlanDetailController alloc] init];
//        planDetail.hasRetBtn = YES;
//        planDetail.bFavoriteShow = NO;
//        planDetail.strIoStat = strIoStat;
//        planDetail.strOiStat = strOiStat;
//        planDetail.strIoStatName = strIoStatName;
//        planDetail.strOiStatName = strOiStatName;
//        planDetail.dictPlan = [self.arrayPlans objectAtIndex:row];
//        planDetail.intType = intType;
//        [self.navigationController pushViewController:planDetail animated:YES];
//        [planDetail release];
        [self.navigationController popViewControllerAnimated:NO];
        //[self.navigationController popToViewController:self.addClockViewController animated:YES];
        //[self.navigationController pushViewController:self.addClockViewController animated:YES];
    }
}

- (void)dealloc
{
    self.strIoStat = nil;
    self.strOiStat = nil;
    self.strIoStatName = nil;
    self.strOiStatName = nil;
    self.arrayPlans = nil;
    [_lblStart release];
    [_lblEnd release];
    [_tableView release];
    [localdic release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
