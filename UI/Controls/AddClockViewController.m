//
//  AddClockViewController.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-26.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "AddClockViewController.h"
#import "PlistUtils.h"
#import "RepeatViewController.h"
#import "ClockVoiceViewController.h"
#import "Database.h"
#import "LineLabel.h"
#import "AppDelegate.h"
#import "RoadChoiceViewController.h"

@interface AddClockViewController ()
@property (nonatomic, retain) NSArray *arrayLines;
@property (nonatomic, retain) NSArray *arrayCurrentLine;


- (LineLabel *)getLblForLineNo:(int)index;
- (UIColor *)getColorForLineNo:(int)index;





@end



@implementation AddClockViewController

@synthesize viewController = _viewController;
@synthesize arrayLines = _arrayLines;
@synthesize arrayCurrentLine = _arrayCurrentLine;

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
    _intClickedLineBtn = 0;
    _intLineStart = 0;
    _intLineEnd = 0;
    _intStationStart = 0;
    _intStationEnd = 0;
    _intSelectedRowInComponent0 = 0;
    
    
    //pickvoew view
    
    _updateLocationTime = 0;
    
    //展示UI界面
    
    
	// Do any additional setup after loading the view.
    
//        UIImageView *imgvBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
//        NSString *strPath = [[NSBundle mainBundle] pathForResource:@"addClockMock" ofType:@"jpeg"];
//        imgvBg.image = [UIImage imageWithContentsOfFile:strPath];
//        [self.view addSubview:imgvBg];
//        self.view.hidden = FALSE;
//        [imgvBg release];
    
}

- (int)getIndexInStations:(NSArray *)arrayStations WithStatId:(NSString *)strStatId {
    for (int i = 0; i < [arrayStations count]; i++) {
        if ([[[arrayStations objectAtIndex:i] objectForKey:@"stat_id"] isEqualToString:strStatId]) {
            return i;
        }
    }
    return -1;
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"addClockView did loading####%@",appDelegate.clockModel.repeatStr);
    
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"addClock"];
    NSString *Toptitle=[localdic objectForKey:@"title"];
    [self setTopTitle:Toptitle];
    name=[localdic objectForKey:@"name"];
    //set图按钮
    NSArray *Linemapary=[[localdic objectForKey:@"btn-save"] componentsSeparatedByString:@","];
    UIButton *btnLinemap = [[UIButton alloc] initWithFrame:CGRectMake(280, 7, 32, 32)];
    NSString *strBtnLinemapPath = [[NSBundle mainBundle] pathForResource:[Linemapary objectAtIndex:0] ofType:@"png"];
    [btnLinemap setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnLinemapPath] forState:UIControlStateNormal];
    NSString *strBtnLinemaHighlightedPath = [[NSBundle mainBundle] pathForResource:[Linemapary objectAtIndex:1] ofType:@"png"];
    [btnLinemap setBackgroundImage:[UIImage imageWithContentsOfFile:strBtnLinemaHighlightedPath] forState:UIControlStateHighlighted];
    [btnLinemap addTarget:self action:@selector(btnSaveClick:) forControlEvents:UIControlEventTouchUpInside];
    [_vTopBar addSubview:btnLinemap];
    [btnLinemap release];
    
    
    Database *database = [Database sharedDatabase];
    self.arrayLines = database.arrayLine;
    if ([self.arrayLines count] > 0) {
        self.arrayCurrentLine = [self.arrayLines objectAtIndex:0];
    }
    
    NSString *bgimag=[localdic objectForKey:@"addClockMock"];
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, 480)];
    scroll.contentSize = CGSizeMake(320, 480);
    [self.view addSubview:scroll];
    UIImageView *imgClockSet = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 310, 240)];
    NSString *strImgHelpPath = [[NSBundle mainBundle] pathForResource:bgimag ofType:@"png"];
    imgClockSet.image = [UIImage imageWithContentsOfFile:strImgHelpPath];
    [scroll addSubview:imgClockSet];
    [imgClockSet release];
    
    
    //车站
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(17.0, 14.0, 40.0, 30.0)];
    label1.text = [localdic objectForKey:@"chezhan"];
    label1.backgroundColor = [UIColor clearColor];
    
    
    //出发站
    StationView *vStationStart = [[StationView alloc] initWithFrame:CGRectMake(152, 7, 158, 39)];
    [vStationStart setStartStatusWithFlag:0];
    vStationStart.tag = 100;
    vStationStart.stationDelegate = self;
    [scroll addSubview:vStationStart];
    [vStationStart release];
    //终点站
    StationView *vStationEnd = [[StationView alloc] initWithFrame:CGRectMake(152, 44, 158, 39)];
    [vStationEnd setStartStatusWithFlag:1];
    vStationEnd.tag = 101;
    vStationEnd.stationDelegate = self;
    [scroll addSubview:vStationEnd];
    [vStationEnd release];
    
    StationView *clockTimeView = [[StationView alloc] initWithFrame:CGRectMake(152, 82, 158, 39)];
    [clockTimeView setStartStatusWithFlag:2];
    clockTimeView.tag = 102;
    clockTimeView.stationDelegate = self;
    [scroll addSubview:clockTimeView];
    [clockTimeView release];
    
    
    //起点
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(61.0, 14.0, 40.0, 30.0)];
    label2.text = [localdic objectForKey:@"qidian"];
    label2.backgroundColor = [UIColor clearColor];
    
    // map 图标
    NSString *map=[localdic objectForKey:@"map"];
    UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(104.0, 14.0, 30.0, 30.0)];
    NSString *imgMapPath = [[NSBundle mainBundle] pathForResource:map ofType:@"png"];
    imgMap.image = [UIImage imageWithContentsOfFile:imgMapPath];
    [scroll addSubview:imgMap];
    [imgMap release];
    
    //
    //    UITextField *textFieldQiDian = [[UITextField alloc] initWithFrame:CGRectMake(170.0, 18.0, 200.0, 30.0)];
    //    textFieldQiDian.placeholder = [localdic objectForKey:@"qidianChoose"];
    //    [textFieldQiDian setBorderStyle:UITextBorderStyleNone];
    
    
    //终点
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(61.0, 50.0, 40.0, 30.0)];
    label3.text = [localdic objectForKey:@"zhongdian"];
    label3.backgroundColor = [UIColor clearColor];
    
    //    UITextField *textFieldZhongDian = [[UITextField alloc] initWithFrame:CGRectMake(170.0, 54.0, 200.0, 30.0)];
    //    textFieldZhongDian.placeholder = [localdic objectForKey:@"zhongdianChoose"];
    //    [textFieldZhongDian setBorderStyle:UITextBorderStyleNone];
    
    //闹铃时间
    UILabel *labelClockTime = [[UILabel alloc]initWithFrame:CGRectMake(17.0, 88.0, 70.0, 30.0)];
    labelClockTime.text = [localdic objectForKey:@"clockTime"];
    labelClockTime.backgroundColor = [UIColor clearColor];
    
//    UITextField *textFieldClockTime = [[UITextField alloc] initWithFrame:CGRectMake(165.0, 95.0, 200.0, 30.0)];
//    textFieldClockTime.placeholder = [localdic objectForKey:@"clockTimeChoose"];
//    textFieldClockTime.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.1f];
//    [textFieldClockTime setBorderStyle:UITextBorderStyleNone];
//    textFieldClockTime.tag = 3;
//    textFieldClockTime.delegate = self;
    //闹铃选择
    //终点站
    
    
    
    //重复
    UILabel *labelRepeat = [[UILabel alloc]initWithFrame:CGRectMake(17.0, 128.0, 70.0, 30.0)];
    labelRepeat.text = [localdic objectForKey:@"repeat"];
    labelRepeat.backgroundColor = [UIColor clearColor];
    
    UITextField *textFieldRepeat = [[UITextField alloc] initWithFrame:CGRectMake(240.0, 136.0, 100.0, 30.0)];
    textFieldRepeat.placeholder = [localdic objectForKey:@"repeatChoose"];
    [textFieldRepeat setBorderStyle:UITextBorderStyleNone];
    textFieldRepeat.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.1f];
    textFieldRepeat.tag = 4;
    
    textFieldRepeat.delegate = self;
    
    //重复----selectLeft
    NSString *repeatSelectLeft=[localdic objectForKey:@"selectLeft"];
    UIImageView *repeatSelectLeftImg = [[UIImageView alloc] initWithFrame:CGRectMake(296.0, 138.0, 9.0, 12.0)];
    NSString *repeatSelectLeftPath = [[NSBundle mainBundle] pathForResource:repeatSelectLeft ofType:@"png"];
    repeatSelectLeftImg.image = [UIImage imageWithContentsOfFile:repeatSelectLeftPath];
    [scroll addSubview:repeatSelectLeftImg];
    [repeatSelectLeftImg release];
    
    
    //铃声
    UILabel *labelClockVoice = [[UILabel alloc]initWithFrame:CGRectMake(17.0, 166.0, 70.0, 30.0)];
    labelClockVoice.text = [localdic objectForKey:@"clockVoice"];
    labelClockVoice.backgroundColor = [UIColor clearColor];
    
    UITextField *textFieldClockVoice = [[UITextField alloc] initWithFrame:CGRectMake(240.0, 174.0, 100.0, 30.0)];
    textFieldClockVoice.placeholder = [localdic objectForKey:@"clockVoiceChoose"];
    [textFieldClockVoice setBorderStyle:UITextBorderStyleNone];
    textFieldClockVoice.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.1f];
    textFieldClockVoice.tag = 5;
    textFieldClockVoice.delegate = self;
    
    //铃声----selectLeft
    NSString *clockVoiceSelectLeft=[localdic objectForKey:@"selectLeft"];
    UIImageView *clockVoiceSelectLeftImg = [[UIImageView alloc] initWithFrame:CGRectMake(296.0, 176.0, 9.0, 12.0)];
    NSString *clockVoiceSelectLeftPath = [[NSBundle mainBundle] pathForResource:clockVoiceSelectLeft ofType:@"png"];
    clockVoiceSelectLeftImg.image = [UIImage imageWithContentsOfFile:clockVoiceSelectLeftPath];
    [scroll addSubview:clockVoiceSelectLeftImg];
    [clockVoiceSelectLeftImg release];
    
    
    
    //震动
    UILabel *labelVibrate = [[UILabel alloc]initWithFrame:CGRectMake(17.0, 202.0, 70.0, 30.0)];
    labelVibrate.text = [localdic objectForKey:@"vibrate"];
    labelVibrate.backgroundColor = [UIColor clearColor];
    
    
    
    UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(226.0, 206.0, 70.0, 30.0)];
    [switchButton setOn:YES];
    [switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [scroll addSubview:switchButton];
    [switchButton release];
    
    
    
    
    
    _vStation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    _vStation.backgroundColor = [UIColor clearColor];
    
    _pickervStations = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 460, 320, 216)];
    _pickervStations.delegate = self;
    _pickervStations.dataSource = self;
    _pickervStations.showsSelectionIndicator = YES;
    [_vStation addSubview:_pickervStations];
    
    UIView *vBtnBar = [[UIView alloc] initWithFrame:CGRectMake(0, 430, 320, 44)];
    vBtnBar.tag = 200;
    vBtnBar.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgvBtnBarBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    NSString *strPathLocationBtnBar = [[NSBundle mainBundle] pathForResource:@"locationbtnbar" ofType:@"png"];
    imgvBtnBarBg.image = [UIImage imageWithContentsOfFile:strPathLocationBtnBar];
    [vBtnBar addSubview:imgvBtnBarBg];
    [imgvBtnBarBg release];
    
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(12, 8, 66, 28)];
    [btnCancel setBackgroundImage:[UIImage imageNamed:@"btnblack.png"] forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12.0f];
    [btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    NSString *cancle=[localdic objectForKey:@"btncancle"];
    [btnCancel setTitle:cancle forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCancel.tag = 301;
    [vBtnBar addSubview:btnCancel];
    [btnCancel release];
    
    UIButton *btnOK = [[UIButton alloc] initWithFrame:CGRectMake((320-12-66), 8, 66, 28)];
    [btnOK setBackgroundImage:[UIImage imageNamed:@"btnred.png"] forState:UIControlStateNormal];
    btnOK.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12.0f];
    [btnOK setTag:2012];
    [btnOK addTarget:self action:@selector(btnOKClick) forControlEvents:UIControlEventTouchUpInside];
    [btnOK setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    done=[localdic objectForKey:@"btndone"];
    [btnOK setTitle:done forState:UIControlStateNormal];
    [vBtnBar addSubview:btnOK];
    [btnOK release];
    
    [_vStation addSubview:vBtnBar];
    [vBtnBar release];
    
    [self.view addSubview:_vStation];
    _vStation.hidden = YES;
    //----------------------------------------------------------------------------------------------------------------------------------

    if (database.bHasSetStart) {
        StationView *vLinePlanStart = (StationView*)[scroll viewWithTag:100];
        [vLinePlanStart resetStatus];
        if (database.intStartLineNo <= 0) {
            _intLineStart = 0;
            _intStationStart = 0;
        }else {
            _intLineStart = database.intStartLineNo-1;
            database.strStartName = [[self.arrayCurrentLine objectAtIndex:_intStationStart] objectForKey:name];
            _intStationStart = [self getIndexInStations:[self.arrayLines objectAtIndex:_intLineStart] WithStatId:database.strIoStat];
        }
        [vLinePlanStart setStationNo:database.intStartLineNo];
        [vLinePlanStart setStationNoBackgroundColor:[self getColorForLineNo:database.intStartLineNo]];
        [vLinePlanStart setStationName:database.strStartName];
        
    }
    
    if (database.bHasSetEnd) {
        StationView *vLinePlanEnd = (StationView*)[scroll viewWithTag:101];
        [vLinePlanEnd resetStatus];
        if (database.intEndLineNo <= 0) {
            _intLineEnd = 0;
            _intStationEnd = 0;
        }else {
            _intLineEnd = database.intEndLineNo-1;
            _intStationEnd = [self getIndexInStations:[self.arrayLines objectAtIndex:_intLineEnd] WithStatId:database.strOiStat];
            database.strEndName = [[self.arrayCurrentLine objectAtIndex:_intStationEnd] objectForKey:name];
        }
        [vLinePlanEnd setStationNo:database.intEndLineNo];
        [vLinePlanEnd setStationNoBackgroundColor:[self getColorForLineNo:database.intEndLineNo]];
        [vLinePlanEnd setStationName:database.strEndName];
        
    }
    
    
    
    [scroll addSubview:label1];
    [scroll addSubview:label2];
    [scroll addSubview:label3];
    [scroll addSubview:labelClockTime];
    [scroll addSubview:labelRepeat];
    [scroll addSubview:labelClockVoice];
    [scroll addSubview:labelVibrate];
    
    //    [scroll addSubview:textFieldQiDian];
    //    [scroll addSubview:textFieldZhongDian];
    //[scroll addSubview:textFieldClockTime];
    [scroll addSubview:textFieldRepeat];
    [scroll addSubview:textFieldClockVoice];
    
    
    
    [label1 release];
    [label2 release];
    [label3 release];
    [labelClockTime release];
    [labelRepeat release];
    [labelClockVoice release];
    [labelVibrate release];
    
    //    [textFieldQiDian release];
    //    [textFieldZhongDian release];
    //[textFieldClockTime release];
    [textFieldRepeat release];
    [textFieldClockVoice release];
    [scroll release];
    
    
    
    
    
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if(textField.tag == 4){
        RepeatViewController *repeatVC = [[RepeatViewController alloc] init];
        repeatVC.hasRetBtn = YES;
        
        repeatVC.viewController = self.viewController;
        NSLog(@"RepeatViewController loading");
        //netmapVc.intSearchType = [_segment getSelectedSegment];
        [self.navigationController pushViewController:repeatVC animated:YES];
        [repeatVC release];
    }else if(textField.tag == 5){
        
        ClockVoiceViewController *repeatVC = [[ClockVoiceViewController alloc] init];
        repeatVC.hasRetBtn = YES;
        
        repeatVC.viewController = self.viewController;
        NSLog(@"ClockVoiceViewController loading");
        //netmapVc.intSearchType = [_segment getSelectedSegment];
        [self.navigationController pushViewController:repeatVC animated:YES];
        [repeatVC release];
        
    }
    
    
    
    
    return NO;
}



- (LineLabel *)getLblForLineNo:(int)index {
    
    PlistUtils *plistUtils= [PlistUtils sharedPlistData];
    NSDictionary *localdic=[plistUtils getthisdictionary:@"addClock"];
    LineLabel *lbl = [[[LineLabel alloc] initWithFrame:CGRectMake(27, 11, 82, 25)] autorelease];
    lbl.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20.0f];
    NSString *line=[localdic objectForKey:@"line"];
    if (line.length>2) {
        lbl.text = [NSString stringWithFormat:@"%@ %d",line,(index+1)];
    }else{
        lbl.text = [NSString stringWithFormat:@"%d %@",(index+1),line];
    }
    
    [lbl setLineNo:(index+1) withFlag:YES];
    return lbl;
}

- (UIColor *)getColorForLineNo:(int)index {
    UIColor *color = nil;
    switch (index) {
        case 1:
            color = [UIColor redColor];
            break;
        case 2:
            color = [UIColor colorWithRed:119/255.0f green:204/255.0f blue:51/255.0f alpha:1.0];
            break;
        case 3:
            color = [UIColor colorWithRed:255/255.0f green:204/255.0f blue:0/255.0f alpha:1.0];
            break;
        case 4:
            color = [UIColor colorWithRed:102/255.0f green:51/255.0f blue:204/255.0f alpha:1.0];
            break;
        case 5:
            color = [UIColor colorWithRed:166/255.0f green:79/255.0f blue:255/255.0f alpha:1.0];
            break;
        case 6:
            color = [UIColor colorWithRed:255/255.0f green:0/255.0f blue:153/255.0f alpha:1.0];
            break;
        case 7:
            color = [UIColor colorWithRed:255/255.0f green:102/255.0f blue:0/255.0f alpha:1.0];
            break;
        case 8:
            color = [UIColor colorWithRed:51/255.0f green:153/255.0f blue:255/255.0f alpha:1.0];
            break;
        case 9:
            color = [UIColor colorWithRed:136/255.0f green:196/255.0f blue:255/255.0f alpha:1.0];
            break;
        case 10:
            color = [UIColor colorWithRed:204/255.0f green:153/255.0f blue:255/255.0f alpha:1.0];
            break;
        case 11:
            color = [UIColor colorWithRed:102/255.0f green:0/255.0f blue:0/255.0f alpha:1.0];
            break;
        default:
            color = [UIColor clearColor];
            break;
    }
    return color;
}


// 按下完成鈕後的 method
-(void) cancelPicker {
    // endEditing: 是結束編輯狀態的 method
    if ([self.view endEditing:NO]) {
        // 以下幾行是測試用 可以依照自己的需求增減屬性
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd" options:0 locale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        // 將選取後的日期 填入 UITextField
        
        //textField.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:datePicker.date]];
    }
}


-(void)btnSaveClick:(UIButton *)btn{
    
    NSLog(@"####btn-save-click click");
    
}

-(void)timeChanged:(UIButton *)btn{
    NSLog(@"###btn-timeChanged click");
}

-(void)switchAction:(UIButton *)btn{
    NSLog(@"####btn-switch-action click");
}

-(void)btnAddClockClick:(UIButton *)btn{
    
}

- (void)btnCancelClick {
//    [self showBtmBar];
    _intClickedLineBtn = 0;
    [UIView beginAnimations:@"hide" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.25];
    UIView *v = [_vStation viewWithTag:200];
    v.frame = CGRectMake(0, 430, 320, 44);
    _pickervStations.frame = CGRectMake(0, 474, 320, 216);
    [UIView commitAnimations];
}

- (void)btnOKClick {
//    [self showBtmBar];
    [UIView beginAnimations:@"hide" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.25];
    UIView *v = [_vStation viewWithTag:200];
    v.frame = CGRectMake(0, 430, 320, 44);
    _pickervStations.frame = CGRectMake(0, 474, 320, 216);
    Database *database = [Database sharedDatabase];
    [UIView commitAnimations];
    StationView *linePlanView = (StationView*)[scroll viewWithTag:_intClickedLineBtn];
    [linePlanView resetStatus];
    if (_intClickedLineBtn == 100) {
        _intLineStart = [_pickervStations selectedRowInComponent:0];
        _intStationStart = [_pickervStations selectedRowInComponent:1];
        self.arrayCurrentLine = [self.arrayLines objectAtIndex:_intLineStart];
        database.intStartLineNo = _intLineStart+1;
        database.strIoStat = [[self.arrayCurrentLine objectAtIndex:_intStationStart] objectForKey:@"stat_id"];
        database.strStartName = [[self.arrayCurrentLine objectAtIndex:_intStationStart] objectForKey:name];
        database.bHasSetStart = YES;
        
        [linePlanView setStationNo:database.intStartLineNo];
        [linePlanView setStationNoBackgroundColor:[self getColorForLineNo:database.intStartLineNo]];
        [linePlanView setStationName:database.strStartName];
    }else if(_intClickedLineBtn == 101){
        _intLineEnd = [_pickervStations selectedRowInComponent:0];
        _intStationEnd = [_pickervStations selectedRowInComponent:1];
        self.arrayCurrentLine = [self.arrayLines objectAtIndex:_intLineEnd];
        database.intEndLineNo = _intLineEnd+1;
        database.strOiStat = [[self.arrayCurrentLine objectAtIndex:_intStationEnd] objectForKey:@"stat_id"];
        database.strEndName = [[self.arrayCurrentLine objectAtIndex:_intStationEnd] objectForKey:name];
        database.bHasSetEnd = YES;
        
        [linePlanView setStationNo:database.intEndLineNo];
        [linePlanView setStationNoBackgroundColor:[self getColorForLineNo:database.intEndLineNo]];
        [linePlanView setStationName:database.strEndName];
        
        //弹出路线选择页面
        PlistUtils *plistUtils= [PlistUtils sharedPlistData];
        NSDictionary *localdic=[plistUtils getthisdictionary:@"addClock"];
        NSArray *alertary=[[localdic objectForKey:@"alerttitle"] componentsSeparatedByString:@","];
        if (database.bHasSetStart&&database.bHasSetEnd) {
            if (![database.strStartName isEqualToString:database.strEndName]) {
                
                
                
                
                
                RoadChoiceViewController *roadChoiceVC = [[RoadChoiceViewController alloc] init];
                roadChoiceVC.hasRetBtn = YES;
                roadChoiceVC.addClockViewController = self;
                roadChoiceVC.strIoStat = database.strIoStat;
                roadChoiceVC.strIoStatName = database.strStartName;
                roadChoiceVC.strOiStat = database.strOiStat;
                roadChoiceVC.strOiStatName = database.strEndName;
                roadChoiceVC.intType = 1;
                
                roadChoiceVC.viewController = self.viewController;
                NSLog(@"RepeatViewController loading");
                //netmapVc.intSearchType = [_segment getSelectedSegment];
                [self.navigationController pushViewController:roadChoiceVC animated:YES];
                [roadChoiceVC release];
                
                
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[alertary objectAtIndex:1] delegate:nil cancelButtonTitle:done otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
            }
            
        }else {
            NSString *strMessage = nil;
            if (!database.bHasSetStart) {
                strMessage =[alertary objectAtIndex:2];
            }else {
                strMessage =[alertary objectAtIndex:3];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:strMessage delegate:nil cancelButtonTitle:done otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            
        }
        
        
        
        
    }else if(_intClickedLineBtn == 102){  //设置闹钟选择时间
        _intLineEnd = [_pickervStations selectedRowInComponent:0];
        _intStationEnd = [_pickervStations selectedRowInComponent:1];
        if(_intStationEnd <10)
            [linePlanView setStationName:[NSString stringWithFormat:@"    %d:0%d",_intLineEnd,_intStationEnd]];
        else
            [linePlanView setStationName:[NSString stringWithFormat:@"    %d:%d",_intLineEnd,_intStationEnd]];
        
    }
    _intClickedLineBtn = 0;
}

- (void)showPickerView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    UIView *v = [_vStation viewWithTag:200];
    v.frame = CGRectMake(0, 220, 320, 44);
    _pickervStations.frame = CGRectMake(0, 264, 320, 216);
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    _vStation.hidden = YES;
}

#pragma mark StationView delegate

- (void)stationBtnisClicked:(StationView *)stationView {
    if ([_vStation isHidden]) {
        _intClickedLineBtn = stationView.tag;
        _vStation.hidden = NO;
//        [self hideBtmBar];
        
        if (_intClickedLineBtn == 100) {
            _pickervStations.tag = 100;
            [_pickervStations reloadAllComponents];
            _intSelectedRowInComponent0 = _intLineStart;
            self.arrayCurrentLine = [self.arrayLines objectAtIndex:_intSelectedRowInComponent0];
            [_pickervStations selectRow:_intLineStart inComponent:0 animated:NO];
            [_pickervStations selectRow:_intStationStart inComponent:1 animated:NO];
        }else if(_intClickedLineBtn == 101){
            _pickervStations.tag = 101;
            [_pickervStations reloadAllComponents];
            _intSelectedRowInComponent0 = _intLineEnd;
            self.arrayCurrentLine = [self.arrayLines objectAtIndex:_intSelectedRowInComponent0];
            [_pickervStations selectRow:_intLineEnd inComponent:0 animated:NO];
            [_pickervStations selectRow:_intStationEnd inComponent:1 animated:NO];
        }else if(_intClickedLineBtn == 102){   //展示时间选择框
            [_pickervStations reloadAllComponents];
            _pickervStations.tag = 102;
        }
        [self performSelector:@selector(showPickerView)];
    }
}

#pragma mark UIPickerView delegate and dataSource method

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag == 101 || pickerView.tag == 100){
        if (component == 0) {
            return [self.arrayLines count];
        }else {
            return [self.arrayCurrentLine count];
        }
    }else{
        if (component == 0){
            return 24;
        }else{
            return 60;
        }
    }
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *cell = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    
    if(pickerView.tag == 101 || pickerView.tag == 100){
        
        UILabel *lbl = nil;
        if (component == 0) {
            cell.frame = CGRectMake(0, 0, 120, 48);
            lbl = [[self getLblForLineNo:row] retain];
        }else if(component == 1){
            cell.frame = CGRectMake(0, 0, 200, 48);
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 185, 48)];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = [UIColor blackColor];
            lbl.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20.0f];
            //文本对齐方式         //居中对齐
            lbl.textAlignment = UITextAlignmentCenter;
            int index = [pickerView selectedRowInComponent:0];
            NSArray *array = [self.arrayLines objectAtIndex:index];
            NSString * laltext=[[array objectAtIndex:row] objectForKey:name];
            if (row < [array count]) {
                lbl.lineBreakMode = UILineBreakModeWordWrap;
                lbl.numberOfLines =0;
                if (laltext.length >12) {
                    lbl.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0f];
                    if (laltext.length>23) {
                        lbl.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14.0f];
                    }
                }
                lbl.text = laltext;
            }
        }
        [cell addSubview:lbl];
        [lbl release];
        
    }else{
        UILabel *lbl = nil;
        if(component == 0) {
            cell.frame = CGRectMake(0, 0, 120, 48);
            
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 48)];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = [UIColor blackColor];
            lbl.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20.0f];
            //文本对齐方式         //居中对齐
            lbl.textAlignment = UITextAlignmentCenter;
            
            lbl.text = [NSString stringWithFormat:@"%d",row];
            [cell addSubview:lbl];
            [lbl release];
        }else{
            cell.frame = CGRectMake(0, 0, 200, 48);
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 190, 48)];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = [UIColor blackColor];
            lbl.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20.0f];
            //文本对齐方式         //居中对齐
            lbl.textAlignment = UITextAlignmentCenter;
            
            if(row < 10){
               lbl.text = [NSString stringWithFormat:@"0%d",row];
            }else{
               lbl.text = [NSString stringWithFormat:@"%d",row]; 
            }
            
            [cell addSubview:lbl];
            [lbl release];
        }
    }
    
    return cell;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 48;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if(pickerView.tag == 101 || pickerView.tag == 100){
        if (_intSelectedRowInComponent0 != [pickerView selectedRowInComponent:0]) {
            _intSelectedRowInComponent0 = [pickerView selectedRowInComponent:0];
            self.arrayCurrentLine = [self.arrayLines objectAtIndex:_intSelectedRowInComponent0];
            [pickerView selectRow:0 inComponent:1 animated:NO];
            [pickerView reloadComponent:1];
        }
    }
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0) {
        return 135.0f;
    }else{
        return 185.0f;
    }
}




- (void)dealloc
{
    self.arrayLines = nil;
    self.arrayCurrentLine = nil;
    self.viewController = nil;
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
