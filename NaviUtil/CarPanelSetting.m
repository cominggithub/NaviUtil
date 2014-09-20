//
//  CarPanelSetting.m
//  NaviUtil
//
//  Created by Coming on 9/20/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelSetting.h"
#import "UIColor+category.h"


#define IS_SPEED_MPH @"is_speed_mph"
#define IS_HUD @"is_hud"
#define IS_COURSE @"is_course"
#define PRIMARY_COLORS @"primary_colors"
#define SECONDARY_COLORS @"secondary_colors"
#define SEL_PRIMARY_COLOR @"sel_primary_color"
#define SEL_SECONDARY_COLOR @"sel_primary_color"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"


@interface CarPanelSetting()

@property (nonatomic) NSArray* primaryColors;
@property (nonatomic) NSArray* secondaryColors;

@end


@implementation CarPanelSetting

-(id)initWithName:(NSString*)name
{
    self = [super init];
    if (self)
    {
        self.name = name;
        if (![self checkSetting])
        {
            [self resetDefault];
        }
        else
        {
            [self loadDefault];
        }
    }
    
    return self;
}

-(void) resetDefault
{
    self.isHud              = false;
    self.isSpeedUnitMph     = true;
    self.isCourse           = true;

    [self initColorByName];
    
    [[NSUserDefaults standardUserDefaults] setObject:_primaryColors forKey:[self getKey:PRIMARY_COLORS]];
    [[NSUserDefaults standardUserDefaults] setObject:_secondaryColors forKey:[self getKey:SECONDARY_COLORS]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) initColorByName
{
    self.primaryColors = @[@"0000FF",
                           @"FFFFFF",
                           @"00BFFF",
                           @"FFFF00",
                           @"00FFFF",
                           ];
    
    self.secondaryColors = @[@"00FF00",
                             @"FFFFFF",
                             @"00BFFF",
                             @"FFFF00",
                             @"00FFFF",
                             ];
    
    if ([self.name isEqualToString:@"CarPanel2"])
    {

    }
    
    self.selPrimaryColor = [self.primaryColors objectAtIndex:0];
    
    
}
-(BOOL) checkSetting
{
    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:[self getKey:IS_HUD]])
    {
        return FALSE;
    }
    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:[self getKey:IS_SPEED_MPH]])
    {
        return FALSE;
    }
    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:[self getKey:IS_COURSE]])
    {
        return FALSE;
    }
    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:[self getKey:SEL_PRIMARY_COLOR]])
    {
        return FALSE;
    }
    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:[self getKey:PRIMARY_COLORS]])
    {
        return FALSE;
    }
    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:[self getKey:SECONDARY_COLORS]])
    {
        return FALSE;
    }
    return TRUE;
}

-(void) loadDefault
{
    _isHud          = [[NSUserDefaults standardUserDefaults] boolForKey:[self getKey:IS_HUD]];
    _isSpeedUnitMph = [[NSUserDefaults standardUserDefaults] boolForKey:[self getKey:IS_SPEED_MPH]];
    _isCourse       = [[NSUserDefaults standardUserDefaults] boolForKey:[self getKey:IS_COURSE]];
    _primaryColors   = [[NSUserDefaults standardUserDefaults] objectForKey:[self getKey:PRIMARY_COLORS]];
    _secondaryColors = [[NSUserDefaults standardUserDefaults] objectForKey:[self getKey:SECONDARY_COLORS]];
    _selPrimaryColor = [UIColor colorWithRGBHexCode:[[NSUserDefaults standardUserDefaults] objectForKey:[self getKey:SEL_PRIMARY_COLOR]]];
}

-(void) setName:(NSString *)name
{
    _name = name;
}

-(void) setIsHud:(BOOL)isHud
{
    _isHud = isHud;
    [[NSUserDefaults standardUserDefaults] setBool:self.isHud forKey:[self getKey:IS_HUD]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    _isSpeedUnitMph = isSpeedUnitMph;
    [[NSUserDefaults standardUserDefaults] setBool:self.isSpeedUnitMph  forKey:[self getKey:IS_SPEED_MPH]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setIsCourse:(BOOL)isCourse
{
    _isCourse = isCourse;
    [[NSUserDefaults standardUserDefaults] setBool:self.isCourse forKey:[self getKey:IS_COURSE]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setSelPrimaryColor:(UIColor *)selPrimaryColor
{
    _selPrimaryColor = selPrimaryColor;
    [[NSUserDefaults standardUserDefaults] setObject:[selPrimaryColor getRGBHexCode]  forKey:[self getKey:SEL_PRIMARY_COLOR]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSArray*) primaryColors
{
    return @[[UIColor colorWithRGBHexCode:[_primaryColors objectAtIndex:0]],
             [UIColor colorWithRGBHexCode:[_primaryColors objectAtIndex:1]],
             [UIColor colorWithRGBHexCode:[_primaryColors objectAtIndex:2]],
             [UIColor colorWithRGBHexCode:[_primaryColors objectAtIndex:3]],
             [UIColor colorWithRGBHexCode:[_primaryColors objectAtIndex:4]]
             ];
}

-(NSArray*) secondaryColors
{
    return @[[UIColor colorWithRGBHexCode:[_secondaryColors objectAtIndex:0]],
             [UIColor colorWithRGBHexCode:[_secondaryColors objectAtIndex:1]],
             [UIColor colorWithRGBHexCode:[_secondaryColors objectAtIndex:2]],
             [UIColor colorWithRGBHexCode:[_secondaryColors objectAtIndex:3]],
             [UIColor colorWithRGBHexCode:[_secondaryColors objectAtIndex:4]]
             ];
}

-(UIColor*) secondaryColorByPrimaryColor:(UIColor*) primaryColor
{
    for (int i=0; i<self.primaryColors.count; i++)
    {
        UIColor* c = [self.primaryColors objectAtIndex:i];
        if ([c isEqual:self.primaryColors])
        {
            return [self.secondaryColors objectAtIndex:i];
        }
    }
    return NULL;
}


-(NSString*)getKey:(NSString*) key
{
    return [NSString stringWithFormat:@"%@_%@", self.name, key];
}

@end
