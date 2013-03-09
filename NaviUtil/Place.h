//
//  Place.h
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Place : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) CLLocationCoordinate2D coordinate;

+(NSArray*) parseJson:(NSString*) fileName;

@end
