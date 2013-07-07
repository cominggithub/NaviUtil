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
    UIImage *_preDrawImage;
    UIImage *_imgToDraw;
    float _flashTimeout;
    
}

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;
@property (strong, nonatomic) NSMutableArray* drawBlocks;
@property (nonatomic) int flashInterval;
@property (nonatomic) BOOL visible;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) BOOL rotateInfinite;
@property (nonatomic) float currentAngle;
@property (nonatomic) float targetAngle;
@property (nonatomic) float rotateSpeed; // radius/s
@property (nonatomic) NSDate* lastUpdateTime;
@property (strong, nonatomic) UIColor *color;


+(DrawBlock*) drawBlockWithImageName:(NSString*) name origin:(CGPoint) origin size:(CGSize) size;
-(void) drawRect:(CGRect) rect;
-(void) update;
@end
