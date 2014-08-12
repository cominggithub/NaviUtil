//
//  GoogleUtil.h
//  NavierIOS
//
//  Created by Coming on 8/12/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleUtil : NSObject

+(void)sendButtonEvent:(NSString*)buttonName;
+(void)sendScreenView:(NSString*)screenName;
+(void)initializeGoogleAnalytics;
+(void)setVerbose:(BOOL) verbose;
@end

