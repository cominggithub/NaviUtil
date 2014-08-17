//
//  GoogleUtil.m
//  NaviUtil
//
//  Created by Coming on 8/12/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "GoogleUtil.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#if DEBUG
#define FILE_DEBUG FALSE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"

@implementation GoogleUtil

+(void)sendScreenView:(NSString*)screenName
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    // Set the screen name on the tracker so that it is used in all hits sent from this screen.
    [tracker set:kGAIScreenName value:screenName];
    
    // Send a screenview.
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
}

+(void)sendButtonEvent:(NSString*)buttonName
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Button"
                                                          action:@"Press"
                                                           label:buttonName
                                                           value:nil] build]];
}

+(void)initializeGoogleAnalytics
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 5;
    
    // Optional: set Logger to VERBOSE for debug information.
    //    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelWarning];
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-53605712-1"];
    
}

+(void)setVerbose:(BOOL) verbose
{
    [[[GAI sharedInstance] logger] setLogLevel:verbose == TRUE ? kGAILogLevelVerbose:kGAILogLevelWarning];
}
@end
