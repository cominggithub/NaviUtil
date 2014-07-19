//
//  CoordinateTranslator.m
//  NaviUtil
//
//  Created by Coming on 6/1/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CoordinateTranslator.h"

#import "GeoUtil.h"
#define MAP_RATIO 32000

// ratio 32000, 850m from carCenterPoint to screen top at latitude 0
// ratio 32000, 850m from carCenterPoint to screen top at latitude 0



#include "Log.h"

@implementation CoordinateTranslator

static float refAngle;

+(void) setRefAngleByLatitude:(float) latitude;
{
    refAngle = TO_RADIUS(latitude);
}

+(CGPoint) projectCoordinate:(CLLocationCoordinate2D) coordinate
{
    return [self projectCoordinate:coordinate refAngle:refAngle];
}

+(CGPoint) projectCoordinate:(CLLocationCoordinate2D) coordinate refAngle:(float)angle
{
    CGPoint p;
    p.x = coordinate.longitude * MAP_RATIO * cos(angle);
//    p.x = coordinate.longitude * MAP_RATIO;
    p.y = coordinate.latitude * MAP_RATIO;
    
    return p;
}

+(CGPoint) rotatePoint:(CGPoint) point at:(CGPoint)origin angle:(double)angle
{
    
    CGPoint tmpPoint;
    CGPoint rotatedPoint;
    

    // step 1: rotate
    // let carPoint be the origin
    tmpPoint.x = (point.x - origin.x);
    tmpPoint.y = (point.y - origin.y);
    
    
    // rotate and move back
    //    translatedPoint.x = tmpPoint.x*cos(directionAngle) - tmpPoint.y*sin(directionAngle) + carPoint.x;
    //    translatedPoint.y = tmpPoint.x*sin(directionAngle) + tmpPoint.y*cos(directionAngle) + carPoint.y;
    
    rotatedPoint.x = tmpPoint.x*cos(angle) - tmpPoint.y*sin(angle) + origin.x;
    rotatedPoint.y = tmpPoint.x*sin(angle) + tmpPoint.y*cos(angle) + origin.y;

//    logfns("rotation: (%.2f, %.2f) -> (%.2f, %.2f)\n", point.x, point.y, rotatedPoint.x, rotatedPoint.y);
    
    return rotatedPoint;
}

/* translate projected point (0,0 at left bottom) into draw point (0,0 at left-top) according to carCenterPoint */ 
+(CGPoint) translateToDrawPointByPoint:(CGPoint)point projectedToScreenOffset:(CGPoint)projectedToScreenOffset screenMirrorPoint:(CGPoint)screenMirrorPoint
{
    CGPoint drawPoint;
    //    translatedPoint.x = translatedPoint.x*ratio*cos(TO_RADIUS(p.y)) + toScreenOffset.x;
    drawPoint.x = point.x + projectedToScreenOffset.x;
    drawPoint.y = point.y + projectedToScreenOffset.y;

    // step3: mirror around the y axis of car center point
    // 1. move to origin (-carCenterPoint)
    // 2. mirror, y=-y
    // 3. move back (+carCenterPoint)
    drawPoint.y = screenMirrorPoint.y - drawPoint.y + screenMirrorPoint.y;
    
    //    printf("     draw point (%.5f, %.5f) - > (%.0f, %.0f)\n\n", p.x, p.y, translatedPoint.x, translatedPoint.y);

    return drawPoint;
}

+(CGPoint) getDrawPointByPoint:(CGPoint)point at:(CGPoint)origin angle:(double)angle projectedToScreenOffset:(CGPoint)projectedToScreenOffset screenMirrorPoint:(CGPoint)screenMirrorPoint
{
    CGPoint drawPoint;
    drawPoint = [self rotatePoint:point at:origin angle:angle];
    drawPoint = [self translateToDrawPointByPoint:drawPoint projectedToScreenOffset:projectedToScreenOffset screenMirrorPoint:screenMirrorPoint];
    
    return drawPoint;
}

+(PointD) getMirrorYPointbyPoint:(PointD) p mirror:(PointD)mirrorPoint
{
    PointD mirroredPoint;
    mirroredPoint.x = p.x;
    mirroredPoint.y = mirrorPoint.y - p.y + mirrorPoint.y;
    
    return mirroredPoint;
}

@end
