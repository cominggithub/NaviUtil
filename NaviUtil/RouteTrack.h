//
//  RouteTrack.h
//  NaviUtil
//
//  Created by Coming on 5/10/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"
#import "NaviState.h"

@interface RouteTrack : NSObject

@property (nonatomic, strong) NSString* name;
-(void) addRoute:(Route*) route;
-(void) addLocation:(CLLocation*) location event:(GR_EVENT) event;
-(void) save;
@end

