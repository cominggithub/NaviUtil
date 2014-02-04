//
//  RageIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "NavierHUDIAPHelper.h"
#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>
#import "SKProduct+category.h"



#define FILE_DEBUG TRUE
#include "Log.h"


@implementation NavierHUDIAPHelper

NSMutableDictionary* iapItems;

+(void) init
{
    iapItems = [[NSMutableDictionary alloc] initWithCapacity:0];
    [self retrieveProduct];
}

+ (int)iapItemCount
{
    return iapItems.count;
}

+ (NavierHUDIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static NavierHUDIAPHelper * sharedInstance;

    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      IAP_NO_AD_STORE_USER_PLACE,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


+(void) retrieveProduct
{
    [[NavierHUDIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success)
        {
            for (SKProduct* p in products)
            {
                [iapItems setValue:p forKey:p.productIdentifier];
            }
        }
        
        [self dumpIapItems];
    }];

}

+(void) dumpIapItems
{
    SKProduct *skProduct;
    NSNumberFormatter *formatter;
    NSMutableString *msg;
    formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    

    msg = [[NSMutableString alloc] init];
    [msg appendString:@"IAP Items\n"];
    for (NSString *key in iapItems.keyEnumerator)
    {
        skProduct = [iapItems objectForKey:key];
        [formatter setLocale:skProduct.priceLocale];
        [msg appendString:[NSString stringWithFormat:@"%@ %@ %0.2f \n%@ %@\n",
                           skProduct.productIdentifier,
                           skProduct.localizedTitle,
                           skProduct.price.floatValue,
                           skProduct.localizedPrice,
                           skProduct.localizedDescription
                           ]];

    }
}

+(SKProduct*) productByKey:(NSString*) key
{
    return [iapItems objectForKey:key];
}

+ (void)buyProduct:(SKProduct*) product
{
    logfn();
    [[NavierHUDIAPHelper sharedInstance] buyProduct:product];
}

@end
