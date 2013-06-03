//
//  NSString+stringByStrippingHTML.m
//  GoogleDirection
//
//  Created by Coming on 13/1/6.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "NSString+category.h"
#import "Log.h"

@implementation NSString (stringByStrippingHTML)

-(NSString*) trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
-(NSString *) stripHTML
{
    NSRange r;
    NSString *s = [self copy] ;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];

    /* remove / character */
     
    s = [s stringByReplacingOccurrencesOfString:@"/" withString:@""];
    return s;
}

-(NSMutableArray *) decodePolyLine
{
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[self length]];
    [encoded appendString:self];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            if (index < encoded.length)
            {
                b = [encoded characterAtIndex:index++] - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            }
        } while (b >= 0x20 && index < encoded.length);

        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;

        do {
            if (index < encoded.length)
            {
                b = [encoded characterAtIndex:index++] - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            }
        } while (b >= 0x20 && index < encoded.length);

        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
//                  printf("[%f,", [latitude doubleValue]);
//                  printf("%f]\n", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }

    return array;
}

-(NSMutableArray *) decodePolyLineLevel
{
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[self length]];
    [encoded appendString:self];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            if (index < encoded.length)
            {
                b = [encoded characterAtIndex:index++] - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            }
        } while (b >= 0x20 && index < encoded.length);
        NSNumber *level = [[NSNumber alloc] initWithFloat:result];
        [array addObject:level];
    }

    return array;
}

+ (NSString *)encodeStringWithCoordinate:(CLLocationCoordinate2D )coordinate
{
    NSMutableString *encodedString = [NSMutableString string];
    // Encode latitude
    int val = 0;
    int value = 0;
    val = round((coordinate.latitude) * 1e5);
    val = (val < 0) ? ~(val<<1) : (val <<1);
    while (val >= 0x20) {
        int value = (0x20|(val & 31)) + 63;
        [encodedString appendFormat:@"%c", value];
        val >>= 5;
    }
    [encodedString appendFormat:@"%c", val + 63];
    
    // Encode longitude
    val = round((coordinate.longitude) * 1e5);
    val = (val < 0) ? ~(val<<1) : (val <<1);
    while (val >= 0x20) {
        value = (0x20|(val & 31)) + 63;
        [encodedString appendFormat:@"%c", value];
        val >>= 5;
    }
    [encodedString appendFormat:@"%c", val + 63];

    
    return encodedString;
}

#if 0
+ (NSString *)encodeStringWithCoordinates:(NSArray *)coordinates
{
    NSMutableString *encodedString = [NSMutableString string];
    int val = 0;
    int value = 0;
    CLLocationCoordinate2D prevCoordinate = CLLocationCoordinate2DMake(0, 0);
    
    for (NSValue *coordinateValue in coordinates) {
        CLLocationCoordinate2D coordinate = [coordinateValue MKCoordinateValue];
        
        // Encode latitude
        val = round((coordinate.latitude - prevCoordinate.latitude) * 1e5);
        val = (val < 0) ? ~(val<<1) : (val <<1);
        while (val >= 0x20) {
            int value = (0x20|(val & 31)) + 63;
            [encodedString appendFormat:@"%c", value];
            val >>= 5;
        }
        [encodedString appendFormat:@"%c", val + 63];
        
        // Encode longitude
        val = round((coordinate.longitude - prevCoordinate.longitude) * 1e5);
        val = (val < 0) ? ~(val<<1) : (val <<1);
        while (val >= 0x20) {
            value = (0x20|(val & 31)) + 63;
            [encodedString appendFormat:@"%c", value];
            val >>= 5;
        }
        [encodedString appendFormat:@"%c", val + 63];
        
        prevCoordinate = coordinate;
    }
    
    return encodedString;
}

#endif
@end
