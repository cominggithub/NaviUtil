//
//  NSString+stringByStrippingHTML.h
//  GoogleDirection
//
//  Created by Coming on 13/1/6.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NSString (stringByStrippingHTML)
-(NSString *) stripHTML;
-(NSMutableArray *) decodePolyLine;
-(NSMutableArray *) decodePolyLineLevel;
+ (NSString *)encodeStringWithCoordinate:(CLLocationCoordinate2D )coordinate;
@end
