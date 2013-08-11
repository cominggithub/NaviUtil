//
//  NSString+stringByStrippingHTML.h
//  GoogleDirection
//
//  Created by Coming on 13/1/6.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface NSString (stringByStrippingHTML)
-(NSString *) stripHTML;
-(NSMutableArray *) decodePolyLine;
-(NSMutableArray *) decodePolyLineLevel;
-(NSString*) trim;
-(UIColor*) uicolorValue;
+(NSString *) encodeStringWithCoordinate:(CLLocationCoordinate2D )coordinate;
+(NSString*) stringFromInt:(int) value;
+(NSString*) stringFromDouble:(double) value;
+(NSString*) stringFromFloat:(float) value;
+(NSString*) stringFromBOOL:(BOOL) value;
+(NSString*) stringFromUIColor:(UIColor*) color;
+(NSString *) stringFromInt:(int)value numOfDigits:(int) numOfDigits;

@end
