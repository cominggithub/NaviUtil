//
//  SystemStatusView.h
//  NaviUtil
//
//  Created by Coming on 8/17/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SystemManager.h"

@interface SystemStatusView : UIView<SystemManagerDelegate>

@property (strong, nonatomic) UIColor *color;
@property (nonatomic) float batteryLife;
@property (nonatomic) float networkStatus;
@property (nonatomic) BOOL gpsEnabled;

-(void) active;
-(void) deactive;

@end
