//
//  HasBlankedVC.m
//  Location
//
//  Created by ChaiLu on 2017/4/20.
//  Copyright © 2017年 jinpeng. All rights reserved.
//

#import "HasBlankedVC.h"
//锁屏通知
#define NotificationOff CFSTR("com.apple.springboard.lockcomplete")

//解锁通知
#define NotificationOn CFSTR("com.apple.springboard.hasBlankedScreen")
@interface HasBlankedVC ()
@property (nonatomic, strong) NSArray *openArr;
@end

@implementation HasBlankedVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ListeningScreenLockState, NotificationOff, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ListeningScreenLockState, NotificationOn, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
static void ListeningScreenLockState(CFNotificationCenterRef center,void* observer,CFStringRef name,const void* object,CFDictionaryRef userInfo)

{
    
    NSString* screenState = (__bridge NSString*)name;
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString * str = [formatter stringFromDate:[NSDate date]];
    if ([screenState isEqualToString:(__bridge  NSString*)NotificationOff]) {
        
        NSLog(@"********锁屏**********");
        NSString * timeStr = [NSString stringWithFormat:@"锁屏%@",str] ;
        saveTimeStr(timeStr);
    } else if([screenState isEqualToString:(__bridge  NSString*)NotificationOn]) {
        NSString * timeStr = [NSString stringWithFormat:@"解屏%@",str] ;
        saveTimeStr(timeStr);
        NSLog(@"********解锁**********");
        
    }
    
}
void saveTimeStr( NSString  * timeStr) {
    //将位置数据不断写入沙盒
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    path = [NSString stringWithFormat:@"%@/HasBlankedScreen.plist",path];
    NSMutableArray *tempAr =[[NSArray arrayWithContentsOfFile:path] mutableCopy];
    if (!tempAr) {
        tempAr = [[NSMutableArray alloc]init];
    }
    NSDictionary *dic = @{@"Time":timeStr};
    [tempAr addObject:dic];
    //写入沙盒
    
    [tempAr writeToFile:path atomically:YES];
}



- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

-(void)refresh{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    path = [NSString stringWithFormat:@"%@/HasBlankedScreen.plist",path];
    self.openArr =[NSArray arrayWithContentsOfFile:path];
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.openArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifi = @"SignificantCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifi];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifi];
    }
    NSDictionary *dic = self.openArr[indexPath.row];
    cell.textLabel.text = dic[@"Time"];;
//    cell.detailTextLabel.text = dic[@"detailTextLabel"];
//    NSNumber *isLocationKey = dic[@"isRunFromeSystem"];
//    NSNumber *isBackground = dic[@"isBackground"];
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
