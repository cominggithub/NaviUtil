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

static IAP_STATUS iapStatus;
+(void) init
{
    iapItems = [[NSMutableDictionary alloc] initWithCapacity:0];
    [self retrieveProduct];
}

+ (long)iapItemCount
{
    return iapItems.count;
}

+ (NavierHUDIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static NavierHUDIAPHelper * sharedInstance;

    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      IAP_NO_AD_STORE_USER_PLACE,
                                      IAP_CAR_PANEL_2,
                                      IAP_CAR_PANEL_3,
                                      IAP_CAR_PANEL_4,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


+(void) retrieveProduct
{
    iapStatus = IAP_STATUS_RETRIEVING;
    [[NavierHUDIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success)
        {
            for (SKProduct* p in products)
            {
                [iapItems setValue:p forKey:p.productIdentifier];
            }
            iapStatus = IAP_STATUS_RETRIEVED;
            [[NSNotificationCenter defaultCenter] postNotificationName:IAP_EVENT_IAP_STATUS_RETRIEVED object:self];
            
        }
        else
        {
            iapStatus = IAP_STATUS_RETRIEVE_FAIL;
            [[NSNotificationCenter defaultCenter] postNotificationName:IAP_EVENT_IAP_STATUS_RETRIEVE_FAIL object:self];
        }
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
        [msg appendString:[NSString stringWithFormat:@"-- \n%@ %@ %0.2f \n%@\n%@\n",
                           skProduct.productIdentifier,
                           skProduct.localizedTitle,
                           skProduct.price.floatValue,
                           skProduct.localizedPrice,
                           skProduct.localizedDescription
                           ]];

    }
    NSLog(@"%@", msg);
}

+(SKProduct*) productByKey:(NSString*) key
{
    return [iapItems objectForKey:key];
}

+ (void)buyProduct:(SKProduct*) product
{
    [[NavierHUDIAPHelper sharedInstance] buyProduct:product];
}

+ (void)restorePurchasedProduct
{
    [[NavierHUDIAPHelper sharedInstance] restoreCompletedTransactions];
}

+ (IAP_STATUS)retrieveIap
{
    return iapStatus;
}


+ (BOOL)hasUnbroughtIap
{
    // car panel 4 is not available for screen size 480x320
    if ([SystemManager lanscapeScreenRect].size.width >= 568)
    {
        
        return ![SystemConfig getBoolValue:IAP_NO_AD_STORE_USER_PLACE] || ![SystemConfig getBoolValue:IAP_CAR_PANEL_2] ||
        ![SystemConfig getBoolValue:IAP_CAR_PANEL_3] || ![SystemConfig getBoolValue:IAP_CAR_PANEL_4];
    }
    
    return ![SystemConfig getBoolValue:IAP_NO_AD_STORE_USER_PLACE] || ![SystemConfig getBoolValue:IAP_CAR_PANEL_2] ||
    ![SystemConfig getBoolValue:IAP_CAR_PANEL_3];
}


@end
