//
//  ECMapViewController.m
//  Map
//
//  Created by Jame on 15/4/22.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import "ECMapViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "DWBubbleMenuButton.h"
#import "ECNearViewController.h"
#import "ECPathViewController.h"
#import "ECNaviViewController.h"
#import "ECMoreViewController.h"

@interface ECMapViewController () <BMKMapViewDelegate,BMKLocationServiceDelegate,UIAlertViewDelegate>
{
    BMKMapView *_mapView;
    BMKLocationService *_locationService;
    BMKLocationViewDisplayParam *_param;
    UIView *_tabBar;
    BOOL _isMoveToLocationPoint;
}
@end

@implementation ECMapViewController

#pragma mark - 加载视图
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    _isMoveToLocationPoint = YES;
    [self initMapView];
    [self creatToolButton];
    [self creatCustomTabBar];
    [self creatLocationButton];
}

#pragma mark - 视图即将显示
- (void)viewWillAppear:(BOOL)animated
{
    [self startLocationService];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _locationService.delegate = self;
}

#pragma mark - 视图即将消失
- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _locationService.delegate = nil;
    [self stopLocationService];
}

#pragma mark - 初始化MapView
- (void)initMapView
{
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, ECSCREEN_W, ECSCREEN_H)];
    _mapView.showMapScaleBar = YES;
    _mapView.mapScaleBarPosition = CGPointMake((ECSCREEN_W+ 20)/4 *3, ECSCREEN_H/14 *13 - 45 );
    _mapView.showsUserLocation = YES;
     _mapView.zoomLevel = 15;
    
    //读取上次存储的地理位置
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    float latitude = [UD floatForKey:@"latitude"];
    float longitude = [UD floatForKey:@"longitude"];
    if (latitude == 0||longitude ==0) {
        NSLog(@"没有上次地理位置");
    }else{
        _mapView.centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        NSLog(@"读取上次地理位置");
    }
    
    [self.view addSubview:_mapView];
    NSLog(@"地图初始化完成");
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (_mapView.overlooking == 0) {
        if (_mapView.buildingsEnabled == YES) {
            _mapView.buildingsEnabled = NO;
            NSLog(@"退出3D建筑图");
        }
    }
    //地图界面变化存储一次定位地理信息
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    float latitude = _locationService.userLocation.location.coordinate.latitude;
    float longitude = _locationService.userLocation.location.coordinate.longitude;
    [UD setFloat:latitude forKey:@"latitude"];
    [UD setFloat:longitude forKey:@"longitude"];
    NSLog(@"地图变化，存储用户位置信息");
    [UD synchronize];
}

#pragma mark - 启动地图跳转到定位地点
- (void)moveToLocationPoint
{
    if (!_mapView.userLocationVisible) {
        [_mapView setCenterCoordinate:_locationService.userLocation.location.coordinate animated:YES];
    }
    NSLog(@"移动到定位地点");
}

#pragma mark - 初始化LocationService
- (void)startLocationService
{
    _locationService = [[BMKLocationService alloc] init];
    [_locationService startUserLocationService];
    NSLog(@"开启定位服务");
}

#pragma mark - 停止LocationService
- (void)stopLocationService
{
    //结束定位存储一次定位地理位置
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    float latitude = _locationService.userLocation.location.coordinate.latitude;
    float longitude = _locationService.userLocation.location.coordinate.longitude;
    [UD setFloat:latitude forKey:@"latitude"];
    [UD setFloat:longitude forKey:@"longitude"];
    NSLog(@"结束定位，存储用户位置信息");
    [UD synchronize];

    [_locationService stopUserLocationService];
    NSLog(@"结束定位服务");
}

#pragma mark - 用户位置更新后调用此函数
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    if (_isMoveToLocationPoint) {
        [self moveToLocationPoint];
        _isMoveToLocationPoint = NO;
    }
}

#pragma mark - 定位失败
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"定位服务启动失败");
    NSLog(@"%@",error);
    sleep(3);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"本次定位失败，请重新定位" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新定位", nil];
    [alertView show];
}

#pragma mark -启动定位失败弹窗
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@"重新开启定位服务");
        [self startLocationService];
    }
}

#pragma mark - 创建LocationButton
- (void)creatLocationButton
{//default_account_gender_radiobtn_normal   default_account_gender_radiobtn_highlighted
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(10, ECSCREEN_H/14 *13 - 45, 30, 30);
    [locationButton setBackgroundImage:[UIImage imageNamed:@"default_account_gender_radiobtn_normal.png"] forState:UIControlStateNormal];
    [locationButton setImage:[UIImage imageNamed:@"default_generalsearch_category_you_highlighted.png"] forState:UIControlStateNormal];
    [locationButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [locationButton addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    locationButton.layer.masksToBounds = YES;
    locationButton.layer.cornerRadius = locationButton.frame.size.height/2;
    locationButton.backgroundColor = ECRGBACOLOR(10, 10, 10, .5f);
    [self.view addSubview:locationButton];
}

#pragma mark - LocationButton触发事件
- (void)locationBtnClick:(UIButton *)locationButton
{
    _isMoveToLocationPoint = YES;
    if (_mapView.userTrackingMode == BMKUserTrackingModeNone) {
        _mapView.showsUserLocation = NO;
        _mapView.userTrackingMode = BMKUserTrackingModeFollow;
        _mapView.showsUserLocation = YES;
    }else{
        _mapView.showsUserLocation = NO;
        _mapView.userTrackingMode = BMKUserTrackingModeNone;
        _mapView.showsUserLocation = YES;
    }
    if (_mapView.buildingsEnabled) {
        _mapView.buildingsEnabled = NO;
        NSLog(@"退出3D建筑图");
    }
}

#pragma mark - 创建ToolButton
- (void)creatToolButton
{
    UIImageView *imageView = [self creatToolButtonView];
    DWBubbleMenuButton *downButtonMenu = [[DWBubbleMenuButton alloc] initWithFrame:CGRectMake(ECSCREEN_W - 50, ECSCREEN_H/14, imageView.frame.size.width, imageView.frame.size.height) expansionDirection:DirectionDown];
    downButtonMenu.homeButtonView = imageView;
    
    downButtonMenu.layer.cornerRadius = downButtonMenu.frame.size.height / 2.f;
    downButtonMenu.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
    downButtonMenu.clipsToBounds = YES;

    [downButtonMenu addButtons:[self creatToolButtonArray]];
    [self.view addSubview:downButtonMenu];
}

#pragma mark - 创建ToolButton视图
- (UIImageView *)creatToolButtonView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 30.f, 30.f)];
    //imageView.backgroundColor = [UIColor redColor];
    imageView.image = [UIImage imageNamed:@"default_generalsearch_category_zhu_highlighted.png"];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    titleLabel.text = @"工具";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:10];
    [imageView addSubview:titleLabel];
    return imageView;
}

#pragma mark - 创建ToolButtonArr
- (NSArray *)creatToolButtonArray
{
    NSMutableArray *buttonsArr = [[NSMutableArray alloc] init];
    NSArray *imageArr = @[@"default_generalsearch_category_wan_highlighted.png",@"default_generalsearch_category_gou_highlighted.png",@"default_generalsearch_category_re_normal.png",@"default_generalsearch_category_re_highlighted.png",@"default_generalsearch_category_chi_highlighted.png"];
    NSArray *titleArr = @[@"普通",@"卫星",@"交通",@"热力",@"3D"];
        int i =0;
    for (NSString *imageStr in imageArr) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i==2) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:10];
        [button setBackgroundImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
        button.frame = CGRectMake(0.f, 0.f, 30.f, 30.f);
        button.layer.cornerRadius = button.frame.size.height / 2.f;
        button.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
        button.clipsToBounds = YES;
        button.tag = i++;
        [button addTarget:self action:@selector(toolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsArr addObject:button];
    }
    return [buttonsArr copy];
}

#pragma mark - ToolButton点击触发事件
- (void)toolBtnClick:(UIButton *)toolButton
{
    switch (toolButton.tag) {
        case 0:
        {
            NSLog(@"普通地图");
            _mapView.mapType = BMKMapTypeStandard;
        }
            break;
        case 1:
        {
            NSLog(@"卫星地图");
            _mapView.mapType = BMKMapTypeSatellite;
        }
            break;

        case 2:
        {
            NSLog(@"开启交通图");
            if (_mapView.trafficEnabled == NO) {
                _mapView.trafficEnabled = YES;
            }else{
                _mapView.trafficEnabled = NO;
                NSLog(@"关闭交通图");
            }
        }
            break;

        case 3:
        {
            NSLog(@"开启热力图");
            if (_mapView.baiduHeatMapEnabled == NO) {
                _mapView.baiduHeatMapEnabled = YES;
            }else{
                _mapView.baiduHeatMapEnabled = NO;
                NSLog(@"关闭热力图");
            }
        }
            break;
            
        case 4:
        {
            NSLog(@"开启3D建筑图");
            if (_mapView.buildingsEnabled == NO) {
                _mapView.buildingsEnabled = YES;
                _mapView.overlooking = -45;
            }else{
                _mapView.buildingsEnabled = NO;
                _mapView.overlooking = 0;
                NSLog(@"关闭3D建筑图");
            }
        }
            
        default:
            break;
    }
}

#pragma mark - 创建自定义TabBar
- (void)creatCustomTabBar
{
    //自定义TabBar
    _tabBar = [[UIView alloc] initWithFrame:CGRectMake(10, ECSCREEN_H /14 *13 - 10, ECSCREEN_W - 20, ECSCREEN_H / 14)];
    _tabBar.layer.shadowColor = [UIColor blackColor].CGColor ;
    _tabBar.layer.shadowOpacity=0.5;
    _tabBar.layer.shadowOffset = CGSizeMake(5, 5);
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _tabBar.frame.size.width, _tabBar.frame.size.height)];
    backgroundImageView.image = [UIImage imageNamed:@"default_main_toolbar_bg_normal.png"];
    [_tabBar addSubview:backgroundImageView];
    
    //解析plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"toolbarList" ofType:@"plist"];
    //NSLog(@"plist=====%@",path);
    NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableArray *bottom = [root objectForKey:@"bottom"];
    
    for (int i = 0; i < bottom.count; i++) {
        NSDictionary *dict = bottom[i];
        NSString *imageStr = [NSString stringWithFormat:@"default_%@_normal@2x.png",[dict objectForKey:@"icon"]];
        NSString *titleStr = [dict objectForKey:@"title"];
        //NSLog(@"%@=====%@",imageStr,titleStr);
        
        //创建button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(_tabBar.frame.size.width/4*i, 0, _tabBar.frame.size.width/4, _tabBar.frame.size.height);
        //button.backgroundColor = [UIColor redColor];
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 100 +i;
        [_tabBar addSubview:button];
        
        //button的图片
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, button.frame.size.height/2 - 10, 20, 20)];
        imageView.image = [UIImage imageNamed:imageStr];
        [button addSubview:imageView];
        //NSLog(@"加载图片");
        
        //button的标题
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, button.frame.size.height/2 - 10, button.frame.size.width - 30, 20)];
        label.text = titleStr;
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
        label.textColor = [UIColor blackColor];
        [button addSubview:label];
    }
    [self.view addSubview:_tabBar];
}

#pragma mark - button点击触发事件
- (void)btnClick:(UIButton *)button
{
    switch (button.tag) {
        case 100:
        {
            ECNearViewController *nearViewController = [[ECNearViewController alloc] init];
            [self presentViewController:nearViewController animated:YES completion:^{
                
            }];
            //ECRELEASE(nearViewController);
        }
            break;
            
        case 101:
        {
            ECPathViewController *pathViewController = [[ECPathViewController alloc] init];
            [self presentViewController:pathViewController animated:YES completion:^{
                
            }];
            //ECRELEASE(pathViewController);
        }
            break;
            
        case 102:
        {
            ECNaviViewController *naviViewController= [[ECNaviViewController alloc] init];
            [self presentViewController:naviViewController animated:YES completion:^{
                
            }];
            //ECRELEASE(naviViewController);
        }
            break;
            
        case 103:
        {
            ECMoreViewController *moreViewController = [[ECMoreViewController alloc] init];
            [self presentViewController:moreViewController animated:YES completion:^{
                
            }];
            //ECRELEASE(moreViewController);
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
