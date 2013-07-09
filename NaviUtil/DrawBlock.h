//
//  DrawBlock.h
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DrawBlock : NSObject
{
    BOOL _flashVisible;
    float _flashInterval;
    UIImage *_preDrawImage;
    UIImage *_imgToDraw;
    float _flashTimeout;
    
}

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;
@property (strong, nonatomic) NSMutableArray* drawBlocks;
@property (nonatomic) float flashShowInterval;
@property (nonatomic) float flashHideInterval;
@property (nonatomic) BOOL visible;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) BOOL rotateInfinite;
@property (nonatomic) float currentAngle;
@property (nonatomic) float targetAngle;
@property (nonatomic) float rotateSpeed; // radius/s
@property (nonatomic) NSDate* lastUpdateTime;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSString* name;


+(DrawBlock*) drawBlockWithImageName:(NSString*) name origin:(CGPoint) origin size:(CGSize) size;
-(void) drawRect:(CGRect) rect;
-(void) update;
-(void) initSelf;
-(void) enableFlash;
-(void) disableFlash;
@end
