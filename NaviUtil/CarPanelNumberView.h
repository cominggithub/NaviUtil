//
//  CarPanelNumberView.h
//  NaviUtil
//
//  Created by Coming on 9/20/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarPanelNumberView : UIView
{
    UIImageView *numberImage[3];
    int numberBlock[3];
    UIImage* rawImage[10];
    int maxNumberImageHeight;
    
}
@property (nonatomic, copy) NSString* imagePrefix;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, assign) int number;
@property (nonatomic, assign) int numberGapPadding;
@property (nonatomic, assign) int numberBlockWidth;
@property (nonatomic, assign) int numberBlockHeight;


-(NSString*) getImageNameByNumber:(int) num;
-(void) adjustNumberImagePosition;
-(void)addUIComponent;
-(void)setColor:(UIColor *)color;
@end
