//
//  AppDelegate.m
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-5-12.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import "AppDelegate.h"
#import "PlistUtils.h"
#import "ViewController.h"
#import "ZipArchive.h"
#import "ClockModel.h"

#define kDataBaseNamesmall @"subway.sqlite"


#define kStartTime 3.0f

@implementation AppDelegate

@synthesize switchVc = _switchVc;

@synthesize clockModel;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
     
    clockModel = [[ClockModel alloc] init];
    
    NSString *str=@"zh";
    [[PlistUtils sharedPlistData] init:str];
    
    
    _imgvLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"startpage" ofType:@"png"];
    _imgvLogo.image  = [UIImage imageWithContentsOfFile:strPath];
    [self.window addSubview:_imgvLogo];
    
    _indicatorv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorv.center = CGPointMake(160, 300);
    _indicatorv.hidesWhenStopped = YES;
    [_imgvLogo addSubview:_indicatorv];
    
    [self.window makeKeyAndVisible];
    
    _switchVc = [[ViewController alloc] init];
    [self.window addSubview:_switchVc.view];
    _switchVc.view.hidden = YES;
    
    [self showLogo];
    
    [self unZipDataBase];
    
    
    return YES;
}


- unZipDataBase{
    
    NSError *err = nil;
    
    NSArray *arrayPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *strDocPath = [[arrayPath objectAtIndex:0] stringByAppendingPathComponent:@"Caches"];
    NSString *strLvmmPath = [strDocPath stringByAppendingPathComponent:@"subway"];
    NSString *strSqlPath = [strLvmmPath stringByAppendingPathComponent:@"sql"];
    NSString *strDatabasePath = [strSqlPath stringByAppendingPathComponent:kDataBaseNamesmall];
    
    NSString *defaultZipFilePath=[[NSBundle mainBundle] pathForResource:@"subway.sqlite" ofType:@"zip"];
    
    ZipArchive *unzip = [[ZipArchive alloc] init];
    if ([unzip UnzipOpenFile:defaultZipFilePath]) {
        BOOL result = [unzip UnzipFileTo:strSqlPath overWrite:YES];
        if (result) {
            NSLog(@"解压数据库成功！");
        }
        else {
            NSLog(@"解压数据库失败");
        }
        [unzip UnzipCloseFile];
    }
    else {
        NSLog(@"打开数据库zip文件失败");
    }
    [unzip release];

}


- (void)showLogo {
    [_indicatorv startAnimating];
    [self performSelector:@selector(showStart) withObject:nil afterDelay:kStartTime];
}

- (void)showStart {
    

    
    _imgvLogo.hidden = YES;
    _imgvLogo.image = nil;
    _switchVc.view.hidden = NO;
    
    
    //    [self updateLocalDatabaseWithSettingInfo:dict];
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
