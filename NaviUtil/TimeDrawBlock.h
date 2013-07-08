//
//  TimeDrawBlock.h
//  NaviUtil
//
//  Created by Coming on 7/6/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "DrawBlock.h"

@interface TimeDrawBlock : DrawBlock

@property (strong, nonatomic) NSString* numImagePrefix;
@property (strong, nonatomic) NSDate* value;

+(TimeDrawBlock*) timeDrawBlockWithNumImagePrefix:(NSString*) numPrefix origin:(CGPoint) origin size:(CGSize) size;

@end
