//
//  User.m
//  NaviUtil
//
//  Created by Coming on 13/3/17.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "User.h"

@implementation User


+(void) parseJson:(NSString*) fileName
{
#if 0
    int i;
    NSArray *array;
    NSDictionary *dic;
    NSDictionary *location;
    NSError* error;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:10];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileName];

    
    NSDictionary* root = [NSJSONSerialization
                      JSONObjectWithData:data //1
                      
                      options:kNilOptions
                      error:&error];
    
#endif

}

+(void) save
{
    NSError* error;
    
    //build an info object and convert to json
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"dic1_data", @"dic1_key", nil];
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:@"dic2_data", @"dic2_key", nil];
    NSArray *array1 = [NSArray arrayWithObjects:dic1, dic2, nil];

    NSDictionary *dic3 = [NSDictionary dictionaryWithObjectsAndKeys:@"dic3_data", @"dic3_key", nil];
    NSDictionary *dic4 = [NSDictionary dictionaryWithObjectsAndKeys:@"dic4_data", @"dic4_key", nil];
    NSDictionary *dic5 = [NSDictionary dictionaryWithObjectsAndKeys:@"dic5_data", @"dic5_key", nil];
    NSArray *array2 = [NSArray arrayWithObjects:dic5, array1, nil];
    NSArray *array3 = [NSArray arrayWithObjects:dic3, dic4, array2, nil];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:array3, @"root", nil];
    
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [jsonData writeToFile:[SystemManager userFilePath] atomically:true];
    
}
@end
