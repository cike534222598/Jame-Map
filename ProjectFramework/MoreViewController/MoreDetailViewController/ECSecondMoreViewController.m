//
//  ECSecondMoreViewController.m
//  Map
//
//  Created by Jame on 15/4/29.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import "ECSecondMoreViewController.h"

@interface ECSecondMoreViewController ()

@end

@implementation ECSecondMoreViewController

#pragma mark - 视图加载
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatNavigationBarWithImage:nil title:@"附近搜索功能介绍"];
    [self creatNavigationBarLeftItemWithLeftTitle:nil LeftImage:[UIImage imageNamed:@"default_generalsearch_searchresultprepage_image_normal.png"]];
    [self initWebView];
}

#pragma mark - 左导航键触发事件
- (void)leftBtnClick:(id)leftSender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 初始化webView
- (void)initWebView
{
    NSURL *url = [NSURL URLWithString:@"http://group.testing.amap.com/jing.chu/userhelpV7/function3.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, ECSCREEN_W, ECSCREEN_H - 64)];
    [webView loadRequest:request];
    [self.view addSubview:webView];
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
