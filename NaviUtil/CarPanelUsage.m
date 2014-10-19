//
//  CarPanelUsage.m
//  NaviUtil
//
//  Created by Coming on 10/19/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelUsage.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"


@implementation CarPanelUsage



-(void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:[NSString stringWithFormat:@"%ld", (long)self.count] forKey:@"count"];
    [encoder encodeObject:[NSString stringWithFormat:@"%ld", (long)self.usedSequenceNumber] forKey:@"usedSequenceNumber"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    self.name = [decoder decodeObjectForKey:@"name"];
    self.count = [[decoder decodeObjectForKey:@"count"] integerValue];
    self.usedSequenceNumber = [[decoder decodeObjectForKey:@"usedSequenceNumber"] integerValue];
    
    return self;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@ - %ld - %ld", self.name, (long)self.count, (long)self.usedSequenceNumber];
}
@end
