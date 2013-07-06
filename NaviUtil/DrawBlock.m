//
//  DrawBlock.m
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "DrawBlock.h"
#import "UIImage+category.h"

@implementation DrawBlock
{
    BOOL _flashVisible;
    UIImage *_imgToDraw;
    float _flashTimeout;
}
-(void) drawRect:(CGRect) rect
{

    if (nil == _image || FALSE == _visible)
        return;
    
    [self update];
    
    if (FALSE == _flashVisible)
        return;
    
    [_imgToDraw drawInRect:rect];
    
    return;
}

-(void) update
{
    NSDate* now = [NSDate date];
    NSTimeInterval timePassed = [now timeIntervalSinceDate:_lastUpdateTime] * 1000;
    
    if (nil != self.image)
    {
        _imgToDraw = [_image imageTintedWithColor:_color];
        _imgToDraw = [_imgToDraw imageRotatedByRadians:_targetAngle];
        
        if (_flashInterval > 0)
        {
            _flashTimeout -= timePassed;
            if (_flashTimeout < 0)
            {
                _flashVisible = !_flashVisible;
                while (_flashTimeout <= 0)
                {
                    _flashTimeout += _flashInterval;
                }
            }
        }
    }
    
    _lastUpdateTime = now;
}
@end
