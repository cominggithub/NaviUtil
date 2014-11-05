//
//  CarPanelBatteryView.m
//  NaviUtil
//
//  Created by Coming on 10/1/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelBatteryView.h"
#import "UIColor+category.h"
#import "UIImageView+category.h"

@implementation CarPanelBatteryView
{
    UIImageView *batteryFrameImage;
    UIView *batteryLifeView;
    UIView *topMask;
    UIView *bottomMask;
    int batteryLifeMaxWidth;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSelf];
    }
    return self;
}

-(void) initSelf
{
    
    self.backgroundColor            = [UIColor blackColor];
    
    
    topMask                         = [[UIView alloc] init];
    topMask.backgroundColor         = [UIColor redColor];
    bottomMask                      = [[UIView alloc] init];
    bottomMask.backgroundColor      = [UIColor redColor];


    CALayer* maskLayer = [CALayer layer];
    batteryLifeMaxWidth             = 0;
    batteryLifeView                 = [[UIView alloc] init];

    maskLayer.frame                 = CGRectMake(0, 0, 39, 16);
    maskLayer.contents              = (__bridge id)[[UIImage imageNamed:@"cp3_battery"] CGImage];
    batteryLifeView.layer.mask      = maskLayer;

    batteryFrameImage               = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 39, 16)];
    batteryFrameImage.image         = [UIImage imageNamed:@"cp3_battery_empty"];

    
//    [self addSubview:batteryLifeView];
    [self addSubview:batteryFrameImage];
    
}

-(void)setBatteryLifeRect:(CGRect)batteryLifeRect
{
    batteryLifeView.frame = CGRectMake(batteryLifeRect.origin.x,
                                       batteryLifeRect.origin.y,
                                       batteryLifeRect.size.width,
                                       batteryLifeRect.size.height);
    
    
    topMask.frame = CGRectMake(batteryLifeRect.origin.x,
                               batteryLifeRect.origin.y,
                               batteryLifeRect.size.width,
                               batteryLifeRect.size.height);
    
    batteryLifeMaxWidth = batteryLifeRect.size.width;
}

-(void)setBatteryPercentage:(int)batteryPercentage
{
    batteryLifeView.frame = CGRectMake(
                                       batteryLifeView.frame.origin.x,
                                       batteryLifeView.frame.origin.y,
                                       batteryLifeMaxWidth * (batteryPercentage/100.0),
                                       batteryLifeView.frame.size.height);
}

-(void)setColor:(UIColor *)color
{
    _color = color;
    batteryLifeView.backgroundColor = [self.color getColorByAlpha:0.35];
    [batteryFrameImage setImageTintColor:self.color];
    
}
@end
