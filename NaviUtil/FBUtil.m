//
//  FBUtil.m
//  NavierIOS
//
//  Created by Coming on 8/10/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "FBUtil.h"
#import <Social/Social.h>
#import "GoogleUtil.h"
#import "SystemConfig.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"

@implementation FBUtil

+(void)shareAppleStoreLink
{
    // Check if the Facebook app is installed and we can present
    // the message dialog
    
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link =
    [NSURL URLWithString:@"https://itunes.apple.com/app/navier-hud/id806144673"];
    params.name = @"Naiver HUD";
//    params.caption = @"Awesome iPhone Navigation App";
    params.picture = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/14692540/blog/global/4/navigation_green.png"];
//    params.linkDescription   = @"";

    if ([FBDialogs canPresentMessageDialogWithParams:params]) {
        
        [FBDialogs presentShareDialogWithParams:params clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                          } else {
                                              [GoogleUtil sendButtonEvent:@"Share App Store Link on Facebook"];
                                              [SystemConfig setValue:CONFIG_IS_SHARE_ON_FB BOOL:TRUE];
                                          }
                                      }];
    }  else {
    }
}

+(void)shareAppleStoreLink:(UIViewController*) parent
{
    SLComposeViewController* slvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    NSString *titleToShare = @"Navier HUD, iPhone Navigation App";
    
    if (titleToShare.length > 140) {
        titleToShare = [titleToShare substringToIndex:140];
    }
    
    [slvc setInitialText:titleToShare];
    
    if (![slvc addURL:[NSURL URLWithString:@"https://itunes.apple.com/app/navier-hud/id806144673"]]) {
        
        NSLog(@"Couldn't add url");
    }
    
    if (![slvc addImage:[UIImage imageNamed:@"fbshare_1136x640"]])
    {
        NSLog(@"Couldn't image");
    }
    
    //    [[[UIApplication sharedApplication].keyWindow.rootViewController].navigationController pushViewController:twitterViewController animated:TRUE];
    [parent presentViewController:slvc animated:TRUE completion:nil];

}

@end
