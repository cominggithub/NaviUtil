//
//  NaviState.h
//  NaviUtil
//
//  Created by Coming on 4/26/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    GR_EVENT_GPS_NO_SIGNAL,
    GR_EVENT_NETWORK_NO_SIGNAL,
    GR_EVENT_LOCATION_LOST,
    GR_EVENT_GPS_READY,
    GR_EVENT_ROUTE_LINE_READY,
    GR_EVENT_NETWORK_READY,
    GR_EVENT_ALL_READY,
    GR_EVENT_ROUTE_DESTINATION_ERROR,
    GR_EVENT_START_NAVIGATION,
    GR_EVENT_ACTIVE,
    GR_EVENT_INACTIVE,
    GR_EVENT_ARRIVAL,
    GR_EVENT_NO_ROUTE
}GR_EVENT;

typedef enum
{
    GR_STATE_ROUTE_PLANNING,
    GR_STATE_ROUTE_REPLANNING,
    GR_STATE_ROUTE_DESTINATION_ERROR,
    GR_STATE_NAVIGATION,
    GR_STATE_GPS_NO_SIGNAL,
    GR_STATE_NETWORK_NO_SIGNAL,
    GR_STATE_LOOKUP,
    GR_STATE_ARRIVAL,
    GR_STATE_INIT,
    GR_STATE_NO_ROUTE
    
}GR_STATE;

@class NaviState;

@protocol NaviStateDelegate <NSObject>
-(void) naviState:(NaviState*) naviState newState:(GR_STATE) newState;
@end
@interface NaviState : NSObject

@property (nonatomic, readonly) GR_STATE state;
@property (nonatomic, weak) id<NaviStateDelegate> delegate;
-(NSString*) GR_EventStr:(GR_EVENT) event;
-(NSString*) GR_StateStr:(GR_STATE) state;
-(void) sendEvent:(GR_EVENT) event;
@end
