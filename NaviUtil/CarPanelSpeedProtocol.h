//
//  CarPanelSpeedProtocol.h
//  NaviUtil
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CarPanelSpeedProtocol <NSObject>
-(void)setSpeed:(double) speed;
-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph;
@end
