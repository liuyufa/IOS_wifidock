//
//  AppDelegate.m
//  WiFiDock
//
//  Created by apple on 14-12-1.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "Reachability+WF.h"
#import "MBProgressHUD+WF.h"
#import "WFNetCheckController.h"
#import "WFViewController.h"
#import "WFNewViewController.h"
#import "HTTPServer.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <netdb.h>
#import "WFNavigationController.h"
#import <AVFoundation/AVFoundation.h>
#import "IGLSMBProvier.h"

@interface AppDelegate ()<UIAlertViewDelegate>
@property(nonatomic, strong)HTTPServer *httpServer;
@property(nonatomic,assign)UIBackgroundTaskIdentifier bgTask;
@property(nonatomic,assign)UIBackgroundTaskIdentifier backgroundTask;
@property(nonatomic,strong)UILocalNotification *note;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSString *key = @"CFBundleVersion";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastVersion = [defaults stringForKey:key];
    
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[key];
    
    if ([currentVersion isEqualToString:lastVersion]) {
  
        WFViewController *root = [[WFViewController alloc] init];
        WFNavigationController *nav = [[WFNavigationController alloc] initWithRootViewController:root];
        nav.navigationBar.hidden = YES;
        self.window.rootViewController = nav;

    } else {
        
        WFNewViewController *root = [[WFNewViewController alloc] init];
        WFNavigationController *nav = [[WFNavigationController alloc] initWithRootViewController:root];
        
        self.window.rootViewController = nav;
        nav.navigationBar.hidden = YES;
        [defaults setObject:currentVersion forKey:key];
        [defaults synchronize];
    }
    
    [self.window makeKeyAndVisible];
    
//    [self pushMsg];
    
    NSString *webPath =[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents/Temp"];

    NSFileManager *fileManager=[NSFileManager defaultManager];
    [fileManager removeItemAtPath:webPath error:nil];

    Reachability *reachability = [Reachability reachabilityWithHostName:kSmbIp];
   
    [Reachability startCheckWithReachability:reachability];
    
    [self startServer];

    [self checkDockStatus];

    return YES;
}


- (void)startServer
{
    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setType:@"_http._tcp."];
    [self.httpServer setPort:LOCAL_HTTP_PORT];
    NSString *webPath =[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents/Temp"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:webPath])
    {
        [fileManager createDirectoryAtPath:webPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self.httpServer setDocumentRoot:webPath];
    NSError *error;
    if([self.httpServer start:&error]){
        NSLog(@"Started HTTP Server on port %hu", [self.httpServer listeningPort]);
    }else{
        
        NSLog(@"Error starting HTTP Server: %@", error);
    }
}

- (void)checkDockStatus
{
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
        if(![Reachability isReachableSamba]){
            
            [self performSelectorOnMainThread:@selector(setDisConnect) withObject:nil waitUntilDone:NO];
        }else{
            
            [self performSelectorOnMainThread:@selector(setConnectMsg) withObject:nil waitUntilDone:NO];
        }

//    });
}

- (void)setDisConnect
{

    NSString *msg = NSLocalizedString(@"Failed to connect wifi_dock. Maybe you need to check the wifi setting?",nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warming",nil) message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Done",nil), nil];
    
    [alert show];
}

- (void) setConnectMsg
{
    
    WFNetCheckController *check = [WFNetCheckController sharedNetCheck];
    if (check.dockPath || check.tfPath ||check.usbPath) return;
   
    NSString *msg = NSLocalizedString(@"Connect wifi_dock is successful. But did not find any storage device, you can only access local files.",nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warming",nil) message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Done",nil), nil];
    
    
    [alert show];

}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents]; // 让后台可以处理多媒体的事件
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil]; //后台播放
    
    if (!self.backgroundTask || self.backgroundTask == UIBackgroundTaskInvalid) {
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            // Synchronize the cleanup call on the main thread in case
            // the task actually finishes at around the same time.
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.backgroundTask != UIBackgroundTaskInvalid)
                {
                    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                    self.backgroundTask = UIBackgroundTaskInvalid;
                }
            });
        }];
    }
}
-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [application beginBackgroundTaskWithExpirationHandler:nil];
//    [application beginReceivingRemoteControlEvents];
 
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.backgroundTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }
    });
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [IGLSMBProvier clearSmbProvider];
    [[NSNotificationCenter defaultCenter] removeObserver:[WFNetCheckController sharedNetCheck]];
}

#pragma mark 推送通知

- (void)pushMsg
{
    float version = [[[UIDevice currentDevice]systemVersion]floatValue];
    if (version >= 8.0) {
        UIMutableUserNotificationAction *accept = [[UIMutableUserNotificationAction alloc] init];
        accept.identifier = @"accept";
        accept.title = @"Accept";
        accept.activationMode = UIUserNotificationActivationModeForeground;
        
        UIMutableUserNotificationAction *reject = [[UIMutableUserNotificationAction alloc] init];
        reject.identifier = @"reject";
        reject.title=@"Reject";
        reject.activationMode = UIUserNotificationActivationModeBackground;
        accept.authenticationRequired = YES;
        accept.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"alert";
        [categorys setActions:@[accept,reject] forContext:(UIUserNotificationActionContextMinimal)];
        
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:[NSSet setWithObjects:categorys, nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    }
 
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:20];
    notification.timeZone=[NSTimeZone defaultTimeZone];
    notification.repeatInterval = 3*kCFCalendarUnitDay;
    notification.alertBody=NSLocalizedString(@"Wonderfull,Closely associated",nil);
    if (version >= 8.0){
        notification.category = @"alert";
    }
    notification.alertLaunchImage = @"Default";
    
    self.note = notification;
    [[UIApplication sharedApplication]  scheduleLocalNotification:notification];
    
}
@end
