//
//  CarPanelSetting.h
//  NaviUtil
//
//  Created by Coming on 9/20/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CarPanelSetting : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic) BOOL isSpeedUnitMph;
@property (nonatomic) BOOL isHud;
@property (nonatomic) BOOL isCourse;
@property (nonatomic) UIColor* selPrimaryColor;
@property (nonatomic, readonly) NSArray* primaryColors;
@property (nonatomic, readonly) NSArray* secondaryColors;

-(UIColor*) secondaryColorByPrimaryColor:(UIColor*) primaryColor;
-(id)initWithName:(NSString*)name;
@end
