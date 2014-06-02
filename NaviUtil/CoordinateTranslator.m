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

+(CGPoint) projectCoordinate:(CLLocationCoordinate2D) coordinate
{
    CGPoint p;
    p.x = coordinate.longitude * MAP_RATIO * cos(TO_RADIUS(coordinate.latitude));
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

+(CGPoint) translateToDrawPointByPoint:(CGPoint)point screenOffset:(CGPoint)screenOffset carCenterPoint:(CGPoint)carCenterPoint
{
    CGPoint drawPoint;
    //    translatedPoint.x = translatedPoint.x*ratio*cos(TO_RADIUS(p.y)) + toScreenOffset.x;
    drawPoint.x = point.x + screenOffset.x;
    drawPoint.y = point.y + screenOffset.y;

    // step3: mirror around the y axis of car center point
    // 1. move to origin (-carCenterPoint)
    // 2. mirror, y=-y
    // 3. move back (+carCenterPoint)
    drawPoint.y = carCenterPoint.y - drawPoint.y + carCenterPoint.y;
    
    //    printf("     draw point (%.5f, %.5f) - > (%.0f, %.0f)\n\n", p.x, p.y, translatedPoint.x, translatedPoint.y);

    return drawPoint;
}

+(CGPoint) getDrawPointByPoint:(CGPoint)point at:(CGPoint)origin angle:(double)angle screenOffset:(CGPoint)screenOffset carCenterPoint:(CGPoint)carCenterPoint
{
    CGPoint drawPoint;
    drawPoint = [self rotatePoint:point at:origin angle:angle];
    drawPoint = [self translateToDrawPointByPoint:drawPoint screenOffset:screenOffset carCenterPoint:carCenterPoint];
    
    return drawPoint;
}

+(PointD) getMirrorYPointbyPoint:(PointD) p mirror:(PointD)mirrorPoint
{
    PointD mirroredPoint;
    mirroredPoint.x = p.x;
    mirroredPoint.y = mirrorPoint.y - p.y + mirrorPoint.y;
    
    return mirroredPoint;
}


/*
-(PointD) getDrawPoint:(PointD)p
{
    
    PointD tmpPoint;
    PointD translatedPoint;
    
    // step 1: rotate
    // let carPoint be the origin
    tmpPoint.x = (p.x - carPoint.x);
    tmpPoint.y = (p.y - carPoint.y);
    
    
    // rotate and move back
    //    translatedPoint.x = tmpPoint.x*cos(directionAngle) - tmpPoint.y*sin(directionAngle) + carPoint.x;
    //    translatedPoint.y = tmpPoint.x*sin(directionAngle) + tmpPoint.y*cos(directionAngle) + carPoint.y;
    
    translatedPoint.x = tmpPoint.x*cos(currentDrawAngle) - tmpPoint.y*sin(currentDrawAngle) + carPoint.x;
    translatedPoint.y = tmpPoint.x*sin(currentDrawAngle) + tmpPoint.y*cos(currentDrawAngle) + carPoint.y;
    
    // step2: scale and move to car screen point.
    translatedPoint.x = translatedPoint.x*ratio + toScreenOffset.x;
    translatedPoint.y = translatedPoint.y*ratio + toScreenOffset.y;
    
    
    //    printf("translatedPoint (%.8f, %.8f)\n", translatedPoint.x, translatedPoint.y);
    
    // step3: mirror around the y axis of car center point
    // 1. move to origin (-carCenterPoint)
    // 2. mirror, y=-y
    // 3. move back (+carCenterPoint)
    translatedPoint.y = carCenterPoint.y - translatedPoint.y + carCenterPoint.y;
    
    //    printf("     draw point (%.5f, %.5f) - > (%.0f, %.0f)\n\n", p.x, p.y, translatedPoint.x, translatedPoint.y);
    
    return translatedPoint;
}
*/

/*
-(PointD) translateDrawPoint:(PointD) p
{
    PointD tmpPoint;
    PointD translatedPoint;
    
    // step 1: rotate
    // let carPoint be the origin
    tmpPoint.x = (p.x - carPoint.x);
    tmpPoint.y = (p.y - carPoint.y);
    
    
    // rotate and move back
    //    translatedPoint.x = tmpPoint.x*cos(directionAngle) - tmpPoint.y*sin(directionAngle) + carPoint.x;
    //    translatedPoint.y = tmpPoint.x*sin(directionAngle) + tmpPoint.y*cos(directionAngle) + carPoint.y;
    
    translatedPoint.x = tmpPoint.x*cos(currentDrawAngle) - tmpPoint.y*sin(currentDrawAngle) + carPoint.x;
    translatedPoint.y = tmpPoint.x*sin(currentDrawAngle) + tmpPoint.y*cos(currentDrawAngle) + carPoint.y;
    
    // step2: move to car screen point.
    translatedPoint.x = translatedPoint.x + toScreenOffset.x;
    translatedPoint.y = translatedPoint.y + toScreenOffset.y;
    
    // step3: mirror around the y axis of car center point
    // 1. move to origin (-carCenterPoint)
    // 2. mirror, y=-y
    // 3. move back (+carCenterPoint)
    translatedPoint.y = carCenterPoint.y - translatedPoint.y + carCenterPoint.y;
    
    return
}
 */


@end