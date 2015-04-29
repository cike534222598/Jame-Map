//
//  ECBaseViewController.h
//  JuJuSports
//
//  Created by Jame on 15/4/17.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECBaseViewController : UIViewController

@property (nonatomic,strong) UIImageView *navcImageView;   //导航条背景
@property (nonatomic,strong) UITextField *searchTextField;     //自定义搜索框
@property (nonatomic,strong) UIButton *searchButton;               //搜索按钮
@property (nonatomic,strong) UILabel *titleLabel;                       //导航条标题
@property (nonatomic,strong) UIButton *leftButton;                  //左按钮
@property (nonatomic,strong) UIButton *rightButton;                 //右按钮
@property (nonatomic,strong) UIImageView *leftImageView;        //左按钮图片
@property (nonatomic,strong) UIImageView *rightImageView;          //右按钮图片

@property (nonatomic,strong) UILabel *leftLabel;                            //左按钮标题
@property (nonatomic,strong) UILabel *rightLabel;                           //右按钮标题

- (void)creatNavigationBarWithImage:(UIImage *)image;     //创建有搜索框导航条

- (void)searchBtnClick:(id)sender;                                          //搜索按钮触发事件

- (void)creatNavigationBarWithImage:(UIImage *)image title:(NSString *)title;   //有标题无搜索框导航条

- (void)creatNavigationBarLeftItemWithLeftTitle:(NSString *)leftTitle LeftImage:(UIImage *)leftImage;                          //左按钮

- (void)leftBtnClick:(id)leftSender;     //左按钮触发事件

- (void)creatNavigationBarRightItemWithRightTitle:(NSString *)rightTitle RightImage:(UIImage *)rightImage;                  //右按钮

- (void)rightBtnClick:(id)rightSender;     //右按钮触发事件

@end
