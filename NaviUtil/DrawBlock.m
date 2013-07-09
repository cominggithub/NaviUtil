//
//  DrawBlock.m
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "DrawBlock.h"
#import "UIImage+category.h"
#import "UIImage+simple-image-processing.h"
#import "GeoUtil.h"


#define FILE_DEBUG TRUE
#include "Log.h"
@implementation DrawBlock
{

}

+(DrawBlock*) drawBlockWithImageName:(NSString*) name origin:(CGPoint) origin size:(CGSize) size
{
    DrawBlock* db = [[DrawBlock alloc] init];
    
    db.image    = [UIImage imageNamed:name];
    db.origin   = origin;
    db.size     = size;
    
    mlogAssertNotNilR(db, nil);
    
    return db;
}

-(id) init
{
    
    self = [super init];
    
    if (self)
    {
        [self initSelf];
    }
    
    return self;
}

-(void) initSelf
{
    _visible        = TRUE;
    _image          = nil;
    _flashVisible   = TRUE;
    _flashInterval  = -1;
    _flashTimeout   = 0;
    _color          = [UIColor cyanColor];
    _currentAngle   = 0;
    _targetAngle    = 0;
    _rotateSpeed    = 0;
    _rotateInfinite = FALSE;
    
}

-(void) setColor:(UIColor *)color
{
    _color = color;

    if (nil != _image)
    {
        _image = [_image imageTintedWithColor:_color];
    }
}

-(void) setImage:(UIImage *)image
{
    _image = image;
    _image = [_image imageTintedWithColor:_color];
}

-(void) drawRect:(CGRect) rect;
{
    NSDate* start = [NSDate date];
    CGRect drawRect = CGRectMake(_origin.x + rect.origin.x,
                                 _origin.y + rect.origin.y,
                                 _size.width,
                                 _size.height
                                 );
    
//    mlogDebug(@"%@ rect: (%.0f, %.0f) (%.0f, %.0f)", _name, drawRect.origin.x, drawRect.origin.y, drawRect.size.width, drawRect.size.height);
    if (FALSE == [self isDrawable])
        return;

    [self update];
    if (FALSE == _flashVisible)
    {
        mlogDebug(@"%@ flash invisible", _name);
        return;
    }


    [_imgToDraw drawInRect:drawRect];
    
    NSDate* end = [NSDate date];
//    mlogDebug(@"%4.4f, %@ ", [end timeIntervalSinceDate:start], _name);
    
    return;
}

-(BOOL) isDrawable
{
    return nil != _image && self.visible;
}

-(void) preDrawImage
{
    _preDrawImage = _image;
}

-(void) update
{

    NSDate* now = [NSDate date];

    
    if (nil == _lastUpdateTime)
    {
        _lastUpdateTime = now;
    }
    
    // timePassed in mini second
    NSTimeInterval timePassed = [now timeIntervalSinceDate:_lastUpdateTime] * 1000;

    [self preDrawImage];
    
    _imgToDraw = _preDrawImage;
    
    if (nil != _preDrawImage)
    {
        float preAngle = _currentAngle;
        if (FALSE == _rotateInfinite)
        {
            if (_currentAngle != _targetAngle)
            {
                if (_currentAngle < _targetAngle)
                {
                    _currentAngle += _rotateSpeed/1000.0 * timePassed;
                
                    if (_currentAngle >= _targetAngle)
                        _currentAngle = _targetAngle;
                }
                else
                {
                    _currentAngle += _rotateSpeed/1000.0 * timePassed;
                    if (_currentAngle >= M_2PI)
                        _currentAngle -= M_2PI;
                }
            
            }
        }
        else
        {
            _currentAngle += _rotateSpeed/1000.0 * timePassed;
            if (_currentAngle >= M_2PI)
                _currentAngle -= M_2PI;
        }

        if (_currentAngle != preAngle)
        {
            _imgToDraw = [_imgToDraw imageRotatedByRadians:_currentAngle];
        }
        
        if (_flashHideInterval != 0 && _flashShowInterval != 0)
        {
            // become hide
            _flashTimeout -= timePassed/1000.0;

            if (_flashTimeout <=0 )
            {
                if (TRUE == _flashVisible)
                {
                    _flashTimeout = _flashHideInterval;
                    _flashVisible = FALSE;
                }
                else
                {
                    _flashTimeout = _flashShowInterval;
                    _flashVisible = TRUE;
                }
            }
        }
    
    }
    

    
    
    _lastUpdateTime = now;
    
}

-(void) enableFlash
{
    self.flashShowInterval = 1;
    self.flashHideInterval = 0.2;
}

-(void) disableFlash
{
    _flashVisible = TRUE;
    self.flashShowInterval = 0;
    self.flashHideInterval = 0;
}
@end
