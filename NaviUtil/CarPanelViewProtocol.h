//
//  CarPanelViewProtocol.h
//  NaviUtil
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol CarPanelSpeedProtocol <NSObject>
-(void)setSpeed:(double) speed;
-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph;
@end

@protocol CarPanelColorProtocol <NSObject>
-(void)setColor:(UIColor*) color;
@end

@protocol CarPanelHeadingProtocol <NSObject>
-(void)setHeading:(double) heading;
@end


@protocol CarPanelViewProtocol <CarPanelSpeedProtocol, CarPanelColorProtocol, CarPanelHeadingProtocol>

@end

