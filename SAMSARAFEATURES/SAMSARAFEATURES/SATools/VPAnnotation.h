//
//  VPAnnotation.h
//  NewVeepooHealth
//
//  Created by weiyipo on 15/12/2.
//  Copyright (c) 2015年 ze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface VPAnnotation : NSObject<MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@end
