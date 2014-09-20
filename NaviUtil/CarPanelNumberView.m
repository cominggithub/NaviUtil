//
//  CarPanelNumberView.m
//  NaviUtil
//
//  Created by Coming on 9/20/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelNumberView.h"
#import "UIImageView+category.h"

@implementation CarPanelNumberView
{
    UIImageView *numberImage[3];
    int numberBlock[3];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setNumber:(int)number
{
    int quotient = 0;
    int remainder = 0;
    _number = number;
    
    for (int i=0; i<2; i++)
    {
        remainder = number%((int)pow(10, 2-i));
        quotient = number - remainder;
        numberBlock[2-i] = quotient;
        numberBlock[2-i-1] = remainder;
    }
    
    [self refreshNumberImage];
}

-(void)refreshNumberImage
{
    for (int i=0; i<3; i++)
    {
        if (numberBlock[i] == 0 && i != 0)
        {
            numberImage[i].hidden = YES;
        }
        else
        {
            numberImage[i].hidden = NO;
        }
        
        numberImage[i].image = [UIImage imageNamed:[self getImageNameByNumber:numberBlock[i]]];
        [numberImage[i] setImageTintColor:self.color];
    }
}

-(NSString*) getImageNameByNumber:(int) num
{
    return [NSString stringWithFormat:@"%@%d", self.imagePrefix, num];
}
@end
