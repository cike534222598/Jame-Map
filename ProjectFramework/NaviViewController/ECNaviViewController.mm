//
//  ECNaviViewController.m
//  Map
//
//  Created by Jame on 15/4/22.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import "ECNaviViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "UIImage+Rotate.h"

#if 1

#define StartAddress @"请输入起点地址"
#define EndAddress @"请输入终点地址"

#else

#define StartAddress @"嘉华中心"
#define EndAddress @"上海人民广场"

#endif


#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface RouteAnnotation : BMKPointAnnotation
{
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
    int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;

@end

@interface ECNaviViewController () <UITextFieldDelegate,BMKGeoCodeSearchDelegate,BMKMapViewDelegate,BMKRouteSearchDelegate,UIAlertViewDelegate>

@end

@implementation ECNaviViewController

{
    UITextField* _webStartName;
    UITextField* _webEndName;
    BMKGeoCodeSearch *_startGeoSearch;
    BMKGeoCodeSearch *_endGeoSearch;
    BMKMapView *_mapView;
    BMKRouteSearch *_routeSearch;
    
    UIAlertView *_geoAlertView;
    UIAlertView *_trafficAlertView;
    BOOL _isAlertShow;

    
    CLLocationCoordinate2D startCoor;
    CLLocationCoordinate2D endCoor;
    
    bool isGeoSearch;
    
    NSInteger num;
}

#pragma mark - 获取百度SDKBundle素材
- (NSString*)getMyBundlePath1:(NSString *)filename
{
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}


#pragma mark - 加载视图
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatNavigationBarWithImage:nil title:@"导航"];
    [self creatNavigationBarLeftItemWithLeftTitle:nil LeftImage:[UIImage imageNamed:@"default_generalsearch_searchresultprepage_image_normal.png"]];
    _startGeoSearch = [[BMKGeoCodeSearch alloc] init];
    _endGeoSearch = [[BMKGeoCodeSearch alloc] init];
    _routeSearch = [[BMKRouteSearch alloc] init];
    [self initView];
    [self initMap];
}

#pragma mark - 导航左按钮触发事件
-(void)leftBtnClick:(id)leftSender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 初始化视图
- (void)initView
{
    
    UIView *controllerView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, ECSCREEN_W, 60)];
    controllerView.backgroundColor = [UIColor whiteColor];
    
    //起点Label
    UILabel *startLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 1, 50, 28)];
    startLabel.text = @"起点";
    startLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14];
    startLabel.textColor = [UIColor blackColor];
    startLabel.textAlignment = NSTextAlignmentCenter;
    [controllerView addSubview:startLabel];
    
    //起点输入框
    _webStartName = [[UITextField alloc] initWithFrame:CGRectMake(50, 1, 200, 28)];
    _webStartName.borderStyle = UITextBorderStyleRoundedRect;
    _webStartName.adjustsFontSizeToFitWidth = YES;
    _webStartName.adjustsFontSizeToFitWidth = YES;
    _webStartName.layer.cornerRadius = 5;
    _webStartName.layer.borderColor = ECRGBACOLOR(67, 67, 67, 1).CGColor;
    _webStartName.layer.borderWidth = 1.2;
    _webStartName.delegate = self;
    _webStartName.text = StartAddress;
    _webStartName.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
    _webStartName.clearsOnBeginEditing = YES;
    [controllerView addSubview:_webStartName];
    
    //终点Label
    UILabel *endLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 50, 28)];
    endLabel.text = @"终点";
    endLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14];
    endLabel.textColor = [UIColor blackColor];
    endLabel.textAlignment = NSTextAlignmentCenter;
    [controllerView addSubview:endLabel];

    //终点输入框
    _webEndName = [[UITextField alloc] initWithFrame:CGRectMake(50, 30, 200, 28)];
    _webEndName.borderStyle = UITextBorderStyleRoundedRect;
    _webEndName.adjustsFontSizeToFitWidth = YES;
    _webEndName.adjustsFontSizeToFitWidth = YES;
    _webEndName.layer.cornerRadius = 5;
    _webEndName.layer.borderColor = ECRGBACOLOR(67, 67, 67, 1).CGColor;
    _webEndName.layer.borderWidth = 1.2;
    _webEndName.delegate = self;
    _webEndName.text = EndAddress;
    _webEndName.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
    _webEndName.clearsOnBeginEditing = YES;
    [controllerView addSubview:_webEndName];
    
    //检索按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = ECRGBACOLOR(170, 85, 28, .5f);
    button.frame = CGRectMake(ECSCREEN_W - 60, 5, 50, 50);
    [button addTarget:self action:@selector(geoSearch:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"检索" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:10];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 8;
    [controllerView addSubview:button];
    
    [self.view addSubview:controllerView];
}


#pragma mark - 视图即将显示
- (void)viewWillAppear:(BOOL)animated{
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _startGeoSearch.delegate = self;
    _endGeoSearch.delegate = self;
    _routeSearch.delegate = self;
}

#pragma mark - 视图即将消失
- (void)viewWillDisappear:(BOOL)animated
{
    _mapView.delegate = nil;
    _startGeoSearch.delegate = nil;
    _endGeoSearch.delegate = nil;
    _routeSearch.delegate = nil;
    [_mapView viewWillDisappear];
}

#pragma mark - 初始化地图
- (void)initMap
{
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 64 + 60, ECSCREEN_W, ECSCREEN_H - 64 - 60)];
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
}

#pragma mark - 检索按钮触发事件
- (void)geoSearch:(UIButton *)button
{
    //检索地址发送失败提示框
    _geoAlertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"知道了", nil];
    _isAlertShow = NO;
    num = 0;
    [self creatStartGeo];
}

#pragma mark - 检索出发地址
- (void)creatStartGeo
{
    isGeoSearch = true;
    //检索出发地址
    BMKGeoCodeSearchOption *startGeocodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    startGeocodeSearchOption.address = _webStartName.text;
    BOOL startFlag = [_startGeoSearch geoCode:startGeocodeSearchOption];
    if(startFlag)
    {
        NSLog(@"geo检索发送成功");
        [self creatEndGeo];
    }
    else
    {
        NSLog(@"geo检索发送失败");
        _geoAlertView.title = @"提示";
        _geoAlertView.message = @"geo检索发送失败";
        [_geoAlertView show];
    }
}

#pragma mark - 检索终点地址
- (void)creatEndGeo
{
    isGeoSearch = true;
    //检索终点地址
    BMKGeoCodeSearchOption *endGeocodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    endGeocodeSearchOption.address = _webEndName.text;
    BOOL endFlag = [_endGeoSearch geoCode:endGeocodeSearchOption];
    if(endFlag)
    {
        NSLog(@"geo检索发送成功");
    }
    else
    {
        NSLog(@"geo检索发送失败");
        _geoAlertView.title = @"提示";
        _geoAlertView.message = @"geo检索发送失败";
        [_geoAlertView show];
    }
}

#pragma mark - 规划驾车路线
- (void)creatPlaneNode
{
    //路线规划起点终点初始化
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = _webStartName.text;
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = _webEndName.text;
    //规划驾车路线
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    BOOL flag = [_routeSearch drivingSearch:drivingRouteSearchOption];
    if(flag)
    {
        NSLog(@"car检索发送成功");
        NSString *titleStr = @"温馨提示";
        NSString *showmeg = [NSString stringWithFormat:@"是否开启导航"];
        
        _trafficAlertView = [[UIAlertView alloc] initWithTitle:titleStr message:showmeg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [_trafficAlertView show];
    }
    else
    {
        NSLog(@"car检索发送失败");
    }
}

#pragma mark - 弹窗触发导航。
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _geoAlertView) {
        
    }else if (alertView == _trafficAlertView){
        if (buttonIndex == 0) {
            [self webNavigation];
            NSLog(@"开启导航");
        }
    }
}

#pragma mark - 检索出发地址,将地址转为地理坐标
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_RESULT_NOT_FOUND) {
        _isAlertShow = YES;
        if (num == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"地址输入错误" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新输入", nil];
            [alertView show];
            num++;
        }
    }else{
        if (searcher == _startGeoSearch) {
            NSLog(@"%f@@@%f",result.location.latitude,result.location.longitude);
            NSLog(@"%@",_webStartName.text);
            startCoor = result.location;
            _mapView.centerCoordinate = result.location;
        }else if (searcher == _endGeoSearch){
            NSLog(@"%f@@@@@%f",result.location.latitude,result.location.longitude);
            NSLog(@"%@",_webEndName.text);
            endCoor = result.location;
            if (!_isAlertShow&&!([_webStartName.text isEqualToString:StartAddress])&&![_webEndName.text isEqualToString:EndAddress]) {
                [self creatPlaneNode];
            }
        }
    }
}

#pragma mark - UITextField Delegate收键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_webStartName resignFirstResponder];
    [_webEndName resignFirstResponder];
    return YES;
}

#pragma mark - 在规划路线添加大头针
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
    BMKAnnotationView* view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 2:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 3:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
            
        }
            break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"waypoint_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_waypoint.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    
    return view;
}


- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        return [self getRouteAnnotationView:view viewForAnnotation:(RouteAnnotation*)annotation];
    }
    return nil;
}


- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}

#pragma mark - 规划自驾路线
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        int size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
    }
}

#pragma mark - 调用web导航
- (void)webNavigation
{
    //初始化调启导航时的参数管理类
    BMKNaviPara* para = [[BMKNaviPara alloc]init];
    //指定导航类型
    para.naviType = BMK_NAVI_TYPE_WEB;
    
    //初始化起点节点
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    //指定起点经纬度
    start.pt = startCoor;
    //指定起点名称
    start.name = _webStartName.text;
    //指定起点
    para.startPoint = start;
    
    NSLog(@"Startlat:%f, Startlon:%f",startCoor.latitude,startCoor.longitude);
    NSLog(@"起点：%@",_webStartName.text);
    
    
    //初始化终点节点
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    //指定起点经纬度
    end.pt = endCoor;
    //指定终点名称
    end.name = _webEndName.text;
    //指定终点
    para.endPoint = end;
    //指定调启导航的app名称
    para.appName = [NSString stringWithFormat:@"%@", @"Map"];
    //调启web导航
    [BMKNavigation openBaiduMapNavigation:para];
    
    NSLog(@"终点：%@",_webEndName.text);
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
