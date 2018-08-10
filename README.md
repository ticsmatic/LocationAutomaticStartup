Moment调查结果 调查⽬目的
Moment是否可持续后台，耗电情况，是否能⾃自动启动，底层实现⽅方式。 应⽤用介绍
![图片](https://github.com/ChinaChailu/LocationAutomaticStartup/blob/master/11492766723_.pic_hd.jpg)


  功能:
  实现应⽤用⻓长时间驻留留后台。
  实现应⽤用在不不主动打开的情况下，⾃自动启动
  实现⽤用户⾏行行为检测(检测是否解锁和锁屏)
应⽤用主要特点
可实现不不开启应⽤用的情况下⾃自动启动 可持续在后台检测 特别省电，仅⽐比不不使⽤用此应⽤用每天增加 5%的⽤用电量量
       
 
 调查过程和结果 调查⽅方式
通过查询stackoverflow,Google,github,baidu
调查结果
实现⾃自动启动 关键API startMonitoringSignificantLocationChanges 在注册此接⼝口后，被⽤用户或系统强⾏行行退出后，系统依然可以⾃自动启动应⽤用，进⾏行行关键位置定位
编写测试Demo，测试此API,⽆无法持续后台 ，仅可被系统唤醒10秒钟
实现持续后台
通过查阅资料料，可通过注册两个 CLLication 对象 第⼀一个⽤用来控制 App⾃自动启动
第⼆二个⽤用来控制 App持续驻留留后台
APP持续驻留留实现⽅方式
1、每次进⼊入应⽤用后 通过 startMonitoringSignificantLocationChanges 注册服务。
2、注册过此服务后 系统会在 位置发⽣生变化后⾃自动唤醒应⽤用，(实测，退出应⽤用后在距离2公⾥里里的地⽅方应⽤用被⾃自动唤醒了了，⼿手机没电⾃自动关机后，充电完成后，也会⾃自动唤醒应⽤用) 3、当应⽤用唤醒后 只有10秒启动时间，这时候 创建新的 CLLocationManager 对象，利利⽤用startUpdatingLocatio 可将后台时间延⻓长到180秒 4、启动定时器器，当检测到后台剩余⼩小于30秒，在次调⽤用 startUpdatingLocatio 可在次 将后台时间延⻓长到 180秒 5、通过循环调⽤用startUpdatingLocatio，实现⽆无限制后台
代码
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//创建定位管理理者单例例
SignificantLocationManager *manager = [SignificantLocationManager shareManager]; manager.isUnStartBackgoundLocation = YES; //当launchOptions中有UIApplicationLaunchOptionsLocationKey表明是系统因为位置发⽣生重⼤大变化，⾃自动启动了了程序 if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
manager.isRunFromeSystem = YES;
[[BackgroundLocationManager shareManager] sendLocalNoification]; }
//开始重⼤大位置改变定位
[manager startMonitoringSignificantLocationChanges];
[self redirectDLogToDocumentFolder];
return YES; }
在 SignificantLocationManager的 didUpdateLocations 中 唤醒另⼀一个 BackgroundLocationManager
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
if (self.isUnStartBackgoundLocation) {
if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) { self.isUnStartBackgoundLocation = YES;
BackgroundLocationManager *mange = [BackgroundLocationManager shareManager];
[mange startChickBgTime]; }
} }
在另⼀一个的 BackgroundLocationManager 中 开始 检查剩余后台时间
- (void)startChickBgTime {
[self.bgTaskTimer invalidate];
self.bgTaskTimer = nil;
self.bgTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(bgTaskTimerAction) userInfo:nil repeats:YES
];
[[BGTask shareBGTask] beginNewBackgroundTask];
}
         当后台时间 ⼩小于30秒 申请定位

  - (void)bgTaskTimerAction {
NSTimeInterval backgroundTimeRemaining = [[UIApplication sharedApplication] backgroundTimeRemaining]; if (backgroundTimeRemaining == DBL_MAX){
NSLog(@"B=T=R = Undetermined"); } else {
NSLog(@"B=T=R = %.02f ", backgroundTimeRemaining);
if (backgroundTimeRemaining < 30 && self.isStartUpdatingLocation == NO) {
} }
}
NSLog(@"开始定位"); self.isStartUpdatingLocation = YES; [self startUpdatingLocation];
在定位成功后，在次申请后台时间 180秒
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
//这个是我封装的⽤用来获取后台时间的⼀一个单例例
[[BGTask shareBGTask] beginNewBackgroundTask]; [self stopUpdatingLocation]; self.isStartUpdatingLocation = NO;
}
优化后测试结果
利利⽤用此API可实现的功能
1、实现后台驻留留
2、实现⾃自动启动 3、实现⽤用户回家后，⾃自动开始睡眠监测
![图片](https://github.com/ChinaChailu/LocationAutomaticStartup/blob/master/IMG_2415.PNG)
尚未解决的问题
1、如果⽤用户主动退出后，⻓长时间没有移动，⼀一直驻留留在同⼀一个位置，⽆无法⾃自动启动 尚⽆无法解决 2、耗电，当前耗电量量 ⽆无法达到Moment 那样 ⼀一天的耗电量量仅为 5% 3、如果⽤用户开启⻜飞⾏行行模式，⽆无法实现后台驻留留，⾃自动启动
4、如果⽤用户关闭 定位权限 ⽆无法实现后台驻留留，⾃自动启动
问题1: 这个问题Moment也存在 如果⼀一直待在同⼀一个地⽅方是没办法⾃自动启动的
问题2: 耗电我尝试了了好⼏几种⽅方式，包括将定位范围放到最⼤大，和每次定位完成关闭定位，都⽆无法解决，⽬目前耗电量量 8% 问题3，问题4:⾃自动启动是关键，但是关闭应⽤用权限的情况下是没有办法⾃自动启动的，如果能⾃自动启动，可以换 静默⾳音持续后台
⽬目前耗电
  测试⽅方式
    是否⾃自动启动
    是否持续后台
   主动退出应⽤用
   是
   是
  关机后启动
  是
   是
          
 测试 19.2⼩小时 耗电量量 8% 调研资料料
https://wigl.github.io/2015/08/28/ios_location_introduction/
官⽅方 API介绍 https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/LocationAwarenessPG/RegionMonitoring/RegionMonitoring.html#//apple_ref/doc/uid/TP40009497- CH9
    
 
