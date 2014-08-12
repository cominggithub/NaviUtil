//
//  FBUtil.h
//  NavierIOS
//
//  Created by Coming on 8/10/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "GoogleUtil.h"
@interface FBUtil : NSObject
+(void)shareAppleStoreLink;
+(void)shareAppleStoreLink:(UIViewController*) parent;
@end
