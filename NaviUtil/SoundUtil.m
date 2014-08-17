//
//  SoundUtil.m
//  NaviUtil
//
//  Created by Coming on 8/17/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "SoundUtil.h"
#import <AVFoundation/AVFoundation.h>

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"


@implementation SoundUtil
AVAudioPlayer *audioPlayer;
+(void)play:(NSString*)file
{
    @try {
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], file]];
        
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        audioPlayer.numberOfLoops = 0;
        
        [audioPlayer play];
    }
    @catch (NSException *exception) {
        mlogDebug(@"%@", [exception reason]);
    }
    
    @try
    {
        [audioPlayer play];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception reason]);
    }
}

+(void)playSwitchSound
{
    [self play:@"switch-7.mp3"];
}
+(void)playPopup
{
    [self play:@"popup.mp3"];
}
@end
