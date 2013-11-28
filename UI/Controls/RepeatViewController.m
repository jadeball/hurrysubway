//
//  RepeatViewController.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-6-26.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "RepeatViewController.h"
#import "PlistUtils.h"
#import "TouchLabel.h"
#import "AppDelegate.h"

@interface RepeatViewController ()

@end

@implementation RepeatViewController

@synthesize viewController = _viewController;
@synthesize dataList = _dataList;

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
    
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"repeat"];
//    NSString *bgimag=[localdic objectForKey:@"repeatMock"];
//    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, 480)];
//    scroll.contentSize = CGSizeMake(320, 480);
//    [self.view addSubview:scroll];
//    UIImageView *imgClockSet = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 310, 240)];
//    NSString *strImgHelpPath = [[NSBundle mainBundle] pathForResource:bgimag ofType:@"png"];
//    imgClockSet.image = [UIImage imageWithContentsOfFile:strImgHelpPath];
//    [scroll addSubview:imgClockSet];
//    [imgClockSet release];
    
    
    NSArray *list = [NSArray arrayWithObjects:[localdic objectForKey:@"Monday"],
                     [localdic objectForKey:@"Tuesday"]
                     ,[localdic objectForKey:@"Wednesday"]
                     ,[localdic objectForKey:@"Thursday"]
                     ,[localdic objectForKey:@"Friday"]
                     ,[localdic objectForKey:@"Saturday"]
                     ,[localdic objectForKey:@"Sunday"], nil];
    self.dataList = list;
    
    UITableView *tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 480) style:UITableViewStyleGrouped] autorelease];
    // 设置tableView的数据源
    tableView.dataSource = self;
    // 设置tableView的委托
    tableView.delegate = self;
    // 设置tableView的背景图

    tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index-bg"]];
    self.myTableView = tableView;
    [self.view addSubview:tableView];

    
//    TouchLabel *label1 = [[TouchLabel alloc]initWithFrame:CGRectMake(10.0, 8.0, 300.0, 33.0)];
//    label1.text = [localdic objectForKey:@"Monday"];
//    label1.backgroundColor = [UIColor clearColor];
//    label1.userInteractionEnabled = YES;
//    label1.tag=1;
//    [scroll addSubview:label1];
//    [label1 release];
//    
//    NSString *map=[localdic objectForKey:@"selectOk"];
//    UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(282.0, 18.0, 13.0, 12.0)];
//    NSString *imgMapPath = [[NSBundle mainBundle] pathForResource:map ofType:@"png"];
//    imgMap.image = [UIImage imageWithContentsOfFile:imgMapPath];
//    [scroll addSubview:imgMap];
//    
//    [imgMap release];
//    
//    TouchLabel *label2 = [[TouchLabel alloc]initWithFrame:CGRectMake(10.0, 42.0, 300.0, 33.0)];
//    label2.text = [localdic objectForKey:@"Tuesday"];
//    label2.backgroundColor = [UIColor clearColor];
//    label2.tag = 2;
//    label2.userInteractionEnabled = YES;
//    [scroll addSubview:label2];
//    [label2 release];
//    
//    NSString *map2=[localdic objectForKey:@"selectOk"];
//    UIImageView *imgMap2 = [[UIImageView alloc] initWithFrame:CGRectMake(282.0, 51.0, 13.0, 12.0)];
//    NSString *imgMapPath2 = [[NSBundle mainBundle] pathForResource:map ofType:@"png"];
//    imgMap2.image = [UIImage imageWithContentsOfFile:imgMapPath2];
//    [scroll addSubview:imgMap2];
//    [imgMap2 release];
//    
//    TouchLabel *label3 = [[TouchLabel alloc]initWithFrame:CGRectMake(10.0, 76.0, 300.0, 33.0)];
//    label3.text = [localdic objectForKey:@"Wednesday"];
//    label3.backgroundColor = [UIColor clearColor];
//    [scroll addSubview:label3];
//    label3.userInteractionEnabled = YES;
//    label3.tag=3;
//    [label3 release];
//    
//    NSString *map3=[localdic objectForKey:@"selectOk"];
//    UIImageView *imgMap3 = [[UIImageView alloc] initWithFrame:CGRectMake(282.0, 84.0, 13.0, 12.0)];
//    NSString *imgMapPath3 = [[NSBundle mainBundle] pathForResource:map ofType:@"png"];
//    imgMap3.image = [UIImage imageWithContentsOfFile:imgMapPath3];
//    [scroll addSubview:imgMap3];
//    [imgMap3 release];
//    
//    TouchLabel *label4 = [[TouchLabel alloc]initWithFrame:CGRectMake(10.0, 108.0, 300.0, 33.0)];
//    label4.text = [localdic objectForKey:@"Thursday"];
//    label4.backgroundColor = [UIColor clearColor];
//    label4.tag=4;
//    label4.userInteractionEnabled = YES;
//    [scroll addSubview:label4];
//    [label4 release];
//    
//    
//    TouchLabel *label5 = [[TouchLabel alloc]initWithFrame:CGRectMake(10.0, 140.0, 300.0, 33.0)];
//    label5.text = [localdic objectForKey:@"Friday"];
//    label5.backgroundColor = [UIColor clearColor];
//    label5.tag=5;
//    label5.userInteractionEnabled = YES;
//    [scroll addSubview:label5];
//    [label5 release];
//    
//    TouchLabel *label6 = [[TouchLabel alloc]initWithFrame:CGRectMake(10.0, 172.0, 300.0, 33.0)];
//    label6.text = [localdic objectForKey:@"Saturday"];
//    label6.userInteractionEnabled = YES;
//    label6.backgroundColor = [UIColor clearColor];
//    [scroll addSubview:label6];
//    label6.tag=6;
//    [label6 release];
//    
//    TouchLabel *label7 = [[TouchLabel alloc]initWithFrame:CGRectMake(10.0, 204.0, 300.0, 33.0)];
//    label7.text = [localdic objectForKey:@"Sunday"];
//    label7.backgroundColor = [UIColor clearColor];
//    label7.tag=7;
//    label7.userInteractionEnabled = YES;
//    [scroll addSubview:label7];
//    [label7 release];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
     NSLog(@"viewController touch");
    
    
    
    }


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identfier=@"placetable";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identfier];
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identfier];
    }
    NSInteger row = [indexPath row];
    cell.textLabel.text = [self.dataList objectAtIndex:row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"行选择" message:@"你已经选择一行！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    [messageAlert show];
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    //appDelegate.clockModel.repeatStr = @"0,1,2,3";
    
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"repeat"];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    
    UIView *imgOK = [cell viewWithTag:indexPath.row+1];
    if(imgOK == nil){
        //添加数据
        //appDelegate.clockModel.repeatStr ;
        //NSString *indexRowStr = [NSString initWithFormat:@"%d", indexPath.row+1];
        
        NSString *map=[localdic objectForKey:@"selectOk"];
        UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(282.0, 10.0, 13.0, 12.0)];
        NSString *imgMapPath = [[NSBundle mainBundle] pathForResource:map ofType:@"png"];
        imgMap.image = [UIImage imageWithContentsOfFile:imgMapPath];
        imgMap.tag = indexPath.row+1;
        [cell addSubview:imgMap];
        NSLog(@"####RowDidSelect:%d",indexPath.row+1);
//        NSString *indexrow = [NSString stringWithFormat:@"%d",indexPath.row+1];
//        NSLog(@"indexRow::%@",indexrow);
//        appDelegate.clockModel.repeatStr = [appDelegate.clockModel.repeatStr stringByAppendingString:indexrow];
        appDelegate.clockModel.repeatStr = [appDelegate.clockModel.repeatStr stringByAppendingFormat:@"%d",indexPath.row+1];
        NSLog(@"xxxxxx%@",appDelegate.clockModel.repeatStr);
       
        [imgMap release];
    }else{
        //删除数据
        [imgOK removeFromSuperview];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"repeat"];
    NSString *Toptitle=[localdic objectForKey:@"title"];
    [self setTopTitle:Toptitle];
    
    
    
}

- (void)btnRetClick:(UIButton *)btn {
    
    //设置AppDelegate.h 的值
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    //appDelegate.clockModel.repeatStr = @"0,1,2,3";
    
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"#####btnRetClick----onClick#####%@",appDelegate.clockModel.repeatStr);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
    
    self.viewController = nil;
    self.dataList = nil;
    self.myTableView = nil;
    
    [super dealloc];
}

@end
