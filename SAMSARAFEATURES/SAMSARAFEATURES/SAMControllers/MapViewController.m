//
//  MapViewController.m
//  
//
//  Created by ze on 15/12/2.
//
//

#import "MapViewController.h"
#define MERCATOR_RADIUS 85445659.44705395
@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Lost location";
    _originalMapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
    _originalMapView.delegate = self;
    _originalMapView.userInteractionEnabled = YES;
    _originalMapView.userTrackingMode = MKUserTrackingModeFollow;
    MKCoordinateSpan span = {0.01,0.01};
    hisMk.span = span;
    originalStartAnnotation = [[VPAnnotation alloc]init];
    originalStartAnnotation.title = @"Lost location";
    originalStartAnnotation.subtitle = @"The position of the equipment beyond the range";
    CLLocation *location = [[CLLocation alloc]initWithLatitude:[self.lostModel.latitude floatValue] longitude:[self.lostModel.longitude floatValue]];
    originalStartAnnotation.coordinate = [VPLocationConverter wgs84ToGcj02:location.coordinate];
    hisMk.center = originalStartAnnotation.coordinate;
    [self.view addSubview:_originalMapView];
    [self configureLocationManager];
}

- (void)showHistoryTrack{
    [_originalMapView setRegion:hisMk animated:NO];
}

#pragma mark


#pragma mark
#pragma mark Location Manager

- (void)configureLocationManager
{
    // Create the location manager if this object does not already have one.
    if (nil == _locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    
    if([CLLocationManager locationServicesEnabled]){
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 5;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            //[_locationManager requestWhenInUseAuthorization];
            [_locationManager requestAlwaysAuthorization];
        }
    }
    [_locationManager startUpdatingLocation];
}

#pragma mark CLLocationManager delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *newLocation = [locations objectAtIndex:0];
    
    CLLocationCoordinate2D coordinate1 = newLocation.coordinate;
    
    coordinate1 = [VPLocationConverter wgs84ToGcj02:coordinate1];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (originalEndAnnotation == nil && originalStartAnnotation == nil) {
            hisMk.center = coordinate1;
        }
    });
}

#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    MKOverlayRenderer* overlayView = nil;
    
    if(overlay == _originalRouteLine)
    {
        //if we have not yet created an overlay view for this overlay, create it now.
        if (_originalRouteLineView) {
            //[_originalRouteLineView removeFromSuperview];
        }
        
        _originalRouteLineView = [[MKPolylineRenderer alloc]initWithPolyline:_originalRouteLine];
        _originalRouteLineView.strokeColor = [UIColor magentaColor];
        _originalRouteLineView.lineWidth = 5;
        
        overlayView = _originalRouteLineView;
    }
    
    return overlayView;
}

//地图定位回调
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f)
        return;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    if (originalStartAnnotation) {
        [_originalMapView addAnnotation:originalStartAnnotation];
    }
    if (originalEndAnnotation) {
        [_originalMapView addAnnotation:originalEndAnnotation];
    }
    [_originalMapView setRegion:hisMk animated:NO];
}


@end
