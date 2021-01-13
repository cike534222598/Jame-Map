//
//  ECMoreViewController.m
//  Map
//
//  Created by Jame on 15/4/22.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import "ECMoreViewController.h"
#import "ECFirstMoreViewController.h"
#import "ECSecondMoreViewController.h"
#import "ECThirdMoreViewController.h"
#import "ECFourthMoreViewController.h"
#import "ECFifthMoreViewController.h"

@interface ECMoreViewController ()

@end

@implementation ECMoreViewController

#pragma mark - 加载视图
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatNavigationBarWithImage:nil title:@"更多"];
    [self creatNavigationBarLeftItemWithLeftTitle:nil LeftImage:[UIImage imageNamed:@"default_generalsearch_searchresultprepage_image_normal.png"]];
    [self initView];
}

#pragma mark - 导航左按钮触发事件
- (void)leftBtnClick:(id)leftSender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 创建视图
- (void)initView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, ECSCREEN_W, ECSCREEN_H - 64)];
    view.backgroundColor = [UIColor whiteColor];
    
    NSArray *titleArr = @[@"主界面功能介绍",@"附近搜索功能介绍",@"路线查询功能介绍",@"路线导航功能介绍",@"实时路况功能介绍"];
    
    for (int i = 0; i < titleArr.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20, (ECSCREEN_H - 64)/7 *i+10, ECSCREEN_W - 40, 50);
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 10;
        button.tag = 500 + i;
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:15];
        button.backgroundColor = [UIColor orangeColor];
        button.alpha = .5f;
        [button addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
    
    [self.view addSubview:view];
}

#pragma mark - ButtonClick触发事件
- (void)BtnClick:(UIButton *)button
{
    switch (button.tag) {
        case 500:
        {
            ECFirstMoreViewController *firstViewController = [[ECFirstMoreViewController alloc] init];
            [self presentViewController:firstViewController animated:YES completion:nil];
        }
            break;
        case 501:
        {
            ECSecondMoreViewController *secondViewController = [[ECSecondMoreViewController alloc] init];
            [self presentViewController:secondViewController animated:YES completion:nil];
        }
            break;
        case 502:
        {
            ECThirdMoreViewController *thirdViewController = [[ECThirdMoreViewController alloc] init];
            [self presentViewController:thirdViewController animated:YES completion:nil];
        }
            break;
        case 503:
        {
            ECFourthMoreViewController *fourthViewController = [[ECFourthMoreViewController alloc] init];
            [self presentViewController:fourthViewController animated:YES completion:nil];
        }
            break;
        case 504:
        {
            ECFifthMoreViewController *fifthViewController = [[ECFifthMoreViewController alloc] init];
            [self presentViewController:fifthViewController animated:YES completion:nil];
        }
            break;

            
        default:
            break;
    }
}

#pragma mark - 接收内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
