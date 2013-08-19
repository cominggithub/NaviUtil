//
//  MessageBoxLabel.m
//  NaviUtil
//
//  Created by Coming on 8/19/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "MessageBoxLabel.h"
#import <QuartzCore/QuartzCore.h>

#include "Log.h"
@implementation MessageBoxLabel
{
    float _maxHeight;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.maxFont                = 40;
        self.minFont                = 20;
        self.layer.borderColor      = self.textColor.CGColor;
        self.layer.cornerRadius     = 8.0f;
        self.layer.masksToBounds    = YES;
        self.layer.borderWidth      = 3.0f;
        self.backgroundColor        = [UIColor blackColor];
        self.lineBreakMode          = UILineBreakModeTailTruncation;
        self.numberOfLines          = 3;
        self.font                   = [UIFont systemFontOfSize:_maxFont];
        self.textAlignment          = UITextAlignmentCenter;
        _maxHeight                  = frame.size.height;
        self.text                   = @"";
        

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {10, 10, 10, 10};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

-(void) setText:(NSString *)text
{

    if (nil == text)
        text = @"";
    
    super.text = text;
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize     = CGSizeMake(self.frame.size.width-20, _maxHeight-20);
    
    CGSize expectedLabelSize    = [text sizeWithFont:self.font constrainedToSize:maximumLabelSize lineBreakMode:self.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame             = self.frame;
    newFrame.size.height        = expectedLabelSize.height + 20 > _maxHeight ? _maxHeight : expectedLabelSize.height + 20;
    self.frame                  = newFrame;
    
    self.hidden = self.text.length > 0 ? NO:YES;
    
}

-(void) setTextColor:(UIColor *)textColor
{
    super.textColor = textColor;
    self.layer.borderColor=[[UIColor greenColor]CGColor];
    
}

@end
