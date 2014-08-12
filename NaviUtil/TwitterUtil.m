//
//  TwitterUtil.m
//  NaviUtil
//
//  Created by Coming on 8/12/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "TwitterUtil.h"
#import <Social/Social.h>

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"

@implementation TwitterUtil

+(void)shareAppStoreLink:(UIViewController*) parent
{
    SLComposeViewController *slvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    NSString *titleToShare = @"Navier HUD, iPhone Navigation App, supports heads-up display (HUD) and digital dashboard\n";
    
    if (titleToShare.length > 140) {
        titleToShare = [titleToShare substringToIndex:140];
    }
    
    [slvc setInitialText:titleToShare];
    
    if (![slvc addURL:[NSURL URLWithString:@"https://itunes.apple.com/app/navier-hud/id806144673"]]) {
        
        NSLog(@"Couldn't add url");
    }
    
    if (![slvc addImage:[UIImage imageNamed:@"fbshare_1136x640.png"]])
    {
        NSLog(@"Couldn't image");
    }

//    [[[UIApplication sharedApplication].keyWindow.rootViewController].navigationController pushViewController:twitterViewController animated:TRUE];
//    [parent.navigationController pushViewController:twitterViewController animated:TRUE];
    [parent presentViewController:slvc animated:TRUE completion:nil];
}
@end
