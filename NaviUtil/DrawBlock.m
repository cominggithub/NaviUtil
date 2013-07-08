//
//  DrawBlock.m
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "DrawBlock.h"
#import "UIImage+category.h"
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

-(void) drawRect:(CGRect) rect
{
    NSDate* start = [NSDate date];
    CGRect drawRect = CGRectMake(_origin.x + rect.origin.x,
                                 _origin.y + rect.origin.y,
                                 _size.width,
                                 _size.height
                                 );
    
    if (FALSE == [self isDrawable])
        return;

    [self update];
    if (FALSE == _flashVisible)
    {
        
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
    
    NSTimeInterval timePassed = [now timeIntervalSinceDate:_lastUpdateTime] * 1000;

    [self preDrawImage];
    
    _imgToDraw = _preDrawImage;
    if (nil != _preDrawImage)
    {

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

//        mlogDebug(@"current angle: %.1f, targetAngle:%.1f", TO_ANGLE(_currentAngle), TO_ANGLE(_targetAngle));
        _imgToDraw = [_imgToDraw imageRotatedByRadians:_currentAngle];
        
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
    else
    {
        mlogDebug(@"predraw image is null\n");
    }

    
    
    _lastUpdateTime = now;
    
}

@end
