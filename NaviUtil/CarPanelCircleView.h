//
//  CarPanel2CircleView.h
//  NaviUtil
//
//  Created by Coming on 7/24/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarPanelViewProtocol.h"

@interface CarPanelCircleView : UIImageView<CarPanelColorProtocol>

@property (weak, nonatomic) UIColor* color;
@property (strong, nonatomic) UIImage *circleImage;
@property (weak, nonatomic) NSString *imageName;
@property (nonatomic) double heading;

@end
