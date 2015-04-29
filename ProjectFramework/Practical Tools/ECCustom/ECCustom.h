//
//  ECCustom.h
//  ShanFaChe
//
//  Created by Jame on 15/4/7.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECCustom : NSObject

//自定义创建Label
+ (UILabel *)creatLabelWithFrame:(CGRect)frame
                            text:(NSString *)text ;

//自定义创建Button
+ (UIButton *)creatButtonWithFrame:(CGRect)frame
                            target:(id)target
                               sel:(SEL)sel
                               tag:(NSInteger)tag
                             image:(NSString *)name
                             title:(NSString *)title;

//自定义创建ImageView
+ (UIImageView *)creatImageViewWithFrame:(CGRect)frame
                               imageName:(NSString *)name;

//自定义创建TextField
+ (UITextField *)creatTextFieldWithFrame:(CGRect)frame
                             placeHolder:(NSString *)string
                                delegate:(id <UITextFieldDelegate>)delegate
                                     tag:(NSInteger)tag;


@end
