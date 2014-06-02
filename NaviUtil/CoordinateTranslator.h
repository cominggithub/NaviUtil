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

+(CGPoint) projectCoordinate:(CLLocationCoordinate2D) coordinate;
+(CGPoint) rotatePoint:(CGPoint) point at:(CGPoint)origin angle:(double)angle;
+(CGPoint) translateToDrawPointByPoint:(CGPoint)point screenOffset:(CGPoint)screenOffset carCenterPoint:(CGPoint)carCenterPoint;
+(CGPoint) getDrawPointByPoint:(CGPoint)point at:(CGPoint)origin angle:(double)angle screenOffset:(CGPoint)screenOffset carCenterPoint:(CGPoint)carCenterPoint;
@end
