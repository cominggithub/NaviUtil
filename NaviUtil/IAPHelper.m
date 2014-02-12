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

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductUpdatedNotification = @"IAPHelperProductUpdatedNotification";

// 2
@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

// 3
@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                mlogDebug(@"Previously purchased: %@", productIdentifier);
            } else {
                mlogDebug(@"Not purchased: %@", productIdentifier);
            }
        }
        
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
}

-(void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    
    if (nil == _completionHandler)
    {
        _completionHandler = [completionHandler copy];

        _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
        _productsRequest.delegate = self;
        [_productsRequest start];
    }
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

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

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    _completionHandler(YES, response.products);
    _completionHandler = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductUpdatedNotification object:nil userInfo:nil];
    
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
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    mlogDebug(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    mlogDebug(@"restoreTransaction...");
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    mlogDebug(@"failedTransaction...");
    mlogDebug(@"Transaction error: %@", transaction.error.localizedDescription);
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    mlogAssertStrNotEmpty(productIdentifier);
    
    [self addPurchasedProductIdentifier:productIdentifier];
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)addPurchasedProductIdentifier:(NSString*) key
{
    mlogAssertStrNotEmpty(key);
    return [SystemConfig addIAPItem:[self systemConfigKeyByProductIdentifier:key]];
}

- (BOOL)hasPurchasedProductIdentifier:(NSString*) key
{
    mlogAssertStrNotEmptyR(key, FALSE);
    
    return [SystemConfig hasIAPItem:[self systemConfigKeyByProductIdentifier:key]];
}

- (NSString*)systemConfigKeyByProductIdentifier:(NSString*) key
{
    mlogAssertStrNotEmptyR(key, nil);
    if ([key isEqualToString:@"com.coming.NavierHUD.NoAdStoreUserPlace"])
        return CONFIG_IAP_IS_NO_AD_AND_STORE_USER_PLACE;
    
    return nil;
}
@end