//
//  DigitalNumDrawBlock.h
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "DrawBlock.h"

@interface DigitalNumDrawBlock : DrawBlock

@property (strong, nonatomic) NSString* numImagePrefix;
@property (nonatomic) BOOL isPaddingZero;
@property (nonatomic) int value;

+(DigitalNumDrawBlock*) digitalNumDrawBlockWithNumImagePrefix:(NSString*) numPrefix origin:(CGPoint) origin size:(CGSize) size;
@end
