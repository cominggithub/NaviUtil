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
+(float) getAngle: (PointD) c Point1:(PointD) p1 Point2:(PointD) p2;
+(float) getLength: (PointD) p1 ToPoint:(PointD) p2;
+(LocationCoordinateRect2D) getRectByLocation:(CLLocationCoordinate2D)location level:(int)level;
+(NSString*)getLatLngStr:(CLLocationCoordinate2D)location;
@end



