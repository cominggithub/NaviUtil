//
//  BatteryNormalDrawBlock.h
//  NaviUtil
//
//  Created by Coming on 7/9/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "DrawBlock.h"

@interface BatteryNormalDrawBlock : DrawBlock

@property (nonatomic) float life;
+(BatteryNormalDrawBlock*) batteryNormalDrawBlockWithOrigin:(CGPoint) origin size:(CGSize) size;


@end
