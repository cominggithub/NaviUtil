//
//  GeoUtil.h
//  GoogleDirection
//
//  Created by Coming on 13/2/2.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "log.h"

#define TO_ANGLE(r) ((r*180.0)/M_PI)

#define MAX_LEVEL 20
typedef struct PointD
{
    double x;
    double y;
}PointD;

typedef struct SizeD
{
    double width;
    double height;
}SizeD;

typedef struct LocationCoordinateRect2D
{
    CLLocationCoordinate2D origin;
    SizeD size;
}LocationCoordinateRect2D;

@interface GeoUtil : NSObject

+(CGPoint) getCGPoint:(PointD) p;
+(float) isOnPath: (PointD) c Point1:(PointD) p1 Point2:(PointD) p2;
+(float) getAngleByLocation1: (CLLocationCoordinate2D) l1 Location2:(CLLocationCoordinate2D) l2 Location3:(CLLocationCoordinate2D) l3;
+(float) getAngleByPoint1: (PointD) p1 Point2:(PointD) p2 Point3:(PointD) p3;
+(float) getLength: (PointD) p1 ToPoint:(PointD) p2;
+(float) getLengthFromLocation: (CLLocationCoordinate2D) p1 ToLocation:(CLLocationCoordinate2D) p2;
+(float) getGeoDistanceFromLocation: (CLLocationCoordinate2D) p1 ToLocation:(CLLocationCoordinate2D) p2;

+(LocationCoordinateRect2D) getRectByLocation:(CLLocationCoordinate2D)location level:(int)level;
+(NSString*)getLatLngStr:(CLLocationCoordinate2D)location;
+(PointD) makePointDFromCLLocationCoordinate2D: (CLLocationCoordinate2D) location;
+(PointD) makePointDFromX: (double) x Y:(double) y;
@end



