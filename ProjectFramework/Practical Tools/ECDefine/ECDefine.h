//
//  ECDefine.h
//  JuJuSports
//
//  Created by Jame on 15-3-31.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#ifndef JuJuSports_ECDefine_h
#define JuJuSports_ECDefine_h

#import "UIView+Frame.h"
#import "ECURLPath.h"
#import "ECHelper.h"
#import "ECCustom.h"

#define ECREMOVESUPERVIEW(x)    [x removeFromSuperview]; [x release]; x = nil
#define ECRELEASE(x)            [x release]; x = nil
#define ECRETAIN(x)             [x retain]

#define ECSCREENSIZE          [[UIScreen mainScreen] bounds]
#define ECSCREEN_W [[UIScreen mainScreen]bounds].size.width
#define ECSCREEN_H [[UIScreen mainScreen]bounds].size.height

// 系统控件默认高度
#define ECSTATUSBARHEIGHT       (20.0f)     //状态栏
#define ECTOPBARHEIGHT          (44.0f)     //顶部的高度
#define ECBOTTOMHEIGHT          (49.0f)     //底部的高度

#define ECNavcLeftImageFrame CGRectMake(15, 25, 30, 30)
#define ECNavcRightImageFrame CGRectMake(ECSCREEN_W - 38, 30, 23, 26)
#define ECNavcRightBtnTitleEdgeInsets UIEdgeInsetsMake(25, 52, 5, 0)

#define ECNavcLeftButtonFrame CGRectMake(0, 0, 50, 64)
#define ECNavcRightButtonFrame CGRectMake(ECSCREEN_W - 50,0,50, 64)

#define ECNavcLeftLabelFrame CGRectMake(0, 25, 60, 34)
#define ECNavcRightLabelFrame CGRectMake(ECSCREEN_W - 60, 25, 60, 34)

// 当前系统版本
#define ECSYSTEMVERSION         ([[[UIDevice currentDevice] systemVersion] doubleValue])

// 颜色(RGB)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ECRGBACOLOR(r, g, b, a)         [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define navc_Color                      UIColorFromRGB(0xce0039) //红色导航颜色

#define background_Color                 ECRGBACOLOR(255, 255, 255, 1.f)//灰色背景

#define base_Color                             ECRGBACOLOR(51, 154, 255, 1)//tabBar导航颜色

#define color_icon                      UIColorFromRGB(0xd95578) //彩色图标颜色
#define gray_icon                       UIColorFromRGB(0x333333) //墨色图标颜色
#define dark_character                  UIColorFromRGB(0x3e3e3e) //深色文字颜色
#define light_character                 UIColorFromRGB(0x646464) //浅色文字颜色

//设备判断

#define IS_IPHONE4  ([[UIScreen mainScreen] bounds].size.width == 320 &&  [[UIScreen mainScreen] bounds].size.height == 480)

#define IS_IPHONE5  ([[UIScreen mainScreen] bounds].size.width == 320 &&  [[UIScreen mainScreen] bounds].size.height == 568)

#define IS_IPHONE6  ([[UIScreen mainScreen] bounds].size.width == 375 &&  [[UIScreen mainScreen] bounds].size.height == 667)

#define IS_IPHONE6P  ([[UIScreen mainScreen] bounds].size.width == 414 &&  [[UIScreen mainScreen] bounds].size.height == 736)

//iOS系统判断
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define ECImageName(_name_) [UIImage imageNamed:_name_]

//项目附加

#define textColor_RGB [UIColor colorWithRed:1 green:0.53 blue:0.27 alpha:1]
#define textView_color [UIColor colorWithRed:0.49 green:0.49 blue:0.49 alpha:1]

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define SHOW_ALERT(_TITLE_,_MESSAGE_,_CANCELTEXT_,_OTHERTEXT_) UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:_TITLE_ message:_MESSAGE_ delegate:nil cancelButtonTitle:_CANCELTEXT_ otherButtonTitles:_OTHERTEXT_, nil];\
[alertView show];

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

#endif
