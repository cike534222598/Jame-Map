//
//  ECNearViewController.m
//  Map
//
//  Created by Jame on 15/4/22.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import "ECNearViewController.h"
#import <BaiduMapAPI/BMapKit.h>

@interface ECNearViewController () <BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate,UITextFieldDelegate>

@end

@implementation ECNearViewController
{
    BMKMapView *_mapView;
    BMKPoiSearch *_poiSearch;
    BMKLocationService *_locationService;
    BMKGeoCodeSearch *_geoSearch;
    NSString *_cityName;
    
    int curPage;
    
    bool isGeoSearch;
}

#pragma mark - 加载视图
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatNavigationBarWithImage:nil];
    [self creatNavigationBarLeftItemWithLeftTitle:nil LeftImage:[UIImage imageNamed:@"default_generalsearch_searchresultprepage_image_normal.png"]];
    [self creatNavigationBarRightItemWithRightTitle:@"下组数据" RightImage:nil];
    _poiSearch = [[BMKPoiSearch alloc] init];
    _geoSearch = [[BMKGeoCodeSearch alloc] init];
    self.rightButton.enabled = false;
    [self initMap];
    [self ReverseGeocode];
}

#pragma mark - 即将加载视图
- (void)viewWillAppear:(BOOL)animated
{
    [self startLocationService];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _locationService.delegate = self;
    _poiSearch.delegate = self;
    _geoSearch.delegate = self;
}

#pragma mark - 视图即将消失
- (void)viewWillDisappear:(BOOL)animated
{
    _mapView.delegate = nil;
    _locationService.delegate = nil;
    _poiSearch.delegate = nil;
    _geoSearch.delegate = nil;
    [_mapView viewWillDisappear];
    [self stopLocationService];
}

#pragma mark - 初始化地图
- (void)initMap
{
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 64, ECSCREEN_W, ECSCREEN_H-64)];
    _mapView.showsUserLocation = YES;
    _mapView.zoomLevel = 14.5;
    
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

#pragma mark - 反地理编码
-(void)ReverseGeocode
{
    isGeoSearch = false;
    
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    float latitude = [UD floatForKey:@"latitude"];
    float longitude = [UD floatForKey:@"longitude"];
    if (latitude == 0||longitude ==0) {
        NSLog(@"没有上次地理位置");
    }else{
        _mapView.centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        NSLog(@"读取上次地理位置");
    }
    
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){latitude, longitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geoSearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

#pragma mark - 反地里编码Result
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == 0) {
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        item.title = result.address;
        [_mapView addAnnotation:item];
        _mapView.centerCoordinate = result.location;
        NSString* titleStr;
        NSString* showmeg;
        titleStr = @"您当前所在位置";
        showmeg = [NSString stringWithFormat:@"%@",item.title];
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:titleStr message:showmeg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [myAlertView show];
        _cityName = result.addressDetail.city;
    }
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


#pragma mark - 导航左按钮触发事件
- (void)leftBtnClick:(id)leftSender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 右导航按钮触发事件
- (void)rightBtnClick:(id)rightSender
{
    curPage++;
    //城市内检索，请求发送成功返回YES，请求发送失败返回NO
    BMKNearbySearchOption *nearSearchOption = [[BMKNearbySearchOption alloc]init];
    nearSearchOption.pageIndex = curPage;
    nearSearchOption.pageCapacity = 10;
    nearSearchOption.location= _locationService.userLocation.location.coordinate;
    nearSearchOption.radius = 3000;
    nearSearchOption.keyword = self.searchTextField.text;
    BOOL flag = [_poiSearch poiSearchNearBy:nearSearchOption];
    if(flag)
    {
        self.rightButton.enabled = true;
        NSLog(@"周边检索发送成功");
    }
    else
    {
        self.rightButton.enabled = false;
        NSLog(@"周边检索发送失败");
    }
}

#pragma mark - textFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchTextField resignFirstResponder];
    return YES;
}

#pragma mark - 搜索按钮触发事件
- (void)searchBtnClick:(id)sender
{
    NSLog(@"%@",self.searchTextField.text);
    curPage = 0;
    BMKNearbySearchOption *nearSearchOption = [[BMKNearbySearchOption alloc] init];
    nearSearchOption.pageIndex = curPage;
    nearSearchOption.location = _locationService.userLocation.location.coordinate;
    nearSearchOption.radius = 3000;
    nearSearchOption.keyword = self.searchTextField.text;
    BOOL flag = [_poiSearch poiSearchNearBy:nearSearchOption];
        if(flag)
        {
            self.rightButton.enabled = true;
            NSLog(@"周边检索发送成功");
        }
        else
        {
            self.rightButton.enabled = false;
            NSLog(@"周边检索发送失败");
        }
}


#pragma mark - 添加大头针
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    return annotationView;
}

#pragma mark - 选中大头阵
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}

#pragma mark - 添加大头针视图
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"didAddAnnotationViews");
}

#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            [_mapView addAnnotation:item];
            if(i == 0)
            {
                //将第一个点的坐标移到屏幕中央
                _mapView.centerCoordinate = poi.pt;
            }
        }
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
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
