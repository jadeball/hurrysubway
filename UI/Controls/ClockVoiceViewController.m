//
//  ClockVoiceViewController.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-6-30.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "ClockVoiceViewController.h"
#import "PlistUtils.h"

@interface ClockVoiceViewController ()

@end

@implementation ClockVoiceViewController


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
    NSDictionary *localdic=[plistUtils getthisdictionary:@"clockVoice"];
//    NSString *bgimag=[localdic objectForKey:@"repeatMock"];
//    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, 480)];
//    scroll.contentSize = CGSizeMake(320, 480);
//    [self.view addSubview:scroll];
//    UIImageView *imgClockSet = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 310, 240)];
//    NSString *strImgHelpPath = [[NSBundle mainBundle] pathForResource:bgimag ofType:@"png"];
//    imgClockSet.image = [UIImage imageWithContentsOfFile:strImgHelpPath];
//    [scroll addSubview:imgClockSet];
//    [imgClockSet release];
//    
//    
//    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(14.0, 8.0, 80.0, 30.0)];
//    label1.text = [localdic objectForKey:@"buguniao"];
//    label1.backgroundColor = [UIColor clearColor];
//    [scroll addSubview:label1];
//    [label1 release];
//
//    NSString *map=[localdic objectForKey:@"selectOk"];
//    UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(282.0, 18.0, 13.0, 12.0)];
//    NSString *imgMapPath = [[NSBundle mainBundle] pathForResource:map ofType:@"png"];
//    imgMap.image = [UIImage imageWithContentsOfFile:imgMapPath];
//    [scroll addSubview:imgMap];
//    [imgMap release];
//    
//    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(14.0, 42.0, 80.0, 30.0)];
//    label2.text = [localdic objectForKey:@"buguniao"];
//    label2.backgroundColor = [UIColor clearColor];
//    [scroll addSubview:label2];
//    [label2 release];
//    
//    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(14.0, 76.0, 80.0, 30.0)];
//    label3.text = [localdic objectForKey:@"buguniao"];
//    label3.backgroundColor = [UIColor clearColor];
//    [scroll addSubview:label3];
//    [label3 release];
//    
//    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(14.0, 108.0, 80.0, 30.0)];
//    label4.text = [localdic objectForKey:@"buguniao"];
//    label4.backgroundColor = [UIColor clearColor];
//    [scroll addSubview:label4];
//    [label4 release];
//    
//    
//    UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake(14.0, 140.0, 80.0, 30.0)];
//    label5.text = [localdic objectForKey:@"buguniao"];
//    label5.backgroundColor = [UIColor clearColor];
//    [scroll addSubview:label5];
//    [label5 release];
//    
//    UILabel *label6 = [[UILabel alloc]initWithFrame:CGRectMake(14.0, 172.0, 80.0, 30.0)];
//    label6.text = [localdic objectForKey:@"buguniao"];
//    label6.backgroundColor = [UIColor clearColor];
//    [scroll addSubview:label6];
//    [label6 release];
//    
//    UILabel *label7 = [[UILabel alloc]initWithFrame:CGRectMake(14.0, 204.0, 80.0, 30.0)];
//    label7.text = [localdic objectForKey:@"buguniao"];
//    label7.backgroundColor = [UIColor clearColor];
//    [scroll addSubview:label7];
//    [label7 release];
    
    
    NSArray *list = [NSArray arrayWithObjects:[localdic objectForKey:@"buguniao"],
                     [localdic objectForKey:@"buguniao"]
                     ,[localdic objectForKey:@"buguniao"]
                     ,[localdic objectForKey:@"buguniao"]
                     ,[localdic objectForKey:@"buguniao"]
                     ,[localdic objectForKey:@"buguniao"]
                     ,[localdic objectForKey:@"buguniao"], nil];
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
    
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"repeat"];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"###row::%dXXXX%d",indexPath.row,indexPath.section);
    UIView *imgOK = [cell viewWithTag:indexPath.row+1];
    if(imgOK == nil){
        
        //删除所有其他的 选择框
        for(NSInteger i=0;i<7;i++){
            NSIndexPath *indexPathTemp = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cellTemp = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPathTemp];
            UIView *imgOKTemp = [cellTemp viewWithTag:indexPathTemp.row+1];
            
            if(imgOKTemp != nil){
                [imgOKTemp removeFromSuperview];
            }
        }
        
        NSString *map=[localdic objectForKey:@"selectOk"];
        UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(282.0, 10.0, 13.0, 12.0)];
        NSString *imgMapPath = [[NSBundle mainBundle] pathForResource:map ofType:@"png"];
        imgMap.image = [UIImage imageWithContentsOfFile:imgMapPath];
        imgMap.tag = indexPath.row+1;
        [cell addSubview:imgMap];
        
        [imgMap release];
        
        
        
        
    }else{
        [imgOK removeFromSuperview];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"clockVoice"];
    NSString *Toptitle=[localdic objectForKey:@"title"];
    [self setTopTitle:Toptitle];
    
    
    
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
