//
//  GuideRouteUIView.m
//  GoogleDirection
//
//  Created by Coming on 13/1/12.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "GuideRouteUIView.h"
#import "SystemConfig.h"
#import "UIImage+category.h"
#import "UIImageView+category.h"
#import "SystemStatusView.h"
#import "ClockView.h"
#import "SpeedView.h"
#import "MessageBoxLabel.h"



#define FILE_DEBUG TRUE
#include "Log.h"

#define radians(degrees) (degrees * M_PI/180)


@implementation GuideRouteUIView
{
    Route* route;
    DownloadRequest *routeDownloadRequest;
    NSMutableArray *drawedRouteLines;
    double _turnAngle;
    CGRect _routeComponentRect;
    CGRect _speedComponentRect;
    PointD _carCenterPoint;
    

    CGRect _turnArrowFrame;
    UITextField *_messageBoxTextField;
    ClockView *_clockView;
    SystemStatusView *_systemStatusView;
    
    UIImageView *_turnArrowImage;
    UIImageView *_currentLocationImage;

    SpeedView *_speedView;
    MessageBoxLabel *_messageBoxLabel;
    UILabel         *_debugMsgLabel;
    NSString *_lastPlayedSpeech;
    int _maxOutOfRouteLineCount;
    int _outOfRouteLineCount;
}

#pragma mark - Main

-(id) init
{
    self = [super init];
    if (self) {
        [self initSelf];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

-(id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // Initialization code
        [self initSelf];
        
    }
    
    return self;
}

-(void) initSelf
{
    
    self.isDebugDraw            = true;
    self.isDebugNormalLine      = false;
    self.isDebugRouteLineAngle  = false;
    
    
    msgRect.origin.x        = floor(480*0.1);
    msgRect.origin.y        = floor(320*0.15);
    msgRect.size.width      = floor(480*0.8);
    msgRect.size.height     = floor(320*0.4);
    

    routeDisplayBound               = [SystemManager lanscapeScreenRect];
    
    carImage = [UIImage imageNamed:@"Blue_car_marker"];
    
    _speedComponentRect.origin.x    = 0;
    _speedComponentRect.origin.y    = 0;
    _speedComponentRect.size.width  = 240;
    _speedComponentRect.size.height = [SystemManager lanscapeScreenRect].size.height;
    
    _routeComponentRect.origin.x    = _speedComponentRect.size.width;
    _routeComponentRect.origin.y    = 0;
    _routeComponentRect.size.width  = [SystemManager lanscapeScreenRect].size.width - _speedComponentRect.size.width;
    _routeComponentRect.size.height = [SystemManager lanscapeScreenRect].size.height;
   
    _carCenterPoint.x        = _routeComponentRect.size.width/2;
//    _carCenterPoint.y        = (_routeComponentRect.size.height/4)*3;
    _carCenterPoint.y        = 250;
    
    _maxOutOfRouteLineCount  = [SystemConfig getIntValue:CONFIG_MAX_OUT_OF_ROUTELINE_COUNT];
    [self addUIComponents];
    
    [SystemManager addDelegate:self];
    self.color      = [SystemConfig getUIColorValue:CONFIG_RN1_COLOR];
    

}

#pragma mark - Geo Calculation
#if 1
-(double) adjustAngle:(double)angle
{
    if(angle > M_PI+0.000001)
    {
        angle -= 2*M_PI;
    }
    else if(angle < -M_PI-0.000001)
    {
        angle += 2*M_PI;
    }
    
    return angle;
}

#else
-(double) adjustAngle:(double)angle
{
    if(angle >= 2*M_PI)
    {
        angle -= 2*M_PI;
    }
    else if(angle <= 0)
    {
        angle += 2*M_PI;
    }
    
    return angle;
}
#endif

-(void) autoSimulatorLocationUpdateStart
{
    if (nil == route || kRouteStatusCodeOk != route.status)
    {
        _isAutoSimulatorLocationUpdateStarted = FALSE;
        return;
    }
    
    _isAutoSimulatorLocationUpdateStarted = TRUE;
}

-(void) autoSimulatorLocationUpdateStop
{

    _isAutoSimulatorLocationUpdateStarted = FALSE;
}

-(void) downloadRequestStatusChange: (DownloadRequest*) downloadRequest
{
    if (downloadRequest == routeDownloadRequest)
        [self processRouteDownloadRequestStatusChange];
}


#pragma mark - Draw Functions

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [super drawRect:rect];
    
    /* draw background */
    [self drawBackground:context Rectangle:rect];
    
    /* draw debug message */
    if (YES == [SystemConfig getBoolValue:CONFIG_IS_DEBUG] && _messageBoxText.length > 0)
    {
        [self drawMessageBox:context Message:_messageBoxText];

        return;
    }

    if (nil == currentRouteLine)
    {
        return;
    }

    /* get draw point, can calculate offset */
    PointD tmpCarDrawPoint = [self getDrawPoint:carPoint];
    PointD startPoint  = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:currentRouteLine.startLocation]];
    xOffset = tmpCarDrawPoint.x - startPoint.x + _routeComponentRect.origin.x;

    /* draw route */
    [self drawRoute:context Rectangle:rect];
    
    /* draw turn message */
    if (GR_STATE_NAVIGATION == self.state)
    {
        [self drawTurnMessage:context];
    }
    
    /* reset ture image */
    _turnArrowImage.image = [self getTurnImage];

    /* draw debug information */
    if (YES == [SystemConfig getBoolValue:CONFIG_IS_DEBUG_ROUTE_DRAW])
    {
        [self drawCar:context];
        [self drawCurrentRouteLine:context];
        [self drawCarFootPrint:context];
        [self drawDebugMessage:context];
        [self drawRouteLabel:context];
    }
}


-(void) drawBackground:(CGContextRef) context Rectangle:(CGRect) rect
{
    
    // draw blackground
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 3.0);

    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    
    // draw screen frame
    CGContextAddRect(context, routeDisplayBound);
    CGContextStrokeRect(context, routeDisplayBound);
    
}


-(void) drawCar:(CGContextRef) context
{

    int size = 20;
    PointD normalPointStart;
    PointD normalPointEnd;
    PointD carOffset;
    CGRect carRect;
    
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    
    carRect.origin.x = _carCenterPoint.x - size + _routeComponentRect.origin.x;
    carRect.origin.y = _carCenterPoint.y - size;
    carRect.size.width = size*2;
    carRect.size.height = size*2;

    //    CGContextStrokeRect(context, carRect);
    

    
    if (self.isDebugNormalLine)
    {
        normalPointStart = routeStartPoint;
        
        normalPointEnd = routeStartPoint;
        normalPointEnd.y = 100;
        
        normalPointStart = [self getDrawPoint:normalPointStart];
        normalPointEnd = [self getDrawPoint:normalPointEnd];
        
        carOffset.x = _carCenterPoint.x - normalPointStart.x;
        carOffset.y = _carCenterPoint.y - normalPointStart.y;
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        
        CGContextSetLineWidth(context, 2.0);
        CGContextMoveToPoint(context, normalPointStart.x + xOffset + carOffset.x, normalPointStart.y + carOffset.y);
        CGContextAddLineToPoint(context, normalPointEnd.x + xOffset + carOffset.x, normalPointEnd.y + carOffset.y);
        CGContextStrokePath(context);
        
        
        normalPointEnd = routeStartPoint;
        normalPointEnd.y = -100;
        
        normalPointEnd = [self getDrawPoint:normalPointEnd];
        
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        
        CGContextSetLineWidth(context, 2.0);
        CGContextMoveToPoint(context, normalPointStart.x + xOffset + carOffset.x, normalPointStart.y + carOffset.y);
        CGContextAddLineToPoint(context, normalPointEnd.x + xOffset + carOffset.x, normalPointEnd.y + carOffset.y);
        CGContextStrokePath(context);
    }
    
}

-(void) drawCurrentRouteLine:(CGContextRef) context
{
    PointD curPoint;
    
    if(currentRouteLine == nil)
        return;
    
    CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextSetLineWidth(context, 5.0);
    
    curPoint = [self getDrawPoint:routeStartPoint];
    curPoint.x += xOffset;
    
    CGContextMoveToPoint(context, curPoint.x, curPoint.y);
    curPoint = [self getDrawPoint:routeEndPoint];
    curPoint.x += xOffset;
    CGContextAddLineToPoint(context, curPoint.x, curPoint.y);
    CGContextStrokePath(context);
    
}




-(void) drawTurnMessage:(CGContextRef) context
{
    RouteLine *nextStepRouteLine;
    
    _messageBoxLabel.text = @"";
    
    if(currentRouteLine != nil)
    {
        nextStepRouteLine = [route getNextStepFirstRouteLineByStepNo:currentRouteLine.stepNo CarLocation:currentCarLocation];
        
        if(nextStepRouteLine != nil)
        {
            NSString* text = [route getStepInstruction:nextStepRouteLine.stepNo];
            //[self drawMessageBox:context Message:[route getStepInstruction:nextStepRouteLine.stepNo]];
            _messageBoxLabel.text = [route getStepInstruction:nextStepRouteLine.stepNo];
            if(YES == [SystemConfig getBoolValue:CONFIG_IS_SPEECH] && FALSE == [audioPlayer isPlaying] )
            {
                [self playSpeech:text];
            }
        }
    
            
    }
    
    
}
-(void) drawRoute:(CGContextRef) context Rectangle:(CGRect) rect
{
    BOOL hasStartPoint;
    PointD startPoint;
    PointD endPoint;
    CGRect roundRect;
    CGRect routeRect = rect;
    CGRect endPointRect;
    int roundRectSize = 8;
    int currentStepNo = -1;
    NSMutableArray *stepPoint;
    RouteLine *tmpRouteLine;
    
    hasStartPoint = FALSE;
    routeRect = rect;
    stepPoint = [[NSMutableArray alloc] init];
    
    
    // draw route line
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);

    if (nil == drawedRouteLines)
    {
        drawedRouteLines = [[NSMutableArray alloc] initWithCapacity:0];
    }

    [drawedRouteLines removeAllObjects];

    CGContextSetFillColorWithColor(context, self.color.CGColor);
    for(RouteLine *rl in route.routeLines)
    {

        startPoint      = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:rl.startLocation]];
        endPoint        = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:rl.endLocation]];
        startPoint.x    += xOffset;
        endPoint.x      += xOffset;
        
        /* 1. current route line
         * 2. start point in the draw rect
         * 3. end point int the draw rect
         */
        if (rl == currentRouteLine                                          ||
            CGRectContainsPoint(routeRect, [GeoUtil getCGPoint:startPoint]) ||
            CGRectContainsPoint(routeRect, [GeoUtil getCGPoint:endPoint]))
        {
            if (FALSE == hasStartPoint)
            {
                CGContextMoveToPoint(context, startPoint.x, startPoint.y);
                hasStartPoint = TRUE;
            }
            
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
            [drawedRouteLines addObject:rl];
        }
    }
    
    CGContextStrokePath(context);
    
    tmpRouteLine = [route.routeLines objectAtIndex:0];
    startPoint      = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:tmpRouteLine.startLocation]];
    endPoint        = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:tmpRouteLine.endLocation]];
    startPoint.x    += xOffset;
    endPoint.x      += xOffset;
    
    if (CGRectContainsPoint(routeRect, [GeoUtil getCGPoint:startPoint]) ||
        CGRectContainsPoint(routeRect, [GeoUtil getCGPoint:endPoint]))
    {
        CGContextSetStrokeColorWithColor(context, _color.CGColor);
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(context, 4.0);
        
        endPointRect.origin.x = startPoint.x - 16;
        endPointRect.origin.y = startPoint.y - 16;
        endPointRect.size.width = 16*2;
        endPointRect.size.height = 16*2;
        CGContextFillEllipseInRect(context, endPointRect);
        CGContextStrokeEllipseInRect(context, endPointRect);

        CGContextSetFillColorWithColor(context, _color.CGColor);
        CGContextFillEllipseInRect(context, CGRectInset(endPointRect, 8, 8));
    }
#
    tmpRouteLine = [route.routeLines lastObject];
    startPoint      = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:tmpRouteLine.startLocation]];
    endPoint        = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:tmpRouteLine.endLocation]];
    startPoint.x    += xOffset;
    endPoint.x      += xOffset;
    
    if (CGRectContainsPoint(routeRect, [GeoUtil getCGPoint:startPoint]) ||
        CGRectContainsPoint(routeRect, [GeoUtil getCGPoint:endPoint]))
    {
        CGContextSetStrokeColorWithColor(context, _color.CGColor);
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(context, 4.0);
        
        endPointRect.origin.x = startPoint.x - 16;
        endPointRect.origin.y = startPoint.y - 16;
        endPointRect.size.width = 16*2;
        endPointRect.size.height = 16*2;
        CGContextFillEllipseInRect(context, endPointRect);
        CGContextStrokeEllipseInRect(context, endPointRect);
        
        CGContextSetFillColorWithColor(context, _color.CGColor);
        CGContextFillEllipseInRect(context, CGRectInset(endPointRect, 6, 6));
    }
    
    if (YES == [SystemConfig getBoolValue:CONFIG_IS_DEBUG_ROUTE_DRAW])
    {
    
        // add circle to the edge of step
        CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
        for(RouteLine *rl in drawedRouteLines)
        {
            startPoint  = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:rl.startLocation]];
            startPoint.x    += xOffset;
            if(currentStepNo != rl.stepNo)
            {
                currentStepNo = rl.stepNo;
                
                roundRect.origin.x = startPoint.x-roundRectSize/2;
                roundRect.origin.y = startPoint.y-roundRectSize/2;
                roundRect.size.width = roundRectSize;
                roundRect.size.height = roundRectSize;
                
            }
            CGContextAddEllipseInRect(context, roundRect);
            
        }
        CGContextStrokePath(context);
    
        
        // mark edge of route line by red circle
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        for(RouteLine *rl in drawedRouteLines)
        {
            startPoint      = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:rl.startLocation]];
            endPoint        = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:rl.endLocation]];
            startPoint.x    += xOffset;
            endPoint.x      += xOffset;
        
            roundRect.origin.x = startPoint.x-roundRectSize/2;
            roundRect.origin.y = startPoint.y-roundRectSize/2;
            roundRect.size.width = roundRectSize;
            roundRect.size.height = roundRectSize;
        
            CGContextAddEllipseInRect(context, roundRect);
        
        }
        CGContextFillPath(context);
    }

}

-(void) drawRouteLabel:(CGContextRef) context
{
    // Drawing code
    int i;
    PointD startPoint;
    PointD endPoint;
    CGRect routeLineLabelRect;
    NSString *routeLineLabel;
    RouteLine *tmpCurrentRouteLine;
    RouteLine *nextRouteLine;
    
    nextRouteLine = nil;
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    for(i=0; i<drawedRouteLines.count; i++)
    {
        tmpCurrentRouteLine = [drawedRouteLines objectAtIndex:i];
        if (i < drawedRouteLines.count-1)
        {
            nextRouteLine = [drawedRouteLines objectAtIndex:i+1];
        }
        
        startPoint  = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:tmpCurrentRouteLine.startLocation]];
        endPoint    = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:tmpCurrentRouteLine.endLocation]];
        
        startPoint.x    += xOffset;
        endPoint.x      += xOffset;
        
        startPoint.x = (startPoint.x + endPoint.x)/2;
        startPoint.y = (startPoint.y + endPoint.y)/2;
        routeLineLabelRect.origin.x = startPoint.x+15;
        routeLineLabelRect.origin.y = startPoint.y;
        routeLineLabelRect.size.width = 180;
        routeLineLabelRect.size.height = 20;
        

        routeLineLabel = [NSString stringWithFormat:@"%d %.0f, %.0f",
                          tmpCurrentRouteLine.no,
                          nextRouteLine == nil ? 0 :TO_ANGLE(tmpCurrentRouteLine.angle),
                          nextRouteLine == nil ? 0 :TO_ANGLE([tmpCurrentRouteLine getTurnAngle:nextRouteLine])
                        ];

        
        [routeLineLabel drawInRect:routeLineLabelRect withFont:[UIFont boldSystemFontOfSize:14.0]];

    }
}
-(void) drawCarFootPrint:(CGContextRef) context
{
    int i;
    PointD curPoint;
    CGRect rect;
    NSTextAlignment aligment;
    NSMutableArray* drawedPoint = [[NSMutableArray alloc] init];
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);

    for(i=0; i<carFootPrint.count; i++)
    {
        int size = 4;
        NSValue* v = [carFootPrint objectAtIndex:i];
        curPoint = [self getDrawPoint:[v PointDValue]];
        curPoint.x += xOffset;
        
        if (i == carFootPrint.count-1)
        {
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        }
        
        rect.origin.x = curPoint.x-size/2;
        rect.origin.y = curPoint.y-size/2;
        rect.size.width = size;
        rect.size.height = size;
        
        CGContextFillRect(context, rect);

        if (i%2 == 0)
        {
            rect.origin.x = curPoint.x-size/2+6;
            aligment = NSTextAlignmentLeft;
        }
        else
        {
           rect.origin.x = curPoint.x-size/2-26;
           aligment = NSTextAlignmentRight;
        }
        
        rect.origin.y = curPoint.y-size/2-6;
        rect.size.width = size+20;
        rect.size.height = size+4;
        
        NSString *num = [NSString stringWithFormat:@"%d", i];
        
        [num drawInRect:rect withFont:[UIFont boldSystemFontOfSize:10.0] lineBreakMode:NSLineBreakByCharWrapping alignment:aligment];
        
        [drawedPoint addObject:[NSValue valueWithPointD:curPoint]];
    }
}

-(void) drawDebugMessage:(CGContextRef) context
{
    int routeLineNo = currentRouteLine != nil ? currentRouteLine.no : -1;
    CGRect endPosText;
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    endPosText.origin.x = 8;
    endPosText.origin.y = 300;
    endPosText.size.width = 350;
    endPosText.size.height = 60;
    
    
    NSString *endText = [NSString stringWithFormat:@"Target:%.2f, Turn:%.2f, rno:%d, mem:%@", TO_ANGLE(targetAngle), TO_ANGLE(_turnAngle), routeLineNo, [SystemManager getUsedMemoryStr]];
    
    [endText drawInRect:endPosText withFont:[UIFont boldSystemFontOfSize:14.0]];
    
}
-(void) drawMessageBox:(CGContextRef) context Message:(NSString*) message
{
    CGRect rect                 = msgRect;
    CGRect actualMessageRect    = CGRectInset(msgRect, 10, 10);
    int radius = 8;
    int fontSize = 32;
    
    actualMessageRect = [self getFitSizeRect:actualMessageRect Message:message FontSize:&fontSize];
    
    rect.size.height = actualMessageRect.size.height + 10;
    
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius,
                    radius, M_PI, M_PI / 2, 1); //STS fixed
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius,
                            rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius,
                    rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius,
                    radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius,
                    -M_PI / 2, M_PI, 1);
    
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:0.9].CGColor);
    CGContextFillPath(context);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius,
                    radius, M_PI, M_PI / 2, 1); //STS fixed
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius,
                            rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius,
                    rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius,
                    radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius,
                    -M_PI / 2, M_PI, 1);
    
    CGContextSetLineWidth(context, 5.0);

    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, self.color.CGColor);

    [message drawInRect:actualMessageRect
               withFont:[UIFont boldSystemFontOfSize:fontSize]
          lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];

    
}

-(void) drawTurnArrow:(CGContextRef) context
{
    _turnArrowImage.image = [self getTurnImage];
#if 0
    UIImage *turnImage;
    CGSize size;
    
    turnImage   = [self getTurnImage];
    size        = turnImage.size;;

    [turnImage drawInRect:
     CGRectMake(_turnArrowFrame.origin.x + (_turnArrowFrame.size.width - size.width)/2,
                _turnArrowFrame.origin.y + (_turnArrowFrame.size.height - size.height)/2,
                size.width, size.height)];
#endif
}

-(void) dumpCarFootPrint
{
    for(NSValue* v in carFootPrint)
    {
        PointD p = [v PointDValue];
        mlogDebug(@"car foot print (%12.7f, %12.7f)", p.y, p.x);
    }
}
-(UIImage*) getCarImage{
    CGSize size = carImage.size;;
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // If this is commented out, image is returned as it is.
    CGContextRotateCTM (context, radians(1));
    
    [carImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}




-(PointD) getNextCarPoint
{
    PointD nextCarPoint = carPoint;
#if 0
    // x = ?
    if(true == isRouteLineMUndefind)
    {
        nextCarPoint.y += directionStep.y;
        nextCarPoint.x = routeStartPoint.x;
    }
    // y = ?
    else if(routeLineM == 0)
    {
        nextCarPoint.y = routeLineB;
        nextCarPoint.x += directionStep.x;
    }
    // y = mx+b;
    else
    {
        nextCarPoint.y += directionStep.y;
        nextCarPoint.x = (nextCarPoint.y - routeLineB)/routeLineM;
    }
#endif
    nextCarPoint.x += routeUnitVector.x*oneStep;
    nextCarPoint.y += routeUnitVector.y*oneStep;
    
    return nextCarPoint;
}

-(UIImage*) getTurnImage
{
    UIImage* turnImage;
    double turnAngle;

    turnAngle = TO_ANGLE(_turnAngle);
    
    // left 45: -67.5 ~ 22.5
    if (-67.5 <= turnAngle && turnAngle <= -22.5)
    {
        turnImage = [UIImage imageNamed:@"turn_left45"];
    }
    // left 90
    else if (turnAngle <= -67.5)
    {
        turnImage = [UIImage imageNamed:@"turn_left90"];
    }
    // right 45: 22.5 ~ 67.5
    else if (22.5 <= turnAngle && turnAngle <= 67.5)
    {
        turnImage = [UIImage imageNamed:@"turn_right45"];
    }
    // right 90
    else if (turnAngle >= 67.5)
    {
        turnImage = [UIImage imageNamed:@"turn_right90"];
    }
    // straight: -22.5 ~ 22.5
    else
    {
        turnImage = [UIImage imageNamed:@"turn_straight"];
    }
    
    return [turnImage imageTintedWithColor:_color];
}


-(void) generateRoutePoints
{
    double widthRatio;
    double heightRatio;
    
    if (nil == route )
    {
        mlogWarning(@"Cannot generate route point, route is nil");
        return;
    }
        
    if ( kGoogleJsonStatus_Ok != route.status )
    {
        mlogWarning(@"Cannot generate route point, route status: %d", route.status);
        return;
    }
    
    
    routePoints = [[NSMutableArray alloc] initWithArray:[route getRoutePolyLinePointD]];
    
    distanceWidth   = 0;
    distanceHeight  = 0;
    widthRatio      = 0;
    heightRatio     = 0;
    
    
    leftMost = [[routePoints objectAtIndex:0] PointDValue];
    rightMost = leftMost;
    topMost = leftMost;
    bottomMost = leftMost;
    
    //    for(NSArray *stepPolyPoints in routePoints)
    {
        for(NSValue *tmpValue in routePoints)
        {
            PointD tmpLocation = [tmpValue PointDValue];
            if (leftMost.x >= tmpLocation.x)
            {
                leftMost = tmpLocation;
            }
            
            if (rightMost.x <= tmpLocation.x)
            {
                rightMost = tmpLocation;
            }
            
            if (topMost.y <= tmpLocation.y)
            {
                topMost = tmpLocation;
            }
            
            if (bottomMost.y >= tmpLocation.y)
            {
                bottomMost = tmpLocation;
            }
            
        }
    }
    
    
    widthRatio = 320.0/fabs((leftMost.x - rightMost.x));
    heightRatio = 480.0/fabs((topMost.y - topMost.y));
    
    fitRatio = MIN(widthRatio, heightRatio);
#if 0
    logfns("%.5f\n", fabs(-0.1));
    logfns("%.5f\n", (fabs(topMost.y- bottomMost.y)*1.0));
    logfns("%.5f\n", (fabs(rightMost.x - leftMost.x)*1.0));
    
    logfns("leftMost     %9.5f\n", leftMost.x);
    logfns("rightMost    %9.5f\n", rightMost.x);
    logfns("topMost      %9.5f\n", topMost.y);
    logfns("bottomMost   %9.5f\n", bottomMost.y);
    
    
    
    //    ratio = fitRatio;
    logfns("fitratio: %.2f\n", fitRatio);
    logfns("   ratio: %.2f\n", ratio);
#endif
    
}

-(PointD) getRawDrawPoint:(PointD) p
{
    PointD tmpPoint;
    PointD translatedPoint;
    
    // let carPoint be the origin
    tmpPoint.x = (p.x - leftMost.x)*ratio;
    tmpPoint.y = (p.y - topMost.y)*ratio;
    
    translatedPoint.y = (-1)*translatedPoint.y;
    
    return translatedPoint;
    
}

-(CGRect) getFitSizeRect:(CGRect) rect Message:(NSString*) message FontSize:(int*) fontSize
{
    int tmpFontSize = *fontSize;
    CGSize actualSize;
    UIFont *font;
    NSString* sampleText = @"OK";
    double oneLineHeight = 0;
    int currentLineNo = 1;
    CGRect resultRect;
    
    
    font = [UIFont boldSystemFontOfSize:tmpFontSize];
    actualSize = [sampleText sizeWithFont:font constrainedToSize:rect.size lineBreakMode:NSLineBreakByClipping];
    oneLineHeight = actualSize.height;
    while (tmpFontSize >= 24 && currentLineNo <=2)
    {
        font = [UIFont boldSystemFontOfSize:tmpFontSize];
        actualSize = [message sizeWithFont:font constrainedToSize:rect.size lineBreakMode:NSLineBreakByClipping];

        if (actualSize.width <= rect.size.width && actualSize.height <= oneLineHeight*currentLineNo)
            break;
        
        if (tmpFontSize == 24)
            currentLineNo++;
        
        tmpFontSize--;
    }
    
    *fontSize   = tmpFontSize;
    resultRect  = rect;
    resultRect.size = actualSize;
    
    if (currentLineNo > 1)
        resultRect.size.height += (currentLineNo-1)*oneLineHeight;

    return resultRect;
}

-(int) getFitFontSize:(CGRect) rect Message:(NSString*) message
{
    int fontSize = 32;
    CGSize actualSize;
    UIFont *font;
    NSString* sampleText = @"OK";
    double oneLineHeight = 0;

    font = [UIFont boldSystemFontOfSize:fontSize];
    actualSize = [sampleText sizeWithFont:font constrainedToSize:rect.size lineBreakMode:NSLineBreakByClipping];
    oneLineHeight = actualSize.height;
    while (fontSize > 24)
    {
        
        font = [UIFont boldSystemFontOfSize:fontSize];
        actualSize = [message sizeWithFont:font constrainedToSize:rect.size lineBreakMode:NSLineBreakByClipping];
        if (actualSize.width <= rect.size.width && actualSize.height <= oneLineHeight)
            break;
        fontSize--;
    }
    
    mlogDebug(@"font size: %d\n", fontSize);
    return fontSize;
}
-(PointD) getDrawPoint:(PointD)p
{
    
    PointD tmpPoint;
    PointD translatedPoint;
    
    
    // step 1: rotate
    // let carPoint be the origin
    tmpPoint.x = (p.x - carPoint.x);
    tmpPoint.y = (p.y - carPoint.y);
    
    
    // rotate and move back
    //    translatedPoint.x = tmpPoint.x*cos(directionAngle) - tmpPoint.y*sin(directionAngle) + carPoint.x;
    //    translatedPoint.y = tmpPoint.x*sin(directionAngle) + tmpPoint.y*cos(directionAngle) + carPoint.y;
    
    translatedPoint.x = tmpPoint.x*cos(currentDrawAngle) - tmpPoint.y*sin(currentDrawAngle) + carPoint.x;
    translatedPoint.y = tmpPoint.x*sin(currentDrawAngle) + tmpPoint.y*cos(currentDrawAngle) + carPoint.y;
    
    
    //    printf("translatedPoint (%.8f, %.8f)\n", translatedPoint.x, translatedPoint.y);
    
    // step2: scale and move to car screen point.
    
    translatedPoint.x = translatedPoint.x*ratio + toScreenOffset.x;
    translatedPoint.y = translatedPoint.y*ratio + toScreenOffset.y;
    
    //    printf("translatedPoint (%.8f, %.8f)\n", translatedPoint.x, translatedPoint.y);
    
    // step3: mirror around the y axis of car center point
    // 1. move to origin (-carCenterPoint)
    // 2. mirror, y=-y
    // 3. move back (+carCenterPoint)
    translatedPoint.y = _carCenterPoint.y - translatedPoint.y + _carCenterPoint.y;
    
    
    //    printf("     draw point (%.5f, %.5f) - > (%.0f, %.0f)\n\n", p.x, p.y, translatedPoint.x, translatedPoint.y);
    
    return translatedPoint;
}

#pragma mark - Navigation
-(void) initNewRouteNavigation
{
    ratio = 1;
    [self generateRoutePoints];
    
    oneStep                 = 0.00013;
    
    targetAngle             = 0;
    screenSize.width        = 480;
    screenSize.height       = 320;

    
    carPoint.x              = 0;
    carPoint.y              = 0;
    locationIndex           = 0;
    routeLineM              = 0;
    routeLineB              = 0;
    isRouteLineMUndefind    = false;
    ratio                   = 452000;
    angleRotateStep         = 0.1;
    rotateInterval          = 0.1;
    
    [self nextRouteLine];
    carPoint = routeStartPoint;
    [self updateTranslationConstant];
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0]];
    currentStep = 0;
    carFootPrint = [NSMutableArray arrayWithCapacity:0];
    
    rotateTimer = [NSTimer scheduledTimerWithTimeInterval:rotateInterval target:self selector:@selector(rotateAngle:) userInfo:nil repeats:YES];
    
    if (YES == [SystemConfig getBoolValue:CONFIG_IS_SPEECH])
    {
        [NaviQueryManager downloadSpeech:route];
    }
    
    [self updateCarLocation:((RouteLine*)[route.routeLines objectAtIndex:0]).startLocation];
    
    [LocationManager setRoute:route];
    
    if (YES == [SystemConfig getBoolValue:CONFIG_IS_LOCATION_SIMULATOR])
    {
        [LocationManager triggerLocationUpdate];
    }
    
    
    // configure debug option
    _isAutoSimulatorLocationUpdateStarted   = FALSE;
    _outOfRouteLineCount                    = 0;

    [self setNeedsDisplay];

}


-(void) nextRouteLine
{
    PointD tmpPoint;
    routeStartPoint = [[routePoints objectAtIndex:locationIndex] PointDValue];
    routeEndPoint = [[routePoints objectAtIndex:locationIndex+1] PointDValue];
    
    // x = ??
    if((routeStartPoint.x - routeEndPoint.x) == 0)
    {
        routeLineM = 0;
        isRouteLineMUndefind = true;
    }
    // y = mx+b
    else
    {
        routeLineM = (routeStartPoint.y - routeEndPoint.y)/(routeStartPoint.x - routeEndPoint.x);
        routeLineB = routeEndPoint.y - routeLineM*routeEndPoint.x;
        isRouteLineMUndefind = false;
    }
    
    tmpPoint.x = routeStartPoint.x;
    tmpPoint.y = routeStartPoint.y;
    tmpPoint.y++;

    
    if(tmpPoint.x > routeEndPoint.x)
    {
        targetAngle *= -1;
    }

    locationIndex++;
    if(locationIndex >= routePoints.count -1)
        locationIndex = 0;
  
    routeDistance = [GeoUtil getLength:routeStartPoint ToPoint:routeEndPoint];
    routeUnitVector.x = (routeEndPoint.x - routeStartPoint.x)/routeDistance;
    routeUnitVector.y = (routeEndPoint.y - routeStartPoint.y)/routeDistance;
}

-(void) playSpeech:(NSString*) text
{
    /* never play speech in simulator mode */
    if (NO == [SystemConfig getBoolValue:CONFIG_IS_SPEECH])
        return;
    
    /* if played before, just skip it */
    
    if (YES == [_lastPlayedSpeech isEqualToString:text])
         return;
    @try
    {
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mp3", [SystemManager getPath:kSystemManager_Path_Speech], text]];
        
        _lastPlayedSpeech = [NSString stringWithString:text];
        
        mlogDebug(@"play %@, %@\n", text, [NSString stringWithFormat:@"%@/%@.mp3", [SystemManager getPath:kSystemManager_Path_Speech], text]);
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        audioPlayer.numberOfLoops = 0;
        [audioPlayer prepareToPlay];
        [audioPlayer play];

    }
    @catch (NSException *exception)
    {
        mlogException(exception);
    }


}

-(void) processRouteDownloadRequestStatusChange
{
    bool isFail = true;
    bool updateStatus = false;
    /* search place finished */
    if (routeDownloadRequest.status == kDownloadStatus_Finished)
    {
        [self startRouteNavigation];
    }
    /* search failed */
    else if(routeDownloadRequest.status == kDownloadStatus_DownloadFail)
    {
        updateStatus = true;
    }
    
    if (true == updateStatus && true == isFail)
    {
        
    }
    
}

-(void) triggerLocationUpdate
{
    if (currentDrawAngle == targetAngle)
    {

    }
    else
    {
        [self rotateAngle:nil];
    }
}

-(void) rotateAngle:(NSTimer *)theTimer
{
    if(true == [self updateCurrentDrawAngle])
    {
        [self setNeedsDisplay];
    }
}


-(void) startRouteNavigation
{
    GoogleJsonStatus status = [GoogleJson getStatus:routeDownloadRequest.filePath];
    if ( kGoogleJsonStatus_Ok == status)
    {
        route = [Route parseJson:routeDownloadRequest.filePath];
        if (nil != route)
        {
            [self initNewRouteNavigation];
        }
    }

    return;
}

-(void) startRouteNavigationFrom:(Place*) s To:(Place*) e
{
    mlogInfo(@"Start: %@, To: %@", s, e);
    GoogleJsonStatus status;
    if (nil == s || nil == e)
    {
        mlogError(@"No start or end place");
        return;
    }
    
    routeStartPlace = s;
    routeEndPlace   = e;

    routeDownloadRequest = [NaviQueryManager getRouteDownloadRequestFrom:routeStartPlace.coordinate To:routeEndPlace.coordinate];
    mlogDebug(@"route download request file: %@", routeDownloadRequest.filePath);
    status = [GoogleJson getStatus:routeDownloadRequest.filePath];
    
    if (kGoogleJsonStatus_Ok == status)
    {
        route                   = [Route parseJson:routeDownloadRequest.filePath];
        routeDownloadRequest    = nil;
        if (nil != route)
        {

            [self initNewRouteNavigation];
        }
    }
    else
    {
        [self planRoute];
    }
    
}

-(void) replanRoute
{
    mlogDebug(@"Re-Route by current place\n");
    
    routeStartPlace = [LocationManager currentPlace];
    [self planRoute];
}

-(void) planRoute
{
    if (nil != routeStartPlace && nil != routeEndPlace)
    {
        if (YES == [routeStartPlace isNullPlace])
        {
            [self sendEvent:GR_EVENT_GPS_NO_SIGNAL];
        }
        else if (![routeStartPlace isCoordinateEqualTo:routeEndPlace])
        {
            routeDownloadRequest = [NaviQueryManager
                                    getRouteDownloadRequestFrom:routeStartPlace.coordinate
                                    To:routeEndPlace.coordinate];
            routeDownloadRequest.delegate = self;
            [NaviQueryManager download:routeDownloadRequest];
        }
        else
        {
            _messageBoxLabel.text = @"route start place and end place are the same";
//            self.state = state_unknown;
        }
    }
    else
    {
        _messageBoxLabel.text = @"start place or end place error";
//        self.state = state_unknown;
    }
}


#pragma mark - Location Update
-(void) updateTranslationConstant
{
    toScreenOffset.x = _carCenterPoint.x - carPoint.x*ratio;
    toScreenOffset.y = _carCenterPoint.y - carPoint.y*ratio;
    
    //    printf("toScreenOffset (%.8f, %.8f)\n", toScreenOffset.x, toScreenOffset.y);
}

-(void) updateCarLocation:(CLLocationCoordinate2D) newCarLocation
{
//    mlogDebug(@"update car location: %.8f, %.8f\n", newCarLocation.latitude, newCarLocation.longitude);
    PointD nextCarPoint;
    currentCarLocation = newCarLocation;
    nextCarPoint.x = newCarLocation.longitude;
    nextCarPoint.y = newCarLocation.latitude;
    carPoint = nextCarPoint;
    [carFootPrint addObject:[NSValue valueWithPointD:carPoint]];
    [self updateTranslationConstant];

    currentRouteLine = [route findClosestRouteLineByLocation:currentCarLocation LastRouteLine:currentRouteLine];
    
    if(currentRouteLine != nil)
    {
        routeStartPoint = [GeoUtil makePointDFromCLLocationCoordinate2D:currentRouteLine.startLocation];
        routeEndPoint   = [GeoUtil makePointDFromCLLocationCoordinate2D:currentRouteLine.endLocation];
        targetAngle     = [route getCorrectedTargetAngle:currentRouteLine.no distance:[SystemConfig getDoubleValue:CONFIG_TARGET_ANGLE_DISTANCE]];
        _turnAngle      = [route getAngleFromCLLocationCoordinate2D:newCarLocation routeLineNo:currentRouteLine.no withInDistance:[SystemConfig getDoubleValue:CONFIG_TURN_ANGLE_DISTANCE]];
        _outOfRouteLineCount = 0;
        
        [self sendEvent:GR_EVENT_GPS_READY];
    }
    else
    {
        _turnAngle      = 0;
        _outOfRouteLineCount++;
        if (_outOfRouteLineCount < _maxOutOfRouteLineCount)
        {
            [self sendEvent:GR_EVENT_GPS_READY];
        }
        else
        {
            [self replanRoute];
        }
    }
    
    

    
    
    
}

#pragma location update

#if 1

-(bool) updateCurrentDrawAngle
{
    bool reverseDirection = false;
    double angleOffset = fabs(currentDrawAngle - targetAngle);
    double turnAngle;
    
    /* if angle offset > 180 || angle offset < -180
     then turn right + becomes turn left - and
     turn left - becomes turn right +
     */
    
    angleRotateStep = (10/180.0) *M_PI;
    
    reverseDirection = angleOffset > (M_PI) ? true:false;
    
    if (currentDrawAngle == targetAngle)
        return false;
    
    /* should be turn right + */
    if(currentDrawAngle < targetAngle)
    {
        turnAngle = angleOffset;
        /* become turn left - */
        if (true == reverseDirection)
            turnAngle = (-1) * (2*M_PI - turnAngle);
    }
    /* should be turn left - */
    else
    {
        turnAngle = (-1) * angleOffset;
        /* becomes turn right + */
        if (true == reverseDirection)
            turnAngle = 2*M_PI + turnAngle;
    }
    
//    mlogDebug(@"cur angle: %.0f, directionAngle: %.0f, turnAngle:%.0f angleOffset:%.0f, step:%.0f\n",
//           TO_ANGLE(currentDrawAngle),
//           TO_ANGLE(targetAngle),
//           TO_ANGLE(turnAngle),
//           TO_ANGLE(angleOffset),
//           TO_ANGLE(angleRotateStep)
//           );
    
    
    if(fabs(turnAngle) <= angleRotateStep)
    {
        currentDrawAngle = targetAngle;
    }
    else
    {
        if (turnAngle > 0)
        {
            currentDrawAngle += angleRotateStep;
        }
        else
        {
            currentDrawAngle -= angleRotateStep;
        }
    }
    
//    mlogDebug(@"cur angle: %.0f, directionAngle: %.0f, turnAngle:%.0f angleOffset:%.0f\n",
//           TO_ANGLE(currentDrawAngle),
//           TO_ANGLE(targetAngle),
//           TO_ANGLE(turnAngle),
//           TO_ANGLE(angleOffset)
//           );
    
    
    currentDrawAngle = [self adjustAngle:currentDrawAngle];
    
    
    return true;
}

#else
-(bool) updateCurrentDrawAngle
{
    int reverseDirection = 1;
    double angleOffset = fabs(currentDrawAngle - targetAngle);
    
    
    /* if angle offset > 180 || angle offset < -180
     then turn right + becomes turn left - and
     turn left - becomes turn right +
     */
    reverseDirection = angleOffset > (M_PI)? (-1):(1);
    
    
    if(angleOffset == 0 || angleOffset == 2*M_PI)
        return false;
    
    mlogDebug(@"cur angle: %.0f, directionAngle: %.0f, angleOffset:%.0f\n", TO_ANGLE(currentDrawAngle), TO_ANGLE(targetAngle), TO_ANGLE(angleOffset));
    
    if(angleOffset <= angleRotateStep)
        currentDrawAngle = targetAngle;
    else
    {
        /* should be turn right + */
        if(currentDrawAngle < targetAngle)
        {
            currentDrawAngle = currentDrawAngle + reverseDirection*angleRotateStep;
            
        }
        /* should be turn left - */
        else
        {
            currentDrawAngle = currentDrawAngle - reverseDirection*angleRotateStep;
        }
    }
    
    currentDrawAngle = [self adjustAngle:currentDrawAngle];
    
    return true;
}

-(bool) updateCurrentDrawAngle
{
    double angleOffset = fabs(currentDrawAngle - targetAngle);
    double direction = 1;
    
    
    if(angleOffset <= angleRotateStep)
    {
        if (currentDrawAngle != targetAngle)
        {
            mlogDebug(@"cur angle: %.0f, directionAngle: %.0f, angleOffset:%.0f\n", TO_ANGLE(currentDrawAngle), TO_ANGLE(targetAngle), TO_ANGLE(angleOffset));
        }
        currentDrawAngle = targetAngle;

        return false;
    }
    
    mlogDebug(@"cur angle: %.0f, directionAngle: %.0f, angleOffset:%.0f\n", TO_ANGLE(currentDrawAngle), TO_ANGLE(targetAngle), TO_ANGLE(angleOffset));
    
    if (currentDrawAngle >= targetAngle)
    {
        direction = -1;
    }
    
    if (angleOffset <= M_PI)
    {
        currentDrawAngle += direction*angleRotateStep;
    }
    else
    {
        currentDrawAngle -= direction*angleRotateStep;
    }
    
    currentDrawAngle = [self adjustAngle:currentDrawAngle];
    
    return true;
}
#endif


-(void) locationManager:(LocationManager *)locationManager update:(CLLocationCoordinate2D)location speed:(double)speed distance:(int)distance heading:(double)heading
{
    currentStep++;
//    mlogDebug(@"location update (%.7f, %.7f), step: %d", location.latitude, location.longitude, currentStep);
    
    [self updateCarLocation:location];
    [self setNeedsDisplay];
//    mlogDebug(@" current route, (%.7f, %.7f) - > (%.7f, %.7f), step: %d\n", routeStartPoint.y, routeStartPoint.x, routeEndPoint.y, routeEndPoint.x, locationIndex);
    
    _debugMsgLabel.text = [NSString stringWithFormat:@"%.8f, %.8f, %.1f, %.1f",
                               location.latitude,
                               location.longitude,
                               speed,
                               heading
                               ];
}


#pragma mark - UI Control
-(void) addUIComponents
{

    _clockView                      = [[ClockView alloc] initWithFrame:CGRectMake(8, 60, 120, 50)];
    _clockView.backgroundColor      = [UIColor clearColor];
    _clockView.opaque               = TRUE;
    _systemStatusView               = [[SystemStatusView alloc] initWithFrame:CGRectMake(0, 0, 180, 50)];
    _systemStatusView.opaque        = FALSE;

    _turnArrowImage                 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"turn_right45.png"]];
    _turnArrowFrame                 = CGRectMake(40, 170, 128, 128);
    _turnArrowImage.frame           = _turnArrowFrame;

    _turnArrowImage.contentMode     = UIViewContentModeScaleAspectFit;
    _currentLocationImage           = [[UIImageView alloc] initWithFrame:
                                       CGRectMake(_carCenterPoint.x + _routeComponentRect.origin.x-15, _carCenterPoint.y-15, 30, 30)];

    _currentLocationImage.image     = [[UIImage imageNamed:@"route_current_location.png"] imageTintedWithColor:[UIColor redColor]];
    _turnArrowImage.contentMode     = UIViewContentModeScaleAspectFit;
    
    _speedView                      = [[SpeedView alloc] initWithFrame:CGRectMake(8, 100, 150, 50)];
    
    _messageBoxLabel                = [[MessageBoxLabel alloc] initWithFrame:
                                       CGRectMake(30, 40, [SystemManager lanscapeScreenRect].size.width - 60, 161)];
    _debugMsgLabel                  = [[UILabel alloc] init];
    _debugMsgLabel.text             = @"debug msg";
    _debugMsgLabel.textColor        = [UIColor whiteColor];
    _debugMsgLabel.backgroundColor  = [UIColor clearColor];
    _debugMsgLabel.frame            = CGRectMake(8, 280, 480, 20);
    [_clockView update];

    
    [self addSubview:_turnArrowImage];
    [self addSubview:_systemStatusView];
    [self addSubview:_clockView];
    [self addSubview:_currentLocationImage];
    [self addSubview:_speedView];
    [self addSubview:_messageBoxLabel];
    [self addSubview:_debugMsgLabel];

    
}

-(void) active
{
    _lastPlayedSpeech         = nil;
    [_systemStatusView active];
    [_clockView active];
    [_speedView active];
    
    [LocationManager addDelegate:self];

    _debugMsgLabel.hidden = ![SystemConfig getBoolValue:CONFIG_IS_DEBUG];
    self.isNetwork  = [SystemManager getNetworkStatus] > 0;
    self.isGps      = [SystemManager getGpsStatus] > 0;
    
//    self.isDebugRouteLineAngle  = TRUE;
//    self.isDebugNormalLine      = TRUE;
    
}

-(void) inactive
{
    [LocationManager removeDelegate:self];
    [_systemStatusView inactive];
    [_clockView inactive];
    [_speedView inactive];
}

-(void) update
{
    [_systemStatusView update];
}

#pragma mark - property

-(void) setIsNetwork:(BOOL)isNetwork
{
    _isNetwork = isNetwork;

    if (NO == _isNetwork)
    {
    
        [self sendEvent:GR_EVENT_NETWORK_NO_SIGNAL];
    }
    
    [self setNeedsDisplay];
}

-(void) setIsGps:(BOOL)isGps
{

    _isGps = isGps;
    [self sendEvent:GR_EVENT_GPS_NO_SIGNAL];
    [self setNeedsDisplay];
}

-(void) setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    _speedView.isSpeedUnitMph = isSpeedUnitMph;
    
}

-(void) setIsHud:(BOOL)isHud
{
    _isHud = isHud;
    
    if(TRUE == _isHud)
    {
        self.transform = CGAffineTransformMakeScale(1,-1);
    }
    else
    {
        self.transform = CGAffineTransformMakeScale(1,1);
    }
}

-(void) setColor:(UIColor *)color
{
    
    _color                      = color;
    _systemStatusView.color     = _color;
    _clockView.color            = _color;
    _speedView.color            = _color;
    _messageBoxLabel.color      = _color;
    _turnArrowImage.image       = [_turnArrowImage.image   imageTintedWithColor:_color];
    
    [self setNeedsDisplay];
}

-(void) setMessageBoxText:(NSString *)messageBoxText
{
    //    _messageBoxText = messageBoxText;
    _messageBoxLabel.text = messageBoxText;
    //    [self setNeedsDisplay];
}


#pragma mark -- SystemManage Monitor
-(void) networkStatusChangeWifi:(float) wifiStatus threeG:(float) threeGStatus
{
    self.isNetwork = (wifiStatus + threeGStatus > 0) ? YES:NO;

}
-(void) gpsStatusChange:(float) status
{
    self.isGps = status > 0 ? YES:NO;
}


#pragma mark -- event State management

-(BOOL) checkGPS
{

    return TRUE;
}

-(BOOL) checkNetwork
{
    return TRUE;
}

-(BOOL) checkRouteDestination
{
    
    return TRUE;
}


-(void) lookupState
{
    if (NO == self.checkGPS)
    {
        [self sendEvent:GR_EVENT_GPS_NO_SIGNAL];
    }
    else if (NO == self.checkNetwork)
    {
        [self sendEvent:GR_EVENT_NETWORK_NO_SIGNAL];
    }
    else if (NO == self.checkRouteDestination)
    {
        [self sendEvent:GR_EVENT_LOCATION_LOST];
    }
    else
    {
        [self sendEvent:GR_EVENT_ALL_READY];
    }
}


-(void) sendEvent:(GR_EVENT) event
{
    switch (event)
    {
        case GR_EVENT_GPS_NO_SIGNAL:
            self.state = GR_STATE_GPS_NO_SIGNAL;
            break;
        case GR_EVENT_NETWORK_NO_SIGNAL:
            self.state = GR_STATE_NETWORK_NO_SIGNAL;
            break;
        case GR_EVENT_ROUTE_DESTINATION_ERROR:
            self.state = GR_STATE_ROUTE_DESTINATION_ERROR;
            break;
        case GR_EVENT_ARRIVAL:
            self.state = GR_STATE_ARRIVAL;
            break;
        case GR_EVENT_GPS_READY:
        case GR_EVENT_NETWORK_READY:
        case GR_EVENT_LOCATION_LOST:
        case GR_EVENT_VIEW_DISAPPEAR:
            self.state = GR_STATE_LOOKUP;
            break;
        case GR_EVENT_ALL_READY:
            self.state = GR_STATE_INIT == self.state ? GR_STATE_ROUTE_PLANNING:GR_STATE_ROUTE_REPLANNING;
            break;
    }
}

-(void) setState:(GR_STATE)state
{
    switch (state)
    {
        case GR_STATE_INIT:
            _messageBoxLabel.text = @"";
            break;
            
    }
}

@end
