//
//  RageIAPHelper.h
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "IAPHelper.h"
#import "IAPEvent.h"
#import "SystemConfig.h"

#define IAP_NO_AD_STORE_USER_PLACE @"com.coming.NavierHUD.Iap.AdvancedVersion"
#define IAP_ADVANCE_VERSION @"com.coming.NavierHUD.Iap.AdvancedVersion"
#define IAP_CAR_PANEL_2 @"com.coming.NavierHUD.Iap.carpanel2"
#define IAP_CAR_PANEL_3 @"com.coming.NavierHUD.Iap.carpanel3"
#define IAP_CAR_PANEL_4 @"com.coming.NavierHUD.Iap.carpanel4"



@interface NavierHUDIAPHelper : IAPHelper

typedef enum
{
    IAP_STATUS_RETRIEVING,
    IAP_STATUS_RETRIEVED,
    IAP_STATUS_RETRIEVE_FAIL
}IAP_STATUS;

+ (void)init;
+ (NavierHUDIAPHelper *)sharedInstance;
+ (void)retrieveProduct;
+ (void)dumpIapItems;
+ (SKProduct*)productByKey:(NSString*) key;
+ (long)iapItemCount;
+ (void)buyProduct:(SKProduct*) product;
+ (void)restorePurchasedProduct;
+ (IAP_STATUS)retrieveIap;
+ (BOOL)hasUnbroughtIap;

@end
