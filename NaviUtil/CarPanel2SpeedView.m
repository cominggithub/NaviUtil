//
//  CarPanel2SpeedView.m
//  NaviUtil
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel2SpeedView.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"


@implementation CarPanel2SpeedView
{
    UILabel *speedLabel;
}

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
    speedLabel.text = @"99999";
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
    speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 250, 15)];
    [self addSubview:speedLabel];
}


#pragma mark -- Property

-(void)setColor:(UIColor *)color
{
    speedLabel.textColor = [UIColor colorWithCGColor:[color CGColor]];
}

-(void)setSpeed:(double)speed
{
    speedLabel.text = [NSString stringWithFormat:@"%.0f", speed];
}

@end
