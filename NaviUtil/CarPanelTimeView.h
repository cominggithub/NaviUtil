//
//  CarPanel3TimeView.h
//  NaviUtil
//
//  Created by Coming on 9/28/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CarPanelViewProtocol.h"


@interface CarPanelTimeView  : UIView<CarPanelActiveProtocol>
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) BOOL hideNoon;
@property (nonatomic, assign) BOOL cumulativeTime;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSString* imagePrefix;
@property (nonatomic, assign) int number;
@property (nonatomic, assign) int numberGapPadding;
@property (nonatomic, assign) int numberBlockWidth;
@property (nonatomic, assign) int numberBlockHeight;
@property (nonatomic, assign) int colonWidth;
@property (nonatomic, assign) int colonHeight;
@property (nonatomic, assign) int colonTopOffset;
@property (nonatomic, assign) int noonTopOffset;
@property (nonatomic, assign) int noonLeftOffset;

@end
