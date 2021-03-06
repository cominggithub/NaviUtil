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

#define M_2PI (2*M_PI)
#define TO_ANGLE(r) ((r*180.0)/M_PI)
#define TO_RADIUS(a) ((a*M_PI)/180.0)
#define MS_TO_KMH(m) (m*3.6)
#define MS_TO_MPH(m) (m*2.23693)
#define KMH_TO_MS(m) (m/3.6)
#define M_TO_MILE(m) (m*0.000621371);

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
+(float) getAngle360ByLocation1: (CLLocationCoordinate2D) l1 Location2:(CLLocationCoordinate2D) l2 Location3:(CLLocationCoordinate2D) l3;
+(float) getAngleByLocation1: (CLLocationCoordinate2D) l1 Location2:(CLLocationCoordinate2D) l2 Location3:(CLLocationCoordinate2D) l3;
+(float) getAngleByPoint1: (PointD) p1 Point2:(PointD) p2 Point3:(PointD) p3;
+(float) getLength: (PointD) p1 ToPoint:(PointD) p2;
+(float) getLengthFromLocation: (CLLocationCoordinate2D) p1 ToLocation:(CLLocationCoordinate2D) p2;
+(float) getMathLengthFromLocation: (CLLocationCoordinate2D) p1 ToLocation:(CLLocationCoordinate2D) p2;
+(float) getGeoDistanceFromLocation: (CLLocationCoordinate2D) p1 ToLocation:(CLLocationCoordinate2D) p2;
+(float) getTurnAngleFrom:(double) fromAngle toAngle:(double) toAngle;

+(LocationCoordinateRect2D) getRectByLocation:(CLLocationCoordinate2D)location level:(int)level;
+(NSString*)getLatLngStr:(CLLocationCoordinate2D)location;
+(PointD) makePointDFromCLLocationCoordinate2D: (CLLocationCoordinate2D) location;
+(PointD) makePointDFromX: (double) x Y:(double) y;
+(bool) isCLLocationCoordinate2DEqual:(CLLocationCoordinate2D) c1 To:(CLLocationCoordinate2D) c2;
+(PointD)getPointDFromCGPoint:(CGPoint)p;
@end



