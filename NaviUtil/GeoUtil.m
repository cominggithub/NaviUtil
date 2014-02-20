//
//  GeoUtil.m
//  GoogleDirection
//
//  Created by Coming on 13/2/2.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "GeoUtil.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation GeoUtil

+(CGPoint) getCGPoint:(PointD) p
{
    CGPoint v;
    v.x = p.x;
    v.y = p.y;
    return v;
}

/* return 0 ~ 3.14 (0-180) */
+(float) getAngleByLocation1: (CLLocationCoordinate2D) l1 Location2:(CLLocationCoordinate2D) l2 Location3:(CLLocationCoordinate2D) l3
{
    PointD p1, p2, p3;
    p1.x = l1.longitude;
    p1.y = l1.latitude;

    p2.x = l2.longitude;
    p2.y = l2.latitude;

    p3.x = l3.longitude;
    p3.y = l3.latitude;
    return [self getAngleByPoint1:p1 Point2:p2 Point3:p3];
}

+(float) getAngle360ByLocation1: (CLLocationCoordinate2D) l1 Location2:(CLLocationCoordinate2D) l2 Location3:(CLLocationCoordinate2D) l3
{
    PointD p1, p2, p3;
    float angle;
    p1.x = l1.longitude;
    p1.y = l1.latitude;
    
    p2.x = l2.longitude;
    p2.y = l2.latitude;
    
    p3.x = l3.longitude;
    p3.y = l3.latitude;
    angle = [self getAngleByPoint1:p1 Point2:p2 Point3:p3];
    
    return p1.x < p3.x ? angle : 2*M_PI - angle;
}

/* return 0 ~ 3.14 (0-180) */
+(float) getAngleByPoint1: (PointD) p1 Point2:(PointD) p2 Point3:(PointD) p3;
{
    float length12, length13, length23;
    double angle = 0;
    double cosValue = 0;
    length12 = [self getLength:p1 ToPoint:p2];
    length13 = [self getLength:p1 ToPoint:p3];
    length23 = [self getLength:p2 ToPoint:p3];
    
    
    if( length12*length23 != 0)
    {
        cosValue = (pow(length12, 2) + pow(length23, 2) - pow(length13, 2))/(2*length12*length23);

        // fix precision problem of double data type
        if (cosValue > 1.0 )
        {
            cosValue = 1.0;
        }
        else if (cosValue < -1.0)
        {
            cosValue = -1.0;
        }
        
        angle = acos(cosValue);
        if (isnan(angle))
        {
            angle = 0;
        }
    }
    else
    {
        angle = 0;
    }
    
    return angle;
}
#if 0
+(float) getAngleByCenterPoint: (PointD) c SidePoint1:(PointD) p1 SidePoint2:(PointD) p2
{
    float cp1Lengh, cp2Lengh, p1p2Length;
    double angle = 0;
    float cr = 0;
    cp1Lengh = [self getLength:c ToPoint:p1];
    cp2Lengh = [self getLength:c ToPoint:p2];
    p1p2Length = [self getLength:p1 ToPoint:p2];
    
    
    cr = (pow(cp1Lengh, 2) + pow(cp2Lengh, 2) - pow(p1p2Length, 2))/(2*cp1Lengh*cp2Lengh);
    angle = acos(cr);
    
    mlogInfo(GEOUTIL, @"angle: %.2f (%.2f, %.2f, %.2f)", TO_ANGLE(angle), cp1Lengh, cp2Lengh, p1p2Length);
    return angle;
}

#endif
+(float) getLength: (PointD) p1 ToPoint:(PointD) p2
{
    float length = 0;
    float r1 = pow((p1.x - p2.x), 2);
    float r2 = pow((p1.y - p2.y), 2);
    length = sqrtf((r1+r2));
    //    printf("p1(%.2f, %.2f), p2(%.2f, %.2f)", p1.x, p1.y, p2.x, p2.y);
    //    printf("r1: %.2f, r2: % .2f, r1+r2: %.2f", r1, r2, r1+r2);
    return sqrt(r1+r2);
}

+(float) getLengthFromLocation: (CLLocationCoordinate2D) p1 ToLocation:(CLLocationCoordinate2D) p2
{
    PointD tp1, tp2;
    tp1.x = p1.longitude;
    tp1.y = p1.latitude;
    
    tp2.x = p2.longitude;
    tp2.y = p2.latitude;
    
    return [self getLength:tp1 ToPoint:tp2];
}

+(float) getMathLengthFromLocation: (CLLocationCoordinate2D) p1 ToLocation:(CLLocationCoordinate2D) p2
{
    float length = 0;
    float r1 = pow((p1.latitude - p2.latitude), 2);
    float r2 = pow((p1.longitude - p2.longitude), 2);
    length = sqrtf((r1+r2));
    return sqrt(r1+r2);
}

+(double) getLevelLongitudeOffset:(int) level
{
    int tmpLevel = level;
    
    double maxLongitude = 180;
    double tmpOffset = maxLongitude*(1.0/8.0);
    while(tmpLevel > 0)
    {
        tmpOffset *= (1.0/2.0);
        tmpLevel --;
    }
    
    return maxLongitude - tmpOffset;
}

+(double) getLevelLatitudeOffset:(int) level
{
    int tmpLevel = level;
    
    double maxLatitude = 90;
    double tmpOffset = maxLatitude*(1.0/8.0);
    
    while(tmpLevel > 0)
    {
        tmpOffset *= (1.0/2.0);
        tmpLevel --;
    }
    
    return maxLatitude - tmpOffset;
}

+(LocationCoordinateRect2D) getRectByLocation:(CLLocationCoordinate2D) location level:(int)level
{
    LocationCoordinateRect2D result;
    double latitudeOffset;
    double longitudeOffset;
    
    if (level >= MAX_LEVEL)
    {
        level = MAX_LEVEL;
    }
    
    longitudeOffset = [GeoUtil getLevelLongitudeOffset:level];
    latitudeOffset = [GeoUtil getLevelLatitudeOffset:level];

    result.origin.longitude = location.longitude - longitudeOffset;
    result.origin.latitude = location.latitude - latitudeOffset;
    result.size.width = 2*longitudeOffset;
    result.size.height = 2*latitudeOffset;
    
    return result;
}

+(NSString*)getLatLngStr:(CLLocationCoordinate2D)location
{
    NSString *result = [NSString stringWithFormat:@"%.5f,%.5f", location.latitude, location.longitude];
    return result;
}

+(PointD) makePointDFromCLLocationCoordinate2D: (CLLocationCoordinate2D) location
{
    PointD d;
    d.x = location.longitude;
    d.y = location.latitude;
    
    return d;
}

+(PointD) makePointDFromX: (double) x Y:(double) y
{
    PointD d;
    d.x = x;
    d.y = y;
    
    return d;
}

+(float) getGeoDistanceFromLocation: (CLLocationCoordinate2D) p1 ToLocation:(CLLocationCoordinate2D) p2
{
    CLLocation* l1 = [[CLLocation alloc] initWithLatitude:p1.latitude longitude:p1.longitude];
    CLLocation* l2 = [[CLLocation alloc] initWithLatitude:p2.latitude longitude:p2.longitude];
    
    return [l1 distanceFromLocation:l2];
}

+(bool) isCLLocationCoordinate2DEqual:(CLLocationCoordinate2D) c1 To:(CLLocationCoordinate2D) c2
{
    return c1.latitude == c2.latitude && c1.longitude == c2.longitude;
}

+(float) getTurnAngleFrom:(double) fromAngle toAngle:(double) toAngle
{
    bool reverseDirection = false;
    double angleOffset = fabs(fromAngle - toAngle);
    double turnAngle;
    
    /* if angle offset > 180 || angle offset < -180
     then turn right + becomes turn left - and
     turn left - becomes turn right +
     */
    
    reverseDirection = angleOffset > (M_PI) ? true:false;
    
    if (fromAngle == toAngle)
        return false;
    
    /* should be turn right + */
    if(fromAngle < toAngle)
    {
        turnAngle = angleOffset;
        /* become turn left - */
        if (true == reverseDirection)
            turnAngle = (-1) * (2*M_PI - turnAngle);
    }
    /* should be turn left - */
    else
    {
        turnAngle = (-1) * angleOffset;
        /* becomes turn right + */
        if (true == reverseDirection)
            turnAngle = 2*M_PI + turnAngle;
    }
    
    return turnAngle;
}


@end
