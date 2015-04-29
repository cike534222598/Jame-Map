//
//  ECPathViewController.m
//  Map
//
//  Created by Jame on 15/4/22.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import "ECPathViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "UIImage+Rotate.h"

#if 1

#define City @"请输入城市"
#define StartAddress @"请输入起点地址"
#define EndAddress @"请输入终点地址"

#else

#define City @"上海"
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

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end

@interface ECPathViewController () <BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate,BMKMapViewDelegate,UITextFieldDelegate>

@end

@implementation ECPathViewController
{
    BMKMapView *_mapView;
    BMKRouteSearch *_routeSearch;
    BMKLocationService *_locationService;
    BMKGeoCodeSearch *_geoSearch;

    UITextField *_startCityTextField;
    UITextField *_endCityTextField;
    UITextField *_startTextField;
    UITextField *_endTextField;
    
    NSInteger  _planType;
    NSString *_currentCity;
    
    NSArray *_suggestArray;
    //歧义类型
    NSInteger _abType; //0 起点  1终点
    
    bool isGeoSearch;
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
    //self.view.backgroundColor = [UIColor redColor];
    [self creatNavigationBarWithImage:nil title:@"路线"];
    [self creatNavigationBarLeftItemWithLeftTitle:nil LeftImage:[UIImage imageNamed:@"default_generalsearch_searchresultprepage_image_normal.png"]];
    _routeSearch = [[BMKRouteSearch alloc] init];
    _geoSearch = [[BMKGeoCodeSearch alloc] init];
    [self initView];
    [self initMapView];
}

#pragma mark - 导航左按钮触发事件
- (void)leftBtnClick:(id)leftSender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 视图即将加载
- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _geoSearch.delegate = self;
    _routeSearch.delegate = self;
}

#pragma mark - 试图即将消失
- (void)viewWillDisappear:(BOOL)animated
{
    _mapView.delegate = nil;
    _geoSearch.delegate = nil;
    _routeSearch.delegate = self;
    [_mapView viewWillDisappear];
}

#pragma mark - 视图初始化
- (void)initView
{
    UIView *controllerView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, ECSCREEN_W, 90)];
    controllerView.backgroundColor = [UIColor whiteColor];
    
    //起点Label
    UILabel *startLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 1, 50, 28)];
    startLabel.text = @"起点";
    startLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14];
    startLabel.textColor = [UIColor blackColor];
    startLabel.textAlignment = NSTextAlignmentCenter;
    [controllerView addSubview:startLabel];
    
    //起点城市输入框
    _startCityTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 1, 100, 28)];
    _startCityTextField.borderStyle = UITextBorderStyleRoundedRect;
    _startCityTextField.adjustsFontSizeToFitWidth = YES;
    _startCityTextField.adjustsFontSizeToFitWidth = YES;
    _startCityTextField.layer.cornerRadius = 5;
    _startCityTextField.layer.borderColor = ECRGBACOLOR(67, 67, 67, 1).CGColor;
    _startCityTextField.layer.borderWidth = 1.2;
    _startCityTextField.delegate = self;
    _startCityTextField.text = City;
    _startCityTextField.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
    _startCityTextField.clearsOnBeginEditing = YES;
    [controllerView addSubview:_startCityTextField];
    
    //起点地址输入框
    _startTextField = [[UITextField alloc]initWithFrame:CGRectMake(160, 1, 150, 28)];
    _startTextField.borderStyle = UITextBorderStyleRoundedRect;
    _startTextField.adjustsFontSizeToFitWidth = YES;
    _startTextField.adjustsFontSizeToFitWidth = YES;
    _startTextField.layer.cornerRadius = 5;
    _startTextField.layer.borderColor = ECRGBACOLOR(67, 67, 67, 1).CGColor;
    _startTextField.layer.borderWidth = 1.2;
    _startTextField.delegate = self;
    _startTextField.text = StartAddress;
    _startTextField.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
    _startTextField.clearsOnBeginEditing = YES;
    [controllerView addSubview:_startTextField];

    //终点Label
    UILabel *endLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 50, 28)];
    endLabel.text = @"终点";
    endLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14];
    endLabel.textColor = [UIColor blackColor];
    endLabel.textAlignment = NSTextAlignmentCenter;
    [controllerView addSubview:endLabel];
    
    //终点城市输入框
    _endCityTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 30, 100, 28)];
    _endCityTextField.borderStyle = UITextBorderStyleRoundedRect;
    _endCityTextField.adjustsFontSizeToFitWidth = YES;
    _endCityTextField.adjustsFontSizeToFitWidth = YES;
    _endCityTextField.layer.cornerRadius = 5;
    _endCityTextField.layer.borderColor = ECRGBACOLOR(67, 67, 67, 1).CGColor;
    _endCityTextField.layer.borderWidth = 1.2;
    _endCityTextField.delegate = self;
    _endCityTextField.text = City;
    _endCityTextField.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
    _endCityTextField.clearsOnBeginEditing = YES;
    [controllerView addSubview:_endCityTextField];

    
    //终点地址输入框
    _endTextField = [[UITextField alloc]initWithFrame:CGRectMake(160, 30, 150, 28)];
    _endTextField.borderStyle = UITextBorderStyleRoundedRect;
    _endTextField.adjustsFontSizeToFitWidth = YES;
    _endTextField.layer.cornerRadius = 5;
    _endTextField.layer.borderColor = ECRGBACOLOR(67, 67, 67, 1).CGColor;
    _endTextField.layer.borderWidth = 1.2;
    _endTextField.delegate = self;
    _endTextField.text = EndAddress;
    _endTextField.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
    _endTextField.clearsOnBeginEditing = YES;
    [controllerView addSubview:_endTextField];
    
    //创建button
    NSArray *titleArr = @[@"公交",@"驾车",@"步行"];
    for (int i = 0; i < titleArr.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 200 +i;
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 5;
        button.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
        button.backgroundColor = ECRGBACOLOR(253, 143, 9, .5f);
        button.frame = CGRectMake(ECSCREEN_W/3*i+20, 60, 60, 26);
        [button addTarget:self action:@selector(trafficBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [controllerView addSubview:button];
    }
    
    [self.view addSubview:controllerView];
}

#pragma mark - textFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_startCityTextField resignFirstResponder];
    [_startTextField resignFirstResponder];
    [_endCityTextField resignFirstResponder];
    [_endTextField resignFirstResponder];
    return YES;
}

#pragma mark - 选择交通方式进行规划
- (void)trafficBtnClick:(UIButton *)button
{
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = _startTextField.text;
    start.cityName = _startCityTextField.text;
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = _endTextField.text;
    end.cityName = _endCityTextField.text;
    
    isGeoSearch = true;
    BMKGeoCodeSearchOption *geocodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    geocodeSearchOption.city= _startCityTextField.text;
    geocodeSearchOption.address = _startTextField.text;
    BOOL flag = [_geoSearch geoCode:geocodeSearchOption];
    if(flag)
    {
        NSLog(@"geo检索发送成功");
    }
    else
    {
        NSLog(@"geo检索发送失败");
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请输入地址" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"输入地址", nil];
    

    switch (button.tag) {
        case 200:
        {
            if ((_startCityTextField.text.length == 0) || (_startTextField.text.length == 0) || (_endCityTextField.text.length ==0) || (_endTextField.text.length == 0)||([_startCityTextField.text isEqualToString:City]) || ([_startTextField.text isEqualToString:StartAddress]) || ([_endCityTextField.text isEqualToString:City]) || ([_endTextField.text isEqualToString:EndAddress])) {
                [alertView show];
            }else{
                BMKTransitRoutePlanOption *transitRouteSearchOption = [[BMKTransitRoutePlanOption alloc]init];
                transitRouteSearchOption.city= start.cityName;
                transitRouteSearchOption.from = start;
                transitRouteSearchOption.to = end;
                BOOL flag = [_routeSearch transitSearch:transitRouteSearchOption];
                
                if(flag)
                {
                    NSLog(@"bus检索发送成功");
                }
                else
                {
                    NSLog(@"bus检索发送失败");
                }

            }
        }
            break;
        case 201:
        {
            if ((_startCityTextField.text.length == 0) || (_startTextField.text.length == 0) || (_endCityTextField.text.length ==0) || (_endTextField.text.length == 0)||([_startCityTextField.text isEqualToString:City]) || ([_startTextField.text isEqualToString:StartAddress]) || ([_endCityTextField.text isEqualToString:City]) || ([_endTextField.text isEqualToString:EndAddress])) {
                [alertView show];
            }else{
                BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
                drivingRouteSearchOption.from = start;
                drivingRouteSearchOption.to = end;
                BOOL flag = [_routeSearch drivingSearch:drivingRouteSearchOption];
                if(flag)
                {
                    NSLog(@"car检索发送成功");
                }
                else
                {
                    NSLog(@"car检索发送失败");
                }

            }
        }
            break;
        case 202:
        {
            if ((_startCityTextField.text.length == 0) || (_startTextField.text.length == 0) || (_endCityTextField.text.length ==0) || (_endTextField.text.length == 0)||([_startCityTextField.text isEqualToString:City]) || ([_startTextField.text isEqualToString:StartAddress]) || ([_endCityTextField.text isEqualToString:City]) || ([_endTextField.text isEqualToString:EndAddress])) {
                [alertView show];
            }else{
                BMKWalkingRoutePlanOption *walkingRouteSearchOption = [[BMKWalkingRoutePlanOption alloc]init];
                walkingRouteSearchOption.from = start;
                walkingRouteSearchOption.to = end;
                BOOL flag = [_routeSearch walkingSearch:walkingRouteSearchOption];
                if(flag)
                {
                    NSLog(@"walk检索发送成功");
                }
                else
                {
                    NSLog(@"walk检索发送失败");
                }

            }
        }
            break;

            
        default:
            break;
    }
}

#pragma mark - 检索出发城市,将出发城市转为地理坐标
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
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
        
        titleStr = @"温馨提示";
        showmeg = [NSString stringWithFormat:@"已经转到您搜索的城市"];
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:titleStr message:showmeg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [myAlertView show];
    }
}


#pragma mark - 初始化地图
- (void)initMapView
{
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 90+64, ECSCREEN_W, ECSCREEN_H - 90 - 64)];
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

#pragma mark - 规划公共汽车路线
- (void)onGetTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKTransitRouteLine* plan = (BMKTransitRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        int size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKTransitStep* transitStep = [plan.steps objectAtIndex:i];
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
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.instruction;
            item.type = 3;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKTransitStep* transitStep = [plan.steps objectAtIndex:j];
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


#pragma mark - 规划步行路线
- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)[result.routes objectAtIndex:0];
        int size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:i];
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
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
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
