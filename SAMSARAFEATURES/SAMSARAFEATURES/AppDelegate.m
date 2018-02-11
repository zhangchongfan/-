//
//  AppDelegate.m
//  SAMSARAFEATURES
//
//  Created by 张冲 on 2017/9/14.
//  Copyright © 2017年 samsara. All rights reserved.
//

#import "AppDelegate.h"
#import "SARootViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TPBGTask.h"
@interface AppDelegate ()<CLLocationManagerDelegate>{
    NSTimer *backGroundTimer;
    NSTimer *backStopTimer;
    CLLocationManager *_locationManager;
    CLLocation *newLocation;
    BOOL initTimer;
}
@property (nonatomic, strong) TPBGTask *bgTask;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [UINavigationBar appearance].barTintColor = AppColor;
    [self.window makeKeyAndVisible];
    SARootViewController *rootController = [[SARootViewController alloc]initWithNibName:@"SARootViewController" bundle:[NSBundle mainBundle]];
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:rootController];
    self.window.rootViewController = navigationController;
    
    self.bleManager = [VPBleCentralManage sharedBleManager];
    UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    [[UIApplication sharedApplication]registerUserNotificationSettings:settings];
    _bgTask = [TPBGTask shareBGTask];
    [self configureLocationManager];
    
    return YES;
}

+ (AppDelegate *)shareDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSString *localValue = [notification.userInfo objectForKey:@"DisconnectOpenBoxNoti"];
    if ([localValue isEqualToString:@"openBox"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DisconnectOpenBoxNoti" object:nil];
    }
}

- (void)getCurrentLocation:(void(^)(NSString *latitude, NSString *longitude))locationBlock {
    _locationBlock = locationBlock;
    [_locationManager startUpdatingLocation];
}

- (void)configureLocationManager {
    if (nil == _locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    if([CLLocationManager locationServicesEnabled]){
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
            _locationManager.allowsBackgroundLocationUpdates = YES;
        }
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            //[_locationManager requestWhenInUseAuthorization];
            [_locationManager requestAlwaysAuthorization];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (AppBleManager.isConnected) {
        [[NSNotificationCenter defaultCenter]postNotificationName:RSSINoti object:@(0)];//进入后台后先让丢失的报警保持一定开启
    }
    [self startLocation];
}

- (void)startLocation {
    initTimer = YES;
    [_bgTask beginNewBackgroundTask];
    [_locationManager startUpdatingLocation];
}

- (void)stopLocation {
    [_locationManager stopUpdatingLocation];
}

- (void)invalidateTimer {
    [backGroundTimer invalidate];
    backGroundTimer = nil;
    [backStopTimer invalidate];
    backStopTimer = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self invalidateTimer];
    if (_locationBlock == nil) {
        [self stopLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    newLocation = [locations objectAtIndex:0];
    NSLog(@"newLocation:%@",newLocation);
    NSString *latitude = [NSString stringWithFormat:@"%.8f",newLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%.8f",newLocation.coordinate.longitude];
    if (_locationBlock) {
        _locationBlock(latitude, longitude);
        _locationBlock = nil;
    }
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self stopLocation];
        return;
    }
    if (initTimer) {
        backGroundTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(startLocation) userInfo:nil repeats:NO];
        backStopTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopLocation) userInfo:nil repeats:NO];
    }
    initTimer = NO;
}

@end
