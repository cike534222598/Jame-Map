//
//  ECBaseViewController.m
//  JuJuSports
//
//  Created by Jame on 15/4/17.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import "ECBaseViewController.h"

@interface ECBaseViewController () <UITextFieldDelegate>

@end

@implementation ECBaseViewController

#pragma mark - 加载视图
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 自定义navigationBar&有搜索框
- (void)creatNavigationBarWithImage:(UIImage *)image
{
    //背景
    self.navigationController.navigationBarHidden =YES;
    // self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    _navcImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ECSCREEN_W, 64)];
    _navcImageView.backgroundColor = base_Color;
    _navcImageView.image = image;
    _navcImageView.userInteractionEnabled = YES;
    [self.view addSubview:_navcImageView];
    
    //   自定义搜索框
    _searchTextField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(ECNavcLeftButtonFrame)+3, 25, ECSCREENSIZE.size.width-2*CGRectGetWidth(ECNavcLeftLabelFrame)-6, 30)];
    _searchTextField.layer.cornerRadius = 5;
    _searchTextField.layer.borderColor = ECRGBACOLOR(67, 67, 67, 1).CGColor;
    _searchTextField.layer.borderWidth = 1.2;
    _searchTextField.text = @"  附近搜索";
    _searchTextField.delegate = self;
    _searchTextField.textColor = ECRGBACOLOR(67, 67, 67, 1);
    _searchTextField.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:13.f];
    _searchTextField.clearsOnBeginEditing = YES;
    [_navcImageView addSubview:_searchTextField];
    
    //搜索按钮
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchButton addTarget:self action:@selector(searchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _searchButton.frame = CGRectMake(CGRectGetWidth(_searchTextField.frame)-22, 6, 20, 20);
    [_searchButton setBackgroundImage:[UIImage imageNamed:@"default_common_searchbtn_image_normal.png"] forState:UIControlStateNormal];
    [_searchTextField addSubview:_searchButton];
    self.view.backgroundColor = background_Color;
}

#pragma mark - 搜索按钮触发事件
- (void)searchBtnClick:(id)sender
{
    NSLog(@"searchBtnClick");
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_searchTextField resignFirstResponder];
    return YES;
}

#pragma mark - 自定义navigationBar&无搜索框
- (void)creatNavigationBarWithImage:(UIImage *)image title:(NSString *)title
{
    //背景
    self.navigationController.navigationBarHidden =YES;
    _navcImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ECSCREEN_W, 64)];
    _navcImageView.backgroundColor =  base_Color;
    _navcImageView.image = image;
    _navcImageView.userInteractionEnabled = YES;
    [self.view addSubview:_navcImageView];
    
    //   标题
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((ECSCREEN_W - 180)/2.0f, 20, 180, 40)];
    _titleLabel.text = title;
    //[_titleLabel setFont:[UIFont systemFontOfSize:15]];
    _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16];
    _titleLabel.textColor = ECRGBACOLOR(67, 67, 67, 1);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_navcImageView addSubview:_titleLabel];
    self.view.backgroundColor = background_Color;
}

#pragma mark - 创建左navigationBarItem
- (void)creatNavigationBarLeftItemWithLeftTitle:(NSString *)leftTitle LeftImage:(UIImage *)leftImage
{
    //    leftLabel
    _leftLabel = [[UILabel alloc]init];
    _leftLabel.frame = ECNavcLeftLabelFrame;
    _leftLabel.text = leftTitle;
    _leftLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:13.f];
    _leftLabel.textAlignment = NSTextAlignmentCenter;
    _leftLabel.textColor = ECRGBACOLOR(67, 67, 67, 1);
    [_navcImageView addSubview:_leftLabel];
    
    //    leftImageView
    _leftImageView = [[UIImageView alloc]init];
    self.leftImageView.image = leftImage;
    self.leftImageView.frame = ECNavcLeftImageFrame;
    [_navcImageView addSubview:_leftImageView];
    
    //    左按钮
    UIButton *leftButton = [[UIButton alloc]init];
    [leftButton addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = ECNavcLeftButtonFrame;
    [_navcImageView addSubview:leftButton];
}

#pragma mark - 左按钮触发事件
- (void)leftBtnClick:(id)sender
{
    NSLog(@"leftButtonClick");
}

#pragma mark - 创建右navigationBarItem
- (void)creatNavigationBarRightItemWithRightTitle:(NSString *)rightTitle RightImage:(UIImage *)rightImage
{
    //    rightLabel
    _rightLabel = [[UILabel alloc]init];
    _rightLabel.frame = ECNavcRightLabelFrame;
    _rightLabel.text = rightTitle;
    _rightLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:13.f];
    _rightLabel.textAlignment = NSTextAlignmentCenter;
    _rightLabel.textColor = ECRGBACOLOR(67, 67, 67, 1);
    [_navcImageView addSubview:_rightLabel];
    
    //    rightImage
    _rightImageView = [[UIImageView alloc]init];
    _rightImageView.image = rightImage;
    self.rightImageView.frame = ECNavcRightImageFrame;
    [_navcImageView addSubview:_rightImageView];

    //    右按钮
    _rightButton = [[UIButton alloc]init];
    [_rightButton addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _rightButton.frame = ECNavcRightButtonFrame;
    [_navcImageView addSubview:_rightButton];
}

#pragma mark - 右按钮触发事件
- (void)rightBtnClick:(id)sender
{
    NSLog(@"rightButtonClick");
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
