//
//  JsonFile.m
//  NaviUtil
//
//  Created by Coming on 7/28/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "JsonFile.h"
#import "Log.h"

@implementation JsonFile

+(JsonFile*) jsonFileWithFileName:(NSString*) fileName
{
    JsonFile* jf = [[JsonFile alloc] init];
    
    if ( nil != jf)
    {
        [jf open:fileName];
        return jf;
    }
    
    return nil;
}

-(BOOL) open:(NSString*) fileName
{

    _fileName = fileName;

    @try
    {
        NSData *data;
        
        if (YES == [[NSFileManager defaultManager] fileExistsAtPath:_fileName])
        {
            data = [[NSFileManager defaultManager] contentsAtPath:_fileName];
            _root = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization
                                                                JSONObjectWithData:data //1
                                                                options:kNilOptions
                                                                error:nil]];
        }
        else
        {
            _root = [NSMutableDictionary dictionaryWithCapacity:0];
        }

    }
    @catch (NSException *exception)
    {
        mlogException(exception);
        return FALSE;
    }

    return _root.count > 0;
}

-(void) save
{
    @try
    {
        //convert object to data
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:_root
                                                           options:NSJSONWritingPrettyPrinted error:nil];
        [jsonData writeToFile:_fileName atomically:true];
    }
    @catch (NSException *exception)
    {
        mlogException(exception);
    }
}

-(id) objectForKey:(NSString*) key
{
    return [_root objectForKey:key];
}

-(void) setObjectForKey:(NSString*) key object:(id) object
{
    [_root setObject:object forKey:key];
}

-(void) setIntForKey:(NSString*) key value:(int) value
{
    [self setObjectForKey:key object:[NSString stringFromInt:value]];
}

-(void) setDoubleForKey:(NSString*) key value:(double) value
{
    [self setObjectForKey:key object:[NSString stringFromDouble:value]];
}

-(void) setFloatForKey:(NSString*) key value:(float) value
{
    [self setObjectForKey:key object:[NSString stringFromFloat:value]];
}

-(void) setBOOLForKey:(NSString*) key value:(BOOL) value
{
    [self setObjectForKey:key object:[NSString stringFromBOOL:value]];
}

@end
