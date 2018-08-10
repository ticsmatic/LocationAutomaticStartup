//
//  AppDelegate.m
//  Location
//
//  Created by cardvalue on 16/4/14.
//  Copyright © 2016年 jinpeng. All rights reserved.
//

#import "AppDelegate.h"
#import "SignificantLocationVC.h"
#import "SignificantLocationManager.h"
#import "BakcgoundLocationVC.h"
#import "BackgroundLocationManager.h"
#import "HasBlankedVC.h"
#import "ACPReminder.h"

@interface AppDelegate ()<CLLocationManagerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.statusBarHidden = YES;
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    UITabBarController *tab = [[UITabBarController alloc]init];
    tab.tabBar.translucent = NO;
    SignificantLocationVC *slvc = [[SignificantLocationVC alloc]init];
    slvc.title = @"重大位置改变定位";
    BakcgoundLocationVC *blvc = [[BakcgoundLocationVC alloc]init];
    blvc.title = @"后台持续定位";
    HasBlankedVC * hvc = [[HasBlankedVC alloc]init];
    hvc.title = @"使用手机时长";
    tab.viewControllers = @[slvc,blvc,hvc];
    _window.rootViewController = tab;
    [_window makeKeyAndVisible];
    
    //创建定位管理者单例
    SignificantLocationManager *manager = [SignificantLocationManager shareManager];
    manager.isUnStartBackgoundLocation = YES;
    //当launchOptions中有UIApplicationLaunchOptionsLocationKey表明是系统因为位置发生重大变化，自动启动了程序
    if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        manager.isRunFromeSystem = YES;
        [[BackgroundLocationManager shareManager] sendLocalNoification];
    }
    //开始重大位置改变定位
    [manager startMonitoringSignificantLocationChanges];
    
    
     [self redirectDLogToDocumentFolder];
    if ([[UIApplication sharedApplication]currentUserNotificationSettings].types!=UIUserNotificationTypeNone) {
    }else{
        [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
    }
    return YES;
}
- (void)redirectDLogToDocumentFolder
{
    //如果已经连接Xcode调试则不输出到文件
    if(isatty(STDOUT_FILENO)) {
        return;
    }
    
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){ //在模拟器不保存到文件中
        return;
    }
    
    //获取Document目录下的Log文件夹，若没有则新建
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"SnailSleepDebug"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.txt",dateStr];
    
    // freopen 重定向输出输出流，将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[BackgroundLocationManager shareManager] startChickBgTime];
   

}

@end
