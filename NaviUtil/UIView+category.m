//
//  UIView+category.m
//  NaviUtil
//
//  Created by Coming on 13/5/11.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "UIView+category.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation UIView (category)

-(void) dumpView
{
    [self dumpViewOffset:@""];
    
}

-(void) dumpViewOffset:(NSString*) offset
{
    int i;
    
    if (nil == offset && offset.length < 1 && nil != [self description])
        return;
    

    
    @try {
        printf("%s%s\n", [offset UTF8String], [[self description] UTF8String]);
    }
    @catch (NSException *exception) {
        printf("%s???\n", [offset UTF8String]);
    }
   
    

    for(i=0; i<[self subviews].count; i++)
    {
        UIView *tmpView = [self.subviews objectAtIndex:i];
        [tmpView dumpViewOffset:[NSString stringWithFormat:@"%@  ", offset]];
        
    }
}
-(void) dumpConstraint
{
    for (NSLayoutConstraint *c in self.constraints)
    {
        logO(c);
    }
}

-(NSString*) description
{
    if (self.accessibilityLabel != nil)
    {
        
        return [NSString stringWithFormat:@"%s(%s): (%.0f, %.0f) %.0f X %.0f 0x%X",
                [self.accessibilityLabel UTF8String], (char*)class_getName([self class]),
                self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height, (int)self
                ];
    }
    return [NSString stringWithFormat:@"%s:  (%.0f, %.0f) %.0f X %.0f 0x%X",
            (char*)class_getName([self class]), self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height, (int)self];
}

-(void) dumpFrame:(NSString*) name
{
    printf("%s: (%.0f, %.0f) %.0f X %.0f\n", [name UTF8String], self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

@end
