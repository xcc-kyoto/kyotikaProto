//
//  KMViewController.m
//  KyotoMap
//
//  Created by kunii on 2013/01/11.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "KMViewController.h"
#import "KMLever.h"
#import "KMTreasureHunterAnnotationView.h"
#import "KMTreasureAnnotationView.h"
#import "KMVaults.h"
#import "KMQuizeViewController.h"

@interface KMViewController ()<MKMapViewDelegate, KMQuizeViewControllerDelegate> {
    MKMapView* _mapView;
    KMLever* _virtualLeaver;
    MKCoordinateRegion _kyotoregion;
    KMTreasureHunterAnnotation* _hunterAnnotation;
    NSTimer*    _timer;
    KMVaults*    _vaults;
    BOOL        _firstLoad;
}
@end

@implementation KMViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tap:) name:@"KMTreasureAnnotationViewTapNotification" object:nil];
    
    for (id < MKAnnotation > a  in _mapView.annotations) {
        if ([a isKindOfClass:[KMTreasureAnnotation class]]) {
            KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
            [v startAnimation];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)tap:(NSNotification*)notification
{
    KMTreasureAnnotation* annotation = [notification.userInfo objectForKey:@"annotation"];
    KMQuizeViewController* c = [[KMQuizeViewController alloc] initWithStyle:UITableViewStyleGrouped];
    c.question = annotation.question;
    c.answers = annotation.answers;
    c.userRef = annotation;
    c.quizeDelegate = self;
    c.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:c animated:YES];
}

- (void)quizeViewControllerAnswer:(KMQuizeViewController*)controller
{
    KMTreasureAnnotation* annotation = (KMTreasureAnnotation*)controller.userRef;
    if (controller.selectedIndex == annotation.correctAnswerIndex) {
        annotation.passed = YES;
        KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:annotation];
        [v setNeedsDisplay];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _firstLoad = YES;
    
    _vaults = [[KMVaults alloc]init];
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    CGRect frame = CGRectMake(10, self.view.bounds.size.height - 50, 100, 20);
    UILabel* label = [[UILabel alloc]initWithFrame:frame];
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:10];
    label.text = @"バーチャルモード";
    [self.view addSubview:label];
    frame.origin.y += frame.size.height;
    frame.size.width = 150;
    UISwitch* virtualSwitch = [[UISwitch alloc] initWithFrame:frame];
    virtualSwitch.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [virtualSwitch addTarget:self action:@selector(virtualSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:virtualSwitch];
    
    frame = CGRectMake(self.view.bounds.size.width - 120, self.view.bounds.size.height - 120, 80, 80);
    _virtualLeaver = [[KMLever alloc] initWithFrame:frame];
    _virtualLeaver.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    _virtualLeaver.hidden = YES;
    [_virtualLeaver addTarget:self action:@selector(move) forControlEvents:UIControlEventTouchDragInside];
    [self.view addSubview:_virtualLeaver];
    
    //  京都　latitude：35.0212466 longitude：135.7555968
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(35.0212466, 135.7555968);
    _kyotoregion = MKCoordinateRegionMakeWithDistance(center,
                                                                        10000.0,  //  10km
                                                                        10000.0);
    _mapView.region = _kyotoregion;  //  アニメーション抜き
}

- (void)move
{
    CGPoint vector = _virtualLeaver.vector;
    CGPoint pt = [_mapView convertCoordinate:_hunterAnnotation.coordinate toPointToView:_mapView];
    
    float dx = 5 * vector.x;
    float dy = 5 * vector.y;
    CGPoint point = CGPointMake(pt.x + dx, pt.y + dy);
    CLLocationCoordinate2D centerCoordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    _hunterAnnotation.coordinate = centerCoordinate;
    [_mapView setCenterCoordinate:centerCoordinate animated:NO];
    
    KMTreasureHunterAnnotationView* view = (KMTreasureHunterAnnotationView*)[_mapView viewForAnnotation:_hunterAnnotation];
    [view direction:vector];
    
//    MKMetersBetweenMapPoints
}

- (void)virtualSwitch:(UISwitch*)virtualSwitch
{
    if (virtualSwitch.on) {
        [_mapView setUserTrackingMode:MKUserTrackingModeNone  animated:YES];
        _mapView.showsUserLocation = NO;   //  ユーザー位置表示
        _hunterAnnotation = [[KMTreasureHunterAnnotation alloc] init];
        _hunterAnnotation.coordinate = CLLocationCoordinate2DMake(35.0212466 + 0.000, 135.7555968 + 0.000);
        [_mapView addAnnotation:_hunterAnnotation];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_kyotoregion.center,
                                                          500.0,  //  500m
                                                          500.0);
        
        _virtualLeaver.transform = CGAffineTransformMakeScale(0.1, 0.1);
        _virtualLeaver.hidden = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
            _virtualLeaver.transform = CGAffineTransformMakeScale(1.5, 1.5);
                         }
         completion:^(BOOL finished) {
             [UIView animateWithDuration:0.3
                              animations:^{
                                  _virtualLeaver.transform = CGAffineTransformMakeScale(0.8, 0.8);
                              }
                              completion:^(BOOL finished) {
                                                       _virtualLeaver.transform = CGAffineTransformIdentity;
                                                        [_mapView setRegion:region animated:YES];
                              }];

         }];
    } else {
        _virtualLeaver.hidden = YES;
        [_mapView removeAnnotation:_hunterAnnotation];
        [_mapView setUserTrackingMode:MKUserTrackingModeFollow  animated:YES];
        _mapView.showsUserLocation = YES;   //  ユーザー位置表示
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    // これがユーザの位置の場合は、単にnilを返す
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[KMTreasureHunterAnnotation class]]) {
        KMTreasureHunterAnnotationView* pinView = (KMTreasureHunterAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Hunter"];
        if (pinView == nil) {
            pinView = [[KMTreasureHunterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Hunter"];
        }
        pinView.canShowCallout = NO;
        [pinView startAnimation];
        return pinView;
    }
    KMTreasureAnnotationView* pinView = (KMTreasureAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (pinView == nil) {
        pinView = [[KMTreasureAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    }
    pinView.canShowCallout = YES;
    [pinView startAnimation];
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (_firstLoad) {
        return;
    }
    NSMutableSet* treasureAnnotations = [[_vaults treasureAnnotationsInRegion:_mapView.region] mutableCopy];
    NSArray* array = [_mapView annotations];
    NSMutableSet* set = [NSMutableSet setWithArray:array];
    [set minusSet:treasureAnnotations];
    if (_hunterAnnotation)
        [set removeObject:_hunterAnnotation];
    if ([set count] > 0)
        [_mapView removeAnnotations:set.allObjects];
    [treasureAnnotations minusSet:[NSSet setWithArray:array]];
    if ([treasureAnnotations count] > 0)
        [_mapView addAnnotations:treasureAnnotations.allObjects];
    
    for (id < MKAnnotation > a  in _mapView.annotations) {
        if ([a isKindOfClass:[KMTreasureAnnotation class]]) {
            KMTreasureAnnotationView* v = (KMTreasureAnnotationView*)[_mapView viewForAnnotation:a];
            [v setNeedsDisplay];
            [v startAnimation];
        }
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    if (_firstLoad) {
        _firstLoad = NO;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_kyotoregion.center,
                                                                       500.0,  //  500m
                                                                       500.0);
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_mapView setRegion:region animated:YES];
            
        });
        
    }
}
@end

