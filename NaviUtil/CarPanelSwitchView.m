//
//  CarPanelSwitchView.m
//  NaviUtil
//
//  Created by Coming on 9/9/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelSwitchView.h"
#import "UIImage+category.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"


@implementation CarPanelSwitchView
{
    UIImage *onImage;
    UIImage *offImage;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setOnImageName:(NSString *)onImageName
{
    _onImageName = onImageName;
    onImage = [UIImage imageNamed:self.onImageName];
}
-(void)setOffImageName:(NSString *)offImageName
{
    _offImageName = offImageName;
    offImage = [UIImage imageNamed:self.offImageName];
}

-(void)setColor:(UIColor *)color
{
    _color      = color;
    self.image  = [self.image imageTintedWithColor:self.color];
}

-(void)on
{
    self.image = [onImage imageTintedWithColor:self.color];
}

-(void)off
{
    self.image = [offImage imageTintedWithColor:self.color];
}
@end
