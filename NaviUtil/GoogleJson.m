//
//  GoogleJson.m
//  NaviUtil
//
//  Created by Coming on 13/3/7.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "GoogleJson.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation GoogleJson

+(GoogleJsonStatus) getStatus:(NSString*) fileName
{
    NSError* error;
    NSData *data;
    NSDictionary* root;
    NSString *statusCode;

    GoogleJsonStatus status = kGoogleJsonStatus_File_Not_Found;
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        @try {
            data = [[NSFileManager defaultManager] contentsAtPath:fileName];
            root = [NSJSONSerialization
                    JSONObjectWithData:data //1
                    options:kNilOptions
                    error:&error];
            
            statusCode = [root objectForKey:@"status"];
            
            if ([statusCode isEqualToString:@"OK"])
            {
                status = kGoogleJsonStatus_Ok;
            }
            else if ([statusCode isEqualToString:@"ZERO_RESULTS"])
            {
                status = kGoogleJsonStatus_Zero_Results;
            }
            else if ([statusCode isEqualToString:@"OVER_QUERY_LIMIT"])
            {
                status = kGoogleJsonStatus_Over_Query_Limit;
            }
            else if ([statusCode isEqualToString:@"REQUEST_DENIED"])
            {
                status = kGoogleJsonStatus_Request_Denied;
            }
            else if ([statusCode isEqualToString:@"INVALID_REQUEST"])
            {
                status = kGoogleJsonStatus_Invalid_Request;
            }
        }
        @catch (NSException *exception)
        {
            
        }
        @finally
        {

        }
        
        logI(status);
    
    }
    return status;
}
@end
