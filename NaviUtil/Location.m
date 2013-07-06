//
//  Location.m
//  NaviUtil
//
//  Created by Coming on 13/3/18.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "Location.h"

#define FILE_DEBUG FALSE
#include "Log.h"
@implementation Location

@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate ;


-(id) init
{
    self = [super init];
    if( self )
    {
        self.name       = @"";
        self.address    = @"";
        self.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    }
    
    return self;
    
}
-(NSDictionary*) toDictionary
{

    NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.name, @"name",
                            self.address, @"address",
                            [NSDictionary getLatLngDic:self.coordinate], @"location",
                            nil];
    
    
    return result;
}

-(NSString*) description
{
    
    return [NSString stringWithFormat:@"%@, %@, (%.7f, %.7f)", self.name, self.address, self.coordinate.latitude, self.coordinate.longitude];
    
}
@end


