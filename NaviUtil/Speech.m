//
//  Speech.m
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "Speech.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation Speech

@synthesize coordinate=_coordinate;
@synthesize text=_text;

-(NSString*) filePath
{
    
    return [NSString stringWithFormat:@"%@%@.mp3", [SystemManager speechFilePath], self.text];
}

@end
