//
//  CarPanel3HeadingView.m
//  NaviUtil
//
//  Created by Coming on 9/9/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel3HeadingView.h"
#import "UIImage+category.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"

@interface CarPanel3HeadingView()
{
    CarPanelCircleView* circleView;
    UIImageView *arrow;
}
@end
@implementation CarPanel3HeadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSelf];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(void) initSelf
{
    [self addUIComponents];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)addUIComponents
{
    // 582, 570, 291, 285
    // 36, 32, 18, 16
    arrow       = [[UIImageView alloc] initWithFrame:CGRectMake(291/2-7, 55, 18, 16)];
    arrow.image = [[UIImage imageNamed:@"cp3_arrow"] imageTintedWithColor:[UIColor redColor]];
    
    circleView  = [[CarPanelCircleView alloc] initWithFrame:CGRectMake(0, 0, 291, 285)];
    [self addSubview:arrow];
    [self addSubview:circleView];
}

-(void)setColor:(UIColor *)color
{
    _color = color;
    arrow.image = [arrow.image  imageTintedWithColor:self.color];
    circleView.color = self.color;
}

-(void)setHeading:(double)heading
{
    _heading = heading;
    circleView.heading = self.heading;
}

-(void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    circleView.imageName = imageName;
}

@end
