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
        self.minFont                = 30;
        self.layer.borderColor      = self.textColor.CGColor;
        self.layer.cornerRadius     = 8.0f;
        self.layer.masksToBounds    = YES;
        self.layer.borderWidth      = 3.0f;
        self.backgroundColor        = [UIColor blackColor];
        self.lineBreakMode          = UILineBreakModeTailTruncation;
        self.numberOfLines          = 2;
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
    int fontSize;
    int measuredLineCount;
    int lineCount;
    CGSize maximumLabelSize;
    CGSize expectedLabelSize;
    CGRect newFrame;
    BOOL fit;
    UIFont *font;
    

    if (nil == text)
        text = @"";
    
    super.text  = text;
    fontSize    = self.maxFont;
    fit         = FALSE;
    lineCount   = 0;

    do
    {
        font                = [UIFont fontWithName:self.font.fontName size:fontSize];
        maximumLabelSize    = CGSizeMake(self.frame.size.width-20, _maxHeight+100);
        expectedLabelSize   = [text sizeWithFont:font constrainedToSize:maximumLabelSize lineBreakMode:self.lineBreakMode];

        measuredLineCount   = expectedLabelSize.height/[self getLineHeight:fontSize];
        fontSize--;

        
    }while (measuredLineCount > self.numberOfLines && fontSize >= self.minFont);
    
    if (measuredLineCount > self.numberOfLines)
    {
        double finalHeight  = [self getLineHeight:self.minFont]*self.numberOfLines <= _maxHeight - 20 ?
                                [self getLineHeight:self.minFont]*self.numberOfLines : _maxHeight - 20;
        font                = [UIFont fontWithName:self.font.fontName size:self.minFont];
        maximumLabelSize    = CGSizeMake(self.frame.size.width-20, finalHeight+20);
        expectedLabelSize   = [text sizeWithFont:self.font constrainedToSize:maximumLabelSize lineBreakMode:self.lineBreakMode];
    }
    
    //adjust the label the the new height.
    self.font                   = font;
    newFrame                    = self.frame;
    newFrame.size.height        = expectedLabelSize.height + 20 > _maxHeight ? _maxHeight : expectedLabelSize.height + 20;
    self.frame                  = newFrame;
    self.hidden = self.text.length > 0 ? NO:YES;
}

-(int) getLineHeight:(int)fontSize
{
    CGSize actualSize;
    UIFont *font;
    NSString* sampleText = @"OK";
    double lineHeight = 0;
    
    font = [UIFont boldSystemFontOfSize:fontSize];
    actualSize = [sampleText sizeWithFont:font constrainedToSize:self.frame.size lineBreakMode:self.lineBreakMode];
    lineHeight = actualSize.height;
    return lineHeight;
}

-(void) setColor:(UIColor *)color
{
    _color                  = color;
    super.textColor         = self.color;
    self.layer.borderColor  = self.color.CGColor;
    
}


@end
