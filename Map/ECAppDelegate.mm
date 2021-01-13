//
//  ECAppDelegate.m
//  Map
//
//  Created by Jame on 15/4/22.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import "ECAppDelegate.h"
#import <BaiduMapAPI/BMapKit.h>
#import "ECMapViewController.h"

@implementation ECAppDelegate
{
    BMKMapManager *_mapManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:@"QZnSBNOz3B5AiiLw5mcV0FYp" generalDelegate:nil];
    if (!ret) {
        NSLog(@"mapManager启动失败");
    }else{
        NSLog(@"mapManager启动成功");
    }
    ECMapViewController *mapViewController = [[ECMapViewController alloc] init];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    self.window.rootViewController = navc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
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
    [BMKMapView willBackGround];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [BMKMapView didForeGround];
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
