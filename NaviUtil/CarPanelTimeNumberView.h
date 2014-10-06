//
//  CarPanelTimeNumberView.h
//  NaviUtil
//
//  Created by Coming on 9/21/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>


// 4 3 2 1 0
//     :
@interface CarPanelTimeNumberView : UIView
{
    UIImageView *numberImage[5];
    int numberBlock[5];
    UIImage* rawImage[13];
    int maxNumberImageHeight;
    
}
@property (nonatomic, copy) NSString* imagePrefix;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, assign) int numberGapPadding;
@property (nonatomic, assign) int numberBlockWidth;
@property (nonatomic, assign) int numberBlockHeight;
@property (nonatomic, assign) int colonWidth;
@property (nonatomic, assign) int colonHeight;
@property (nonatomic, assign) int colonTopOffset;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSTimeInterval elapsedTime;

@end
