//
//  NaviState.m
//  NaviUtil
//
//  Created by Coming on 4/26/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "NaviState.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"
@implementation NaviState
{
    GR_EVENT lastEvent;
    GR_STATE currentState;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        [self initSelf];
    }
    return self;
}

-(void) initSelf
{
    currentState = GR_STATE_INIT;
}


-(GR_STATE) state
{
    return currentState;
}

-(NSString*) GR_EventStr:(GR_EVENT) event
{
    lastEvent = event;
    
    switch (event)
    {
        case GR_EVENT_GPS_NO_SIGNAL:
            return @"GR_EVENT_GPS_NO_SIGNAL";
        case GR_EVENT_NETWORK_NO_SIGNAL:
            return @"GR_EVENT_NETWORK_NO_SIGNAL";
        case GR_EVENT_ROUTE_DESTINATION_ERROR:
            return @"GR_EVENT_ROUTE_DESTINATION_ERROR";
        case GR_EVENT_ARRIVAL:
            return @"GR_EVENT_ARRIVAL";
        case GR_EVENT_GPS_READY:
            return @"GR_EVENT_GPS_READY";
        case GR_EVENT_NETWORK_READY:
            return @"GR_EVENT_NETWORK_READY";
        case GR_EVENT_LOCATION_LOST:
            return @"GR_EVENT_LOCATION_LOST";
        case GR_EVENT_ACTIVE:
            return @"GR_EVENT_ACTIVE";
        case GR_EVENT_INACTIVE:
            return @"GR_EVENT_INACTIVE";
        case GR_EVENT_ALL_READY:
            return @"GR_EVENT_ALL_READY";
        case GR_EVENT_START_NAVIGATION:
            return @"GR_EVENT_START_NAVIGATION";
        case GR_EVENT_ROUTE_LINE_READY:
            return @"GR_EVENT_ROUTE_LINE_READY";
        case GR_EVENT_NO_ROUTE:
            return @"GR_EVENT_NO_ROUTE";
    }
    
}

-(NSString*) GR_StateStr:(GR_STATE)state
{
    switch (state)
    {
        case GR_STATE_INIT:
            return @"GR_STATE_INIT";
        case GR_STATE_NAVIGATION:
            return @"GR_STATE_NAVIGATION";
        case GR_STATE_ROUTE_PLANNING:
            return @"GR_STATE_ROUTE_PLANNING";
        case GR_STATE_ROUTE_REPLANNING:
            return @"GR_STATE_ROUTE_REPLANNING";
        case GR_STATE_GPS_NO_SIGNAL:
            return @"GR_STATE_GPS_NO_SIGNAL";
        case GR_STATE_NETWORK_NO_SIGNAL:
            return @"GR_STATE_NETWORK_NO_SIGNAL";
        case GR_STATE_ARRIVAL:
            return @"GR_STATE_ARRIVAL";
        case GR_STATE_ROUTE_DESTINATION_ERROR:
            return @"GR_STATE_ROUTE_DESTINATION_ERROR";
        case GR_STATE_LOOKUP:
            return @"GR_STATE_LOOKUP";
        case GR_STATE_NO_ROUTE:
            return @"GR_STATE_NO_ROUTE";
    }
    
}


-(void) sendEvent:(GR_EVENT) event
{
    mlogDebug(@"%@", [self GR_EventStr:event]);
    switch (event)
    {
        case GR_EVENT_GPS_NO_SIGNAL:
            [self setState:GR_STATE_GPS_NO_SIGNAL];
            break;
        case GR_EVENT_NETWORK_NO_SIGNAL:
            [self setState:GR_STATE_NETWORK_NO_SIGNAL];
            break;
        case GR_EVENT_ROUTE_DESTINATION_ERROR:
            [self setState:GR_STATE_ROUTE_DESTINATION_ERROR];
            break;
        case GR_EVENT_ARRIVAL:
            [self setState:GR_STATE_ARRIVAL];
            break;
        case GR_EVENT_GPS_READY:
            if (self.state == GR_STATE_GPS_NO_SIGNAL)
                [self setState:GR_STATE_LOOKUP];
            break;
        case GR_EVENT_ROUTE_LINE_READY:
            if (GR_STATE_ROUTE_REPLANNING == self.state || GR_STATE_ROUTE_PLANNING == self.state)
                [self setState:GR_STATE_NAVIGATION];
            break;
        case GR_EVENT_NETWORK_READY:
            if (self.state == GR_STATE_NETWORK_NO_SIGNAL)
                [self setState:GR_STATE_LOOKUP];
            break;
        case GR_EVENT_LOCATION_LOST:
            if (GR_STATE_NAVIGATION == self.state)
            {
                [self setState:GR_STATE_GPS_NO_SIGNAL];
            }
            break;
        case GR_EVENT_ACTIVE:
            [self setState:GR_STATE_LOOKUP];
            break;
        case GR_EVENT_INACTIVE:
            [self setState:GR_STATE_INIT];
            break;
        case GR_EVENT_ALL_READY:
            [self setState:GR_STATE_INIT == self.state ? GR_STATE_ROUTE_PLANNING:GR_STATE_ROUTE_REPLANNING];
            break;
        case GR_EVENT_START_NAVIGATION:
            [self setState:GR_STATE_NAVIGATION];
            break;
        case GR_EVENT_NO_ROUTE:
            [self setState:GR_STATE_NO_ROUTE];
            break;
    }
    
}

-(void) setState:(GR_STATE)state
{
    mlogDebug(@"state change %@ -> %@", [self GR_StateStr:currentState], [self GR_StateStr:state]);
    currentState = state;
    
    [self notifyDelegate];
}

-(void) notifyDelegate
{
    logfn();
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(naviState:newState:)])
    {
        logfn();
        [self.delegate naviState:self newState:self.state];
    }
    logfn();
}
@end
