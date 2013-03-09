//
//  GeoUtil.m
//  GoogleDirection
//
//  Created by Coming on 13/2/2.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "GeoUtil.h"

@implementation GeoUtil

+(CGPoint) getCGPoint:(PointD) p
{
    CGPoint v;
    v.x = p.x;
    v.y = p.y;
    return v;
}



+(float) isOnPath: (PointD) c Point1:(PointD) p1 Point2:(PointD) p2
{
    float angleCP1P2 = [self getAngle:p1 Point1:c Point2:p2];
    float angleCP2P1 = [self getAngle:p2 Point1:c Point2:p2];
    
    return angleCP1P2 <= 90 && angleCP2P1 <= 90;
}

+(float) getAngle: (PointD) c Point1:(PointD) p1 Point2:(PointD) p2
{
    float cp1Lengh, cp2Lengh, p1p2Length;
    double angle = 0;
    float cr = 0;
    cp1Lengh = [self getLength:c ToPoint:p1];
    cp2Lengh = [self getLength:c ToPoint:p2];
    p1p2Length = [self getLength:p1 ToPoint:p2];
    
    
    cr = (pow(cp1Lengh, 2) + pow(cp2Lengh, 2) - pow(p1p2Length, 2))/(2*cp1Lengh*cp2Lengh);
    angle = acos(cr);
    //    printf("angle: %.2f (%.2f, %.2f, %.2f)", (angle/M_PI)*180, cp1Lengh, cp2Lengh, p1p2Length);
    return angle;
}

+(float) getLength: (PointD) p1 ToPoint:(PointD) p2
{
    float length = 0;
    float r1 = pow((p1.x - p2.x), 2);
    float r2 = pow((p1.y - p2.y), 2);
    length = sqrtf((r1+r2));
    //    printf("p1(%.2f, %.2f), p2(%.2f, %.2f)", p1.x, p1.y, p2.x, p2.y);
    //    printf("r1: %.2f, r2: %.2f, r1+r2: %.2f", r1, r2, r1+r2);
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
@end
