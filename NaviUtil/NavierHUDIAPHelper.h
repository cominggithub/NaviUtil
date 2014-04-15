//
//  RageIAPHelper.h
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "IAPHelper.h"

#define IAP_NO_AD_STORE_USER_PLACE @"com.coming.NavierHUD.Iap.AdvancedVersion"

@interface NavierHUDIAPHelper : IAPHelper

+ (void)init;
+ (NavierHUDIAPHelper *)sharedInstance;
+ (void)retrieveProduct;
+ (void)dumpIapItems;
+ (SKProduct*)productByKey:(NSString*) key;
+ (long)iapItemCount;
+ (void)buyProduct:(SKProduct*) product;
+ (void)restorePurchasedProduct;
+ (BOOL)retrieveIap;

@end
