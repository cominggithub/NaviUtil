//
//  BatteryNormalDrawBlock.m
//  NaviUtil
//
//  Created by Coming on 7/9/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "BatteryNormalDrawBlock.h"

@implementation BatteryNormalDrawBlock
{
    CGSize _contentSize;
}

+(BatteryNormalDrawBlock*) batteryNormalDrawBlockWithOrigin:(CGPoint) origin size:(CGSize) size;
{
    BatteryNormalDrawBlock* db = [[BatteryNormalDrawBlock alloc] init];
    
    db.origin   = origin;
    db.size     = size;

    return db;
}

-(void) initSelf
{
    [super initSelf];
    _contentSize = CGSizeMake(150, 100);
}

-(void) setLife:(float)life
{
    _life = life > 0 ? life : 0;
    
    if (_life > 0.3)
    {
        [self disableFlash];

    }
    else
    {
        [self enableFlash];

    }
}
-(void) preDrawImage
{
    float lineWidth = 15;
    CGRect mainBody = CGRectMake(lineWidth, lineWidth, 115, 80);
    CGRect head = CGRectMake(
                             mainBody.origin.x+mainBody.size.width,
                             mainBody.origin.y + mainBody.size.height/4,
                             _contentSize.width - mainBody.origin.x+mainBody.size.width,
                             mainBody.size.height/2
                            );
    
    CGRect batterLife = CGRectMake(lineWidth*2, lineWidth*2, _life * (mainBody.size.width - lineWidth*2), mainBody.size.height - lineWidth*2);
    
    UIGraphicsBeginImageContext(_contentSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);

    CGContextSetLineWidth(context, 10.0);
    CGContextStrokeRect(context, mainBody);
    
    CGContextFillRect(context, batterLife);
    CGContextFillRect(context, head);
    
    _preDrawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();


}

-(BOOL) isDrawable
{
    return self.visible;
}


@end
