//
//  ECHelper.h
//  JuJuSports
//
//  Created by Jame on 15-3-31.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_Hashing)

- (NSString *)MD5Hash;

@end

@interface ECHelper : NSObject

//把一个秒字符串 转化为真正的本地时间
//@"1419055200" -> 转化 日期字符串
+ (NSString *)dateStringFromNumberTimer:(NSString *)timerStr;

//根据字符串内容的多少  在固定宽度 下计算出实际的行高
+ (CGFloat)textHeightFromTextString:(NSString *)text width:(CGFloat)textWidth fontSize:(CGFloat)size;

//获取 当前设备版本
+ (double)getCurrentIOS;

//获取当前设备屏幕的大小
+ (CGSize)getScreenSize;

//获得当前系统时间到指定时间的时间差字符串,传入目标时间字符串和格式
+(NSString*)stringNowToDate:(NSString*)toDate formater:(NSString*)formatStr;

//获取缓存文件 在 沙盒 Library/Caches 中的路径
+ (NSString *)getFullCacheFilePathWithUrl:(NSString *)url;

//判断 缓存文件 是否 超时  第二个参数 可以设置超时时间
+ (BOOL)isOutTimeOfFileWithUrl:(NSString *)url outTime:(NSTimeInterval) time;

@end
