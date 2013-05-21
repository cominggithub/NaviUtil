//
//  GoogleJson.h
//  NaviUtil
//
//  Created by Coming on 13/3/7.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum GoogleJsonStatus
{
    kGoogleJsonStatus_Ok = 0,
    kGoogleJsonStatus_Zero_Results,
    kGoogleJsonStatus_Over_Query_Limit,
    kGoogleJsonStatus_Request_Denied,
    kGoogleJsonStatus_Invalid_Request,
    kGoogleJsonStatus_File_Not_Found,
    kGoogleJsonStatus_Max,
    
}GoogleJsonStatus;
@interface GoogleJson : NSObject
+(GoogleJsonStatus) getStatus:(NSString*) fileName;

@end
