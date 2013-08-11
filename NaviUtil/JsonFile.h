//
//  JsonFile.h
//  NaviUtil
//
//  Created by Coming on 7/28/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+category.h"

@interface JsonFile : NSObject

@property (strong, nonatomic) NSString* fileName;
@property (strong, nonatomic) NSMutableDictionary *root;

+(JsonFile*) jsonFileWithFileName:(NSString*) fileName;

-(BOOL) open:(NSString*) fileName;
-(void) save;
-(id) objectForKey:(NSString*) key;
-(void) setObjectForKey:(NSString*) key object:(id) object;
-(void) setIntForKey:(NSString*) key value:(int) value;
-(void) setDoubleForKey:(NSString*) key value:(double) value;
-(void) setFloatForKey:(NSString*) key value:(float) value;
-(void) setBoolForKey:(NSString*) key value:(BOOL) value;
-(void) setUIColorForKey:(NSString*) key value:(UIColor*) value;
@end
