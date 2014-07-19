//
//  CoordinateTranslator.h
//  NaviUtil
//
//  Created by Coming on 6/1/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
@interface CoordinateTranslator : NSObject

/* multiply MAP_RATIO and apply cosin adjustment on longitude */

+(void) setRefAngleByLatitude:(float) latitude;
+(CGPoint) projectCoordinate:(CLLocationCoordinate2D) coordinate;
+(CGPoint) projectCoordinate:(CLLocationCoordinate2D) coordinate refAngle:(float)angle;
+(CGPoint) rotatePoint:(CGPoint) point at:(CGPoint)origin angle:(double)angle;
+(CGPoint) translateToDrawPointByPoint:(CGPoint)point projectionToScreenOffset:(CGPoint)projectionToScreenOffset screenMirrorPoint:(CGPoint)screenMirrorPoint;
+(CGPoint) getDrawPointByPoint:(CGPoint)point at:(CGPoint)origin angle:(double)angle projectionToScreenOffset:(CGPoint)projectionToScreenOffset screenMirrorPoint:(CGPoint)screenMirrorPoint;
@end
