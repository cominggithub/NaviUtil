//
//  CarPanelViewProtocol.h
//  NaviUtil
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@protocol CarPanelSpeedProtocol <NSObject>
-(void)setSpeed:(double) speed;
-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph;
@end

@protocol CarPanelColorProtocol <NSObject>
-(void)setColor:(UIColor*) color;
@optional
-(void)setSecondaryColor:(UIColor*) color;
@end

@protocol CarPanelHeadingProtocol <NSObject>
-(void)setHeading:(double) heading;
@end

@protocol CarPanelLocationProtocol <NSObject>
-(void)setLocation:(CLLocationCoordinate2D) location;
@end

@protocol CarPanelActiveProtocol <NSObject>
-(void)active;
-(void)inactive;
@end

@protocol CarPanelNetworkSwitchProtocol <NSObject>
-(void)networkOn;
-(void)networkOff;
@end

@protocol CarPanelPgskSwitchProtocol <NSObject>
-(void)gpsOn;
-(void)gpsOff;
@end

@protocol CarPanelViewProtocol <CarPanelActiveProtocol, CarPanelSpeedProtocol, CarPanelColorProtocol, CarPanelHeadingProtocol, CarPanelLocationProtocol>
-(void)setIsHud:(BOOL)isHud;
@end

