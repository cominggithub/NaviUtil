//
//  CarPanelTimeNumberView.h
//  NaviUtil
//
//  Created by Coming on 9/21/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarPanelTimeNumberView : UIView
{
    UIImageView *numberImage[5];
    int numberBlock[5];
    UIImage* rawImage[11];
    int maxNumberImageHeight;
    
}
@property (nonatomic, copy) NSString* imagePrefix;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, assign) int number;
@property (nonatomic, assign) int numberGapPadding;
@property (nonatomic, assign) int numberBlockWidth;
@property (nonatomic, assign) int numberBlockHeight;
@property (nonatomic, assign) int colonWidth;
@end
