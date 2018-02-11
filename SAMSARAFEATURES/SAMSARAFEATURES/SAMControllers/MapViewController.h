//
//  MapViewController.h
//  
//
//  Created by 张冲 on 17/3/2.
//
//
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "VPLocationConverter.h"
#import "VPAnnotation.h"
#import <MapKit/MapKit.h>
#import "SAOpenRecordModel.h"
@interface MapViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate>
{
    
    MKCoordinateRegion hisMk;
    
    //自带
    MKMapView *_originalMapView;
    
    //自带
    MKPolyline* _originalRouteLine;
    
    //自带
    MKPolylineRenderer* _originalRouteLineView;
    
    // 自带
    MKMapRect _originalRouteRect;
    
    // 自带
    VPAnnotation *originalStartAnnotation;
    // 自带
    VPAnnotation *originalEndAnnotation;
    
    
}
@property (nonatomic, strong) SAOpenRecordModel *lostModel;

@property (nonatomic, strong) CLLocationManager* locationManager;
@end
