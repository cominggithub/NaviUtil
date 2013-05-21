//
//  UIView+category.m
//  NaviUtil
//
//  Created by Coming on 13/5/11.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "UIView+category.h"

@implementation UIView (category)

-(void) dumpView
{
    [self dumpViewOffset:@""];
    
}

-(void) dumpViewOffset:(NSString*) offset
{
    int i;

    printf("%s%s\n", [offset UTF8String], [[self description] UTF8String]);
    for(i=0; i<[self subviews].count; i++)
    {
        UIView *tmpView = [self.subviews objectAtIndex:i];
        [tmpView dumpViewOffset:[NSString stringWithFormat:@"%@  ", offset]];
        
    }
}
-(NSString*) description
{
    if (self.accessibilityLabel != nil)
        return [NSString stringWithFormat:@"%s - %s", (char*)class_getName([self class]), [self.accessibilityLabel UTF8String]];
    return [NSString stringWithFormat:@"%s", (char*)class_getName([self class])];
}


@end
