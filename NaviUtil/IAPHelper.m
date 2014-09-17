//
//  IAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

// 1
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "RSSecrets.h"
#import "SystemConfig.h"

#define FILE_DEBUG TRUE
#include "Log.h"

// 2
@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

// 3
@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet * _productIdentifiers;
//    NSMutableSet * _purchasedProductIdentifiers;
}

/* initialize product list */
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;

        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
}

/* retrieve product from itune store */
-(void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    if (nil == _completionHandler)
    {
        _completionHandler = [completionHandler copy];

        _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
        _productsRequest.delegate = self;
        [_productsRequest start];
    }
    
}

/*
- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}
*/
- (void)buyProduct:(SKProduct *)product {
#if RELEASE || DEBUG
    mlogDebug(@"Buying %@...", product.productIdentifier);

    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
#elif RELEASE_TEST
    [self provideContentForProductIdentifier:product.productIdentifier];
#endif
    
}

#pragma mark - SKProductsRequestDelegate

/* receive reponse of product request */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    _completionHandler(YES, response.products);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    mlogDebug(@"Cannot get IAP products");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                mlogDebug(@"SKPaymentTransactionStatePurchased");
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                mlogDebug(@"SKPaymentTransactionStateFailed");
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                mlogDebug(@"SKPaymentTransactionStateRestored");
                [self restoreTransaction:transaction];
            case SKPaymentTransactionStatePurchasing:
                mlogDebug(@"SKPaymentTransactionStatePurchasing");
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    mlogDebug(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAP_EVENT_TRANSACTION_COMPLETE object:transaction.payment.productIdentifier];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    mlogDebug(@"restoreTransaction...");
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAP_EVENT_TRANSACTION_RESTORE object:transaction.payment.productIdentifier];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    mlogDebug(@"failedTransaction...");
    mlogDebug(@"Transaction error: %@", transaction.error.localizedDescription);
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAP_EVENT_TRANSACTION_FAILED object:transaction.payment.productIdentifier];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    mlogAssertStrNotEmpty(productIdentifier);
    [self addPurchasedProductIdentifier:productIdentifier];
    
//    [_purchasedProductIdentifiers addObject:productIdentifier];
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
//    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)addPurchasedProductIdentifier:(NSString*) key
{
    mlogAssertStrNotEmpty(key);
    NSString *iapKey = [self systemConfigKeyByProductIdentifier:key];
    if (nil != iapKey)
    {
        [SystemConfig addIAPItem:iapKey];
        
    }
    
    return ;
}

- (BOOL)hasPurchasedProductIdentifier:(NSString*) key
{
    mlogAssertStrNotEmptyR(key, FALSE);
    
    return [SystemConfig hasIAPItem:[self systemConfigKeyByProductIdentifier:key]];
}

- (NSString*)systemConfigKeyByProductIdentifier:(NSString*) key
{
    mlogAssertStrNotEmptyR(key, nil);
    if ([key isEqualToString:@"com.coming.NavierHUD.Iap.AdvancedVersion"])
    {
        return CONFIG_IAP_IS_ADVANCED_VERSION;
    }
    else if ([key isEqualToString:@"com.coming.NavierHUD.Iap.carpanel2"])
    {
        return CONFIG_IAP_IS_CAR_PANEL_2;
    }
    else if ([key isEqualToString:@"com.coming.NavierHUD.Iap.carpanel3"])
    {
        return CONFIG_IAP_IS_CAR_PANEL_3;
    }
    else if ([key isEqualToString:@"com.coming.NavierHUD.Iap.carpanel4"])
    {
        return CONFIG_IAP_IS_CAR_PANEL_4;
    }
    
    return nil;
}
@end