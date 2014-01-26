//
//  SKProduct+category.m
//  NaviUtil
//
//  Created by Coming on 1/26/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "SKProduct+category.h"

@implementation SKProduct (category)

-(NSString*) localizedPrice
{
    NSNumberFormatter *formatter;
    formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:self.priceLocale];

    return [formatter stringFromNumber:self.price];
}
@end
