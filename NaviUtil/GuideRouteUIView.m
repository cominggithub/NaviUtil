
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
#import "RouteView.h"
#import "RouteTrack.h"
#import "CoordinateTranslator.h"
#import "LocationUpdateEvent.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"


#define radians(degrees) (degrees * M_PI/180)
#define ARRIVAL_REGION 5
#define ROUTE_LINE_WIDTH 20
#define ROUTE_LINE_RECT_SIZE 24
#define MESSAGE_BOX_DISPLAY_TIME_MIN 1
#define MAP_RATIO 32000

@implementation GuideRouteUIView
{
    Route*                  route;
    DownloadRequest         *routeDownloadRequest;
    NSMutableArray          *drawedRouteLines;
    
    double                  _turnAngle;         /* turn angle in route */
    double                  targetAngle;        /* angle to rotate the map */
    double                  carTargetAngle;     /* angle to rotate car */
    double                  currentDrawAngle;   /* current angle of the map */
    
    CGRect                  _routeComponentRect;
    CGRect                  speedComponentRect;
    CGPoint                 carScreenCenterPoint;     // screen center point, x,y
    
    CGPoint                 carProjectedPoint;          // car projected point
    CGPoint                 carDrawPoint;      // car draw pint
    CGPoint                 projectionToScreenOffset;     // toScreenOffset


    CGRect                  turnArrowFrame;

    ClockView               *clockView;
    SystemStatusView        *systemStatusView;
    SpeedView               *speedView;
    RouteView               *routeView;
    
    UIImageView             *turnArrowImage;
    UIImageView             *currentLocationImage;


    MessageBoxLabel         *messageBoxLabel;
    UILabel                 *debugMsgLabel;
    NSString                *lastPlayedSpeech;
    int                     maxOutOfRouteLineCount;
    int                     outOfRouteLineCount;
    CLLocationCoordinate2D  endRouteLineEndPoint;
    float                   distanceFromCarInitToRouteStart;
    BOOL                    hasMessage;

    NSString                *pendingMessage;
    UITextField             *messageBoxTextField;
    NSDate                  *lastUpdateMessageTime;
    GR_EVENT                lastEvent;
    RouteLine               *lastRouteLine;
    Place                   *lastFailedRouteStartPlace;
    
    CLLocationCoordinate2D currentCarLocation;
    CLLocationCoordinate2D lastCarLocation;
    CLLocationCoordinate2D lastCarLocationForCarAngle;
    
    BOOL                    isSimulateSlowWifi;
    int                     planRouteCount;
    NSDate                  *lastValidGPSSignalTime;
    NSDate                  *lastGPSSignalTime;
    NSDate                  *lastValidRouteLineTime;
    BOOL                    isOutOfRoute;
    long                    refreshCount;
    
    NSDateFormatter         *dateFormattor;
    NSTimer                 *rotateTimer;
    NSTimer                 *routePlanTimer;
    NSTimer                 *changeMessageTimer;
    NaviState               *naviState;
    CarStatus               *carStatus;
    double                  distanceToNextStep;
    double                  timeToNextStep;
    double                  distanceToRouteLine;
    RouteTrack              *routeTrack;
    
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
    speedComponentRect.origin.x     = 0;
    speedComponentRect.origin.y     = 0;
    speedComponentRect.size.width   = 240;
    speedComponentRect.size.height  = [SystemManager lanscapeScreenRect].size.height;
    
    _routeComponentRect.origin.x    = speedComponentRect.size.width;
    _routeComponentRect.origin.y    = 0;
    _routeComponentRect.size.width  = [SystemManager lanscapeScreenRect].size.width - speedComponentRect.size.width;
    _routeComponentRect.size.height = [SystemManager lanscapeScreenRect].size.height;
   
    carScreenCenterPoint.x                = _routeComponentRect.size.width/2;
    carScreenCenterPoint.y                = 250;
    
    hasMessage                      = FALSE;
    pendingMessage                  = @"";
    lastFailedRouteStartPlace       = nil;
    
    lastValidGPSSignalTime          = nil;
    lastGPSSignalTime               = nil;
    lastValidRouteLineTime          = nil;
    dateFormattor                   = [[NSDateFormatter alloc] init];
    [dateFormattor setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    maxOutOfRouteLineCount  = [SystemConfig getIntValue:CONFIG_MAX_OUT_OF_ROUTELINE_COUNT];
    [self addUIComponents];
    
    [SystemManager addDelegate:self];
    self.color      = [SystemConfig getUIColorValue:CONFIG_RN1_COLOR];
    
    endRouteLineEndPoint = CLLocationCoordinate2DMake(0, 0);

#if DEBUG
    isSimulateSlowWifi  = TRUE;
#else
    isSimulateSlowWifi  = FALSE;
#endif
    planRouteCount      = 0;
    
    naviState           = [[NaviState alloc] init];
    naviState.delegate  = self;
    carStatus           = [[CarStatus alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLocationUpdateEvent:)
                                                 name:LOCATION_MANAGER_LOCATION_UPDATE_EVENT
                                               object:nil];
    

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
    if (YES == [SystemConfig getBoolValue:CONFIG_H_IS_DEBUG] && _messageBoxText.length > 0)
    {
        [self drawMessageBox:context Message:_messageBoxText];

        return;
    }

    if (nil == currentRouteLine)
    {
        return;
    }

    /* get draw point, can calculate offset */

    CGPoint cstartPoint = [self getDrawCGPoint:currentRouteLine.startProjectedPoint];
    xOffset = carDrawPoint.x - cstartPoint.x + _routeComponentRect.origin.x;

    /* draw route */
    [self drawRoute:context Rectangle:rect];
    
    /* draw turn message */
    if (GR_STATE_NAVIGATION == naviState.state)
    {
        [self drawTurnMessage:context];
    }
    
    /* reset ture image */
    turnArrowImage.image = [self getTurnImage];

    /* draw debug information */
    if (YES == [SystemConfig getBoolValue:CONFIG_H_IS_DEBUG_ROUTE_DRAW])
    {
        [self drawCurrentRouteLine:context];
        [self drawCarFootPrint:context];
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

-(void) drawRoute:(CGContextRef) context Rectangle:(CGRect) rect
{
    int i;
    BOOL hasStartPoint;
    CGPoint startPoint;
    CGPoint endPoint;
    CGPoint lastCircle;
    CGRect roundRect;
    CGRect routeRect;
    CGRect endPointRect;
    int roundRectSize = ROUTE_LINE_RECT_SIZE;
    NSMutableArray *stepPoint;
    RouteLine *tmpRouteLine;
    int drawedMinRouteLineNo;
    int drawedMaxRouteLineNo;
    int routeLineInterval;
    
    
    drawedMinRouteLineNo    = -1;
    drawedMaxRouteLineNo    = -1;
    hasStartPoint           = FALSE;
    routeRect               = rect;
    stepPoint               = [[NSMutableArray alloc] init];
    lastCircle.x            = 0;
    lastCircle.y            = 0;
    routeRect               = rect;
    routeLineInterval       = 100;
    
    // draw route line
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextSetLineWidth(context, ROUTE_LINE_WIDTH);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    if (nil == drawedRouteLines)
    {
        drawedRouteLines = [[NSMutableArray alloc] initWithCapacity:routeLineInterval*2];
    }
    
    [drawedRouteLines removeAllObjects];
    
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    
    // find out the max and min route line no to be drawed
    i = currentRouteLine.no - routeLineInterval > -1 ? currentRouteLine.no - routeLineInterval : 0;
    for (; i<currentRouteLine.no+routeLineInterval && i<route.routeLines.count; i++)
    {
        RouteLine *rl;
        rl              = [route.routeLines objectAtIndex:i];
        startPoint      = [self getDrawCGPoint:rl.startProjectedPoint];
        endPoint        = [self getDrawCGPoint:rl.endProjectedPoint];
        startPoint.x    += xOffset;
        endPoint.x      += xOffset;
        
        /* 1. current route line
         * 2. start point in the draw rect
         * 3. end point int the draw rect
         */
        if (rl == currentRouteLine                     ||
            CGRectContainsPoint(routeRect, startPoint) ||
            CGRectContainsPoint(routeRect, endPoint))
        {
            if (drawedMinRouteLineNo == -1)
                drawedMinRouteLineNo = rl.no;
            
            if (drawedMaxRouteLineNo < rl.no)
                drawedMaxRouteLineNo = rl.no;
            
        }
    }
    
    // draw route lines whose route line No is in among <Min,Max> route line No.
    for (i=drawedMinRouteLineNo; i<route.routeLines.count && i<=drawedMaxRouteLineNo && i>-1; i++)
    {
        RouteLine *rl = [route.routeLines objectAtIndex:i];
        
        startPoint      = [self getDrawCGPoint:rl.startProjectedPoint];
        endPoint        = [self getDrawCGPoint:rl.endProjectedPoint];
        startPoint.x    += xOffset;
        endPoint.x      += xOffset;
        
        if (FALSE == hasStartPoint)
        {
            CGContextMoveToPoint(context, startPoint.x, startPoint.y);
            hasStartPoint = TRUE;
        }
        
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        [drawedRouteLines addObject:rl];
    }
    
    CGContextStrokePath(context);
    CGContextFillPath(context);
    
    
    // add circle to the edge of route line
    for(RouteLine *rl in drawedRouteLines)
    {
        startPoint      = [self getDrawCGPoint:rl.startProjectedPoint];
        startPoint.x    += xOffset;
        
        /* skip circules that are too close to the previous drawed one */
        if (!rl.startRouteLine && [GeoUtil getLength:[GeoUtil getPointDFromCGPoint:startPoint]
                                             ToPoint:[GeoUtil getPointDFromCGPoint:lastCircle]] < roundRectSize)
        {
            continue;
        }
        
        roundRect.origin.x = startPoint.x-roundRectSize/2;
        roundRect.origin.y = startPoint.y-roundRectSize/2;
        roundRect.size.width = roundRectSize;
        roundRect.size.height = roundRectSize;
        
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextFillEllipseInRect(context, roundRect);
        CGContextFillPath(context);
        CGContextStrokePath(context);
        
#if DEBUG
        if (TRUE == rl.startRouteLine)
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        else
            CGContextSetStrokeColorWithColor(context, self.color.CGColor);
#elif RELEASE_TEST
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
#else
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
#endif
        
        CGContextSetLineWidth(context, 2.0);
        CGContextBeginPath(context);
        CGContextAddArc(context, startPoint.x, startPoint.y, 12, 0, 2*M_PI, YES);
        CGContextClosePath(context);
        CGContextStrokePath(context);
        
        
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextStrokeEllipseInRect(context, CGRectInset(roundRect, 8, 8));
        CGContextStrokePath(context);
        
        lastCircle = startPoint;
    }
    
    // draw start point
    if (route.routeLines.count > 1)
    {
        RouteLine *firstRl = [route.routeLines objectAtIndex:0];
        RouteLine *secondR1 = [route.routeLines objectAtIndex:1];
        if ([GeoUtil getGeoDistanceFromLocation:firstRl.startLocation ToLocation:secondR1.startLocation] < 10.0)
        {
            tmpRouteLine = secondR1;
        }
    }
    else
    {
        tmpRouteLine = [route.routeLines objectAtIndex:0];
    }
    
    startPoint      = [self getDrawCGPoint:tmpRouteLine.startProjectedPoint];
    endPoint        = [self getDrawCGPoint:tmpRouteLine.endProjectedPoint];
    
    
    startPoint.x    += xOffset;
    endPoint.x      += xOffset;
    
    if (CGRectContainsPoint(routeRect, startPoint) ||
        CGRectContainsPoint(routeRect, endPoint))
    {
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(context, 4.0);
        
        endPointRect.origin.x = startPoint.x - 16;
        endPointRect.origin.y = startPoint.y - 16;
        endPointRect.size.width = 16*2;
        endPointRect.size.height = 16*2;
        CGContextFillRect(context, endPointRect);
        CGContextStrokeRect(context, endPointRect);
        
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextFillRect(context, CGRectInset(endPointRect, 8, 8));
        
    }
    
    
    // draw end point
    tmpRouteLine = [route.routeLines lastObject];
    startPoint      = [self getDrawCGPoint:tmpRouteLine.startProjectedPoint];
    endPoint        = [self getDrawCGPoint:tmpRouteLine.endProjectedPoint];
    startPoint.x    += xOffset;
    endPoint.x      += xOffset;
    
    if (CGRectContainsPoint(routeRect, startPoint) ||
        CGRectContainsPoint(routeRect, endPoint))
    {
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(context, 4.0);
        
        endPointRect.origin.x = startPoint.x - 16;
        endPointRect.origin.y = startPoint.y - 16;
        endPointRect.size.width = 16*2;
        endPointRect.size.height = 16*2;
        CGContextFillRect(context, endPointRect);
        CGContextStrokeRect(context, endPointRect);
        
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextFillRect(context, CGRectInset(endPointRect, 8, 8));
    }
}

#if 0
-(void) drawRoute:(CGContextRef) context Rectangle:(CGRect) rect
{
    int i;
    BOOL hasStartPoint;
    PointD startPoint;
    PointD endPoint;
    PointD lastCircle;
    CGRect roundRect;
    CGRect routeRect = rect;
    CGRect endPointRect;
    int roundRectSize = ROUTE_LINE_RECT_SIZE;
    NSMutableArray *stepPoint;
    RouteLine *tmpRouteLine;
    int drawedMinRouteLineNo;
    int drawedMaxRouteLineNo;

    
    drawedMinRouteLineNo    = -1;
    drawedMaxRouteLineNo    = -1;
    hasStartPoint           = FALSE;
    routeRect               = rect;
    stepPoint               = [[NSMutableArray alloc] init];
    lastCircle.x            = 0;
    lastCircle.y            = 0;
    
    // draw route line
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextSetLineWidth(context, ROUTE_LINE_WIDTH);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    if (nil == drawedRouteLines)
    {
        drawedRouteLines = [[NSMutableArray alloc] initWithCapacity:30];
    }
    
    [drawedRouteLines removeAllObjects];
    
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    
    // find out the max and min route line no to be drawed
    i = currentRouteLine.no - 30 > -1 ? currentRouteLine.no - 30 : 0;
    for (; i<currentRouteLine.no+30 && i<route.routeLines.count; i++)
    {
        RouteLine *rl;
        rl              = [route.routeLines objectAtIndex:i];
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
            if (drawedMinRouteLineNo == -1)
                drawedMinRouteLineNo = rl.no;
            
            if (drawedMaxRouteLineNo < rl.no)
                drawedMaxRouteLineNo = rl.no;
                
        }
    }
    
    // draw route lines whose route line No is in among <Min,Max> route line No.
    for (i=drawedMinRouteLineNo; i<route.routeLines.count && i<=drawedMaxRouteLineNo && i>-1; i++)
    {
        RouteLine *rl = [route.routeLines objectAtIndex:i];
        
        startPoint      = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:rl.startLocation]];
        endPoint        = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:rl.endLocation]];
        startPoint.x    += xOffset;
        endPoint.x      += xOffset;
        
        if (FALSE == hasStartPoint)
        {
            CGContextMoveToPoint(context, startPoint.x, startPoint.y);
            hasStartPoint = TRUE;
        }
            
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        [drawedRouteLines addObject:rl];
    }
    
    CGContextStrokePath(context);
    CGContextFillPath(context);
    
    
    // add circle to the edge of route line
    for(RouteLine *rl in drawedRouteLines)
    {
        startPoint      = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:rl.startLocation]];
        startPoint.x    += xOffset;
        
        /* skip circules that are too close to the previous drawed one */
        if (!rl.startRouteLine && [GeoUtil getLength:startPoint ToPoint:lastCircle] < roundRectSize)
        {
            continue;
        }
        
        roundRect.origin.x = startPoint.x-roundRectSize/2;
        roundRect.origin.y = startPoint.y-roundRectSize/2;
        roundRect.size.width = roundRectSize;
        roundRect.size.height = roundRectSize;
        
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextFillEllipseInRect(context, roundRect);
        CGContextFillPath(context);
        CGContextStrokePath(context);

#if DEBUG
        if (TRUE == rl.startRouteLine)
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        else
            CGContextSetStrokeColorWithColor(context, self.color.CGColor);
#elif RELEASE_TEST
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
#else
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
#endif
        
        CGContextSetLineWidth(context, 2.0);
        CGContextBeginPath(context);
        CGContextAddArc(context, startPoint.x, startPoint.y, 12, 0, 2*M_PI, YES);
        CGContextClosePath(context);
        CGContextStrokePath(context);
        
        
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextStrokeEllipseInRect(context, CGRectInset(roundRect, 8, 8));
        CGContextStrokePath(context);
        
        lastCircle = startPoint;
    }
    
    // draw start point
    if (route.routeLines.count > 1)
    {
        RouteLine *firstRl = [route.routeLines objectAtIndex:0];
        RouteLine *secondR1 = [route.routeLines objectAtIndex:1];
        if ([GeoUtil getGeoDistanceFromLocation:firstRl.startLocation ToLocation:secondR1.startLocation] < 10.0)
        {
            tmpRouteLine = secondR1;
        }
    }
    else
    {
        tmpRouteLine = [route.routeLines objectAtIndex:0];
    }
    
    startPoint      = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:tmpRouteLine.startLocation]];
    endPoint        = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:tmpRouteLine.endLocation]];
    

    startPoint.x    += xOffset;
    endPoint.x      += xOffset;
    
    if (CGRectContainsPoint(routeRect, [GeoUtil getCGPoint:startPoint]) ||
        CGRectContainsPoint(routeRect, [GeoUtil getCGPoint:endPoint]))
    {
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(context, 4.0);
        
        endPointRect.origin.x = startPoint.x - 16;
        endPointRect.origin.y = startPoint.y - 16;
        endPointRect.size.width = 16*2;
        endPointRect.size.height = 16*2;
        CGContextFillRect(context, endPointRect);
        CGContextStrokeRect(context, endPointRect);
        
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextFillRect(context, CGRectInset(endPointRect, 8, 8));
        
    }
    
    
    // draw end point
    tmpRouteLine = [route.routeLines lastObject];
    startPoint      = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:tmpRouteLine.startLocation]];
    endPoint        = [self getDrawPoint:[GeoUtil makePointDFromCLLocationCoordinate2D:tmpRouteLine.endLocation]];
    startPoint.x    += xOffset;
    endPoint.x      += xOffset;
    
    if (CGRectContainsPoint(routeRect, [GeoUtil getCGPoint:startPoint]) ||
        CGRectContainsPoint(routeRect, [GeoUtil getCGPoint:endPoint]))
    {
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(context, 4.0);
        
        endPointRect.origin.x = startPoint.x - 16;
        endPointRect.origin.y = startPoint.y - 16;
        endPointRect.size.width = 16*2;
        endPointRect.size.height = 16*2;
        CGContextFillRect(context, endPointRect);
        CGContextStrokeRect(context, endPointRect);
        
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextFillRect(context, CGRectInset(endPointRect, 8, 8));
    }
}

#endif
/*
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
    
    carRect.origin.x = carCenterPoint.x - size + _routeComponentRect.origin.x;
    carRect.origin.y = carCenterPoint.y - size;
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
        
        carOffset.x = carCenterPoint.x - normalPointStart.x;
        carOffset.y = carCenterPoint.y - normalPointStart.y;
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
*/
-(void) drawCurrentRouteLine:(CGContextRef) context
{
    CGPoint curPoint;
    
    if(currentRouteLine == nil)
        return;
    
    CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextSetLineWidth(context, 5.0);
    
    curPoint = [self getDrawCGPoint:currentRouteLine.startProjectedPoint];
    curPoint.x += xOffset;
    
    CGContextMoveToPoint(context, curPoint.x, curPoint.y);
    curPoint = [self getDrawCGPoint:currentRouteLine.endProjectedPoint];
    curPoint.x += xOffset;
    CGContextAddLineToPoint(context, curPoint.x, curPoint.y);
    CGContextStrokePath(context);
    
}

-(void) drawTurnMessage:(CGContextRef) context
{
    RouteLine *nextStepRouteLine;
    
    if(currentRouteLine != nil)
    {
        /* show turn message within 100 meters */
        nextStepRouteLine = [route getNextStepFirstRouteLineByRouteLine:currentRouteLine
                                                            carLocation:currentCarLocation
                                                                  speed:carStatus.speed
                                                     distanceToNextStep:&distanceToNextStep
                                                         timeToNextStep:&timeToNextStep
                             ];
        
        if(nextStepRouteLine != nil)
        {
            NSString* text = [route getStepInstruction:nextStepRouteLine.stepNo];
            //[self drawMessageBox:context Message:[route getStepInstruction:nextStepRouteLine.stepNo]];
            messageBoxLabel.text = [route getStepInstruction:nextStepRouteLine.stepNo];
            if(YES == [SystemConfig getBoolValue:CONFIG_IS_SPEECH] && FALSE == [audioPlayer isPlaying] )
            {
                [self playSpeech:text];
            }
        }
        else
        {
            messageBoxLabel.text = @"";
        }

#if DEBUG
        if (distanceToNextStep <= [SystemConfig getDoubleValue:CONFIG_TURN_ANGLE_BEFORE_DISTANCE] ||
            timeToNextStep <= [SystemConfig getDoubleValue:CONFIG_TURN_ANGLE_BEFORE_TIME])
        {
            debugMsgLabel.textColor = [UIColor redColor];
        }
        else
        {
            debugMsgLabel.textColor = [UIColor whiteColor];
        }
        
#elif RELEASE_TEST
        
#else
        
#endif
        
    }
}


-(void) drawRouteLabel:(CGContextRef) context
{
    // Drawing code
    int i;
    CGPoint startPoint;
    CGPoint endPoint;
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
        
        startPoint  = [self getDrawCGPoint:tmpCurrentRouteLine.startProjectedPoint];
        endPoint    = [self getDrawCGPoint:tmpCurrentRouteLine.endProjectedPoint];
        
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
//    PointD curPoint;
    CGPoint curPoint;
    CGRect rect;
    NSTextAlignment aligment;
    NSMutableArray* drawedPoint = [[NSMutableArray alloc] init];
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);

    for(i=0; i<carFootPrint.count; i++)
    {
        int size = 4;
        curPoint = [self getDrawCGPoint:[[carFootPrint objectAtIndex:i] CGPointValue]];
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
        
        [drawedPoint addObject:[NSValue valueWithCGPoint:curPoint]];
    }
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
    turnArrowImage.image = [self getTurnImage];
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
        mlogDebug(@"car foot print (%12.7f, %12.7f)", [v PointDValue].y, [v PointDValue].x);
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

-(CGRect) getFitSizeRect:(CGRect) rect Message:(NSString*) message FontSize:(int*) fontSize
{
    int tmpFontSize = *fontSize;
    CGSize actualSize;
    UIFont *font;
    NSString* sampleText = @"OK";
    double oneLineHeight = 0;
    int currentLineNo = 1;
    int minFontSize = 24;
    CGRect resultRect;
    
    
    font = [UIFont boldSystemFontOfSize:tmpFontSize];
    // measure the line height from the sample text
    actualSize = [sampleText sizeWithFont:font constrainedToSize:rect.size lineBreakMode:NSLineBreakByClipping];
    oneLineHeight = actualSize.height;
    
    // measure the rect for the message
    while (tmpFontSize >= minFontSize && currentLineNo <=2)
    {
        font = [UIFont boldSystemFontOfSize:tmpFontSize];
        // measure the actual size
        actualSize = [message sizeWithFont:font constrainedToSize:rect.size lineBreakMode:NSLineBreakByClipping];
        
        // if the acutal rect size fits the given rect, then break;
        if (actualSize.width <= rect.size.width && actualSize.height <= oneLineHeight*currentLineNo)
            break;
        
        // cannot find a match rect, adjust the font size
        
        
        // increase line count
        if (tmpFontSize == minFontSize)
        {
            currentLineNo++;
            tmpFontSize = *fontSize;
        }
        // decrease font size
        else
        {
            tmpFontSize--;
        }
    }
    
    *fontSize       = tmpFontSize;
    resultRect      = rect;
    resultRect.size = actualSize;
    
    printf("font size: %d, line count: %d", *fontSize, currentLineNo);
    
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

    printf("font size: %d", fontSize);
    mlogDebug(@"font size: %d\n", fontSize);
    return fontSize;
}

-(CGPoint) getDrawCGPoint:(CGPoint)p
{
    return [CoordinateTranslator getDrawPointByPoint:p at:carProjectedPoint angle:currentDrawAngle projectionToScreenOffset:projectionToScreenOffset screenMirrorPoint:carScreenCenterPoint];
}

#pragma mark - Navigation
-(void) initNewRouteNavigation
{
    RouteLine *firstRouteLine;

    targetAngle                     = 0;
    screenSize.width                = 480;
    screenSize.height               = 320;

    angleRotateStep                 = 0.1;
    rotateInterval                  = 0.1;
    firstRouteLine                  = [route.routeLines objectAtIndex:0];
    currentRouteLine                = nil;
    lastFailedRouteStartPlace       = nil;
    lastCarLocation                 = CLLocationCoordinate2DMake(firstRouteLine.startLocation.latitude,
                                                                 firstRouteLine.startLocation.longitude);
    lastCarLocationForCarAngle      = CLLocationCoordinate2DMake(lastCarLocation.latitude, lastCarLocation.longitude);
    distanceFromCarInitToRouteStart = [GeoUtil getGeoDistanceFromLocation:routeStartPlace.coordinate ToLocation:firstRouteLine.startLocation];
    
    [self updateTranslationConstant];
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0]];
    currentStep     = 0;
    carFootPrint    = [NSMutableArray arrayWithCapacity:0];
    
    rotateTimer     = [NSTimer scheduledTimerWithTimeInterval:rotateInterval target:self
                                                     selector:@selector(rotateAngle:)
                                                     userInfo:nil
                                                      repeats:YES];
    [self stopRoutePlanTimer];
    
    if (YES == [SystemConfig getBoolValue:CONFIG_IS_SPEECH])
    {
        [NaviQueryManager downloadSpeech:route];
    }
    
    [LocationManager setRoute:route];
    
    if (YES == [SystemConfig getBoolValue:CONFIG_H_IS_LOCATION_SIMULATOR])
    {
        [LocationManager triggerLocationUpdate];
    }
    
    
    lastGPSSignalTime                       = [NSDate date];
    lastValidGPSSignalTime                  = [NSDate date];
    lastValidRouteLineTime                  = [NSDate date];
    
    refreshCount                            = 0;
    // configure debug option
    _isAutoSimulatorLocationUpdateStarted   = FALSE;
    outOfRouteLineCount                     = 0;
    distanceToRouteLine                     = 0;
    /* trigger a fake car location from start location */
    [self updateCarLocation:routeStartPlace.coordinate speed:0 heading:0];
    
    [self setNeedsDisplay];
    
    [routeTrack addRoute:route];

}


-(void) playSpeech:(NSString*) text
{
    /* never play speech in simulator mode */
    if (NO == [SystemConfig getBoolValue:CONFIG_IS_SPEECH])
        return;
    
    /* if played before, just skip it */
    if (YES == [lastPlayedSpeech isEqualToString:text])
    {
        return;
    }
    @try
    {
        NSString* filePath = [NSString stringWithFormat:@"%@/%@.mp3", [SystemManager getPath:kSystemManager_Path_Speech], text];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
            if (fileSize > 0)
            {

                mlogDebug(@"play %@, %@, size: %LU\n", text, filePath, fileSize);

                audioPlayer                 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                audioPlayer.numberOfLoops   = 0;
                if ([audioPlayer prepareToPlay])
                {
                    if ([audioPlayer play])
                    {
                        lastPlayedSpeech = [NSString stringWithString:text];
                    }
                        
                }
            }
        }


    }
    @catch (NSException *exception)
    {
        mlogException(exception);
    }


}

-(void) processRouteDownloadRequestStatusChange
{
    if (GR_STATE_ROUTE_PLANNING == naviState.state || GR_STATE_ROUTE_REPLANNING == naviState.state)
    {
        /* search place finished */
        if (routeDownloadRequest.status == kDownloadStatus_Finished)
        {
            [self startRouteNavigation];
        }
        /* search failed */
        else if(YES == routeDownloadRequest.done)
        {
            [naviState sendEvent:GR_EVENT_LOCATION_LOST];
        }
        
        if (YES == routeDownloadRequest.done)
        {
            [self stopRoutePlanTimer];
        }
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
    /* use rotate angle timer to reset the pending message */
    if (TRUE == hasMessage)
    {
        self.messageBoxText = pendingMessage;
    }

    
    
    if(TRUE == [self updateCurrentDrawAngle])
    {

        currentLocationImage.transform  = CGAffineTransformMakeRotation(carTargetAngle - currentDrawAngle);
        [self setNeedsDisplay];
    }
    
//    mlogDebug(@"car: %.0f, draw:%.0f，target:%.0f", TO_ANGLE(carTargetAngle), TO_ANGLE(currentDrawAngle), TO_ANGLE(targetAngle));
    
    if (refreshCount++%5==0)
    {
//        [self dumpWatchDog];
    }
}


-(void) startRouteNavigation
{
    
    mlogInfo(@"Start: %@, To: %@", routeStartPlace, routeEndPlace);
    
    GoogleJsonStatus status = [GoogleJson getStatus:routeDownloadRequest.filePath];
    if ( kGoogleJsonStatus_Ok == status)
    {
        route = [Route parseJson:routeDownloadRequest.filePath];
        if (nil != route)
        {
            RouteLine* rl = [route.routeLines lastObject];
            endRouteLineEndPoint = CLLocationCoordinate2DMake(rl.endLocation.latitude, rl.endLocation.longitude);
            [naviState sendEvent:GR_EVENT_START_NAVIGATION];
            [self initNewRouteNavigation];
        }
        else
        {
            lastFailedRouteStartPlace = routeStartPlace;
            [naviState sendEvent:GR_EVENT_LOCATION_LOST];
        }
    }
    else if(kGoogleJsonStatus_Zero_Results == status)
    {
        lastFailedRouteStartPlace = routeStartPlace;
        [naviState sendEvent:GR_EVENT_NO_ROUTE];
    }
    else
    {
        lastFailedRouteStartPlace = routeStartPlace;
        [naviState sendEvent:GR_EVENT_RESTART];
    }

    return;
}

-(BOOL) startRouteNavigationFrom:(Place*) s To:(Place*) e
{
    mlogInfo(@"Start: %@, To: %@", s, e);
    if (nil == s || nil == e)
    {
        mlogError(@"No start or end place");
        return FALSE;
    }
    
    routeStartPlace = s;
    routeEndPlace   = e;
    route           = nil;
    
    routeTrack.name = [NSString stringWithFormat:@"Dest.%.8f,%.8f", e.coordinate.latitude, e.coordinate.longitude];
    
    [naviState sendEvent:GR_EVENT_GPS_NO_SIGNAL];
    [naviState sendEvent:GR_EVENT_ALL_READY];
    
    return TRUE;
}

-(void) replanRoute
{
    mlogDebug(@"Re-Route by current place\n");
    routeStartPlace = [LocationManager currentPlace];

    if (routeStartPlace != nil && FALSE == [routeStartPlace isCoordinateEqualTo:lastFailedRouteStartPlace])
    {
        [self planRoute];
    }
    else
    {
        [naviState sendEvent:GR_EVENT_LOCATION_LOST];
    }
}

-(void) planRoute
{
    planRouteCount++;
    
    mlogDebug(@"plan route from %@ to %@", routeStartPlace, routeEndPlace);
    if (nil != routeStartPlace && nil != routeEndPlace)
    {
        if (YES == [routeStartPlace isNullPlace])
        {
            [naviState sendEvent:GR_EVENT_GPS_NO_SIGNAL];
        }
        else if (![routeStartPlace isCoordinateEqualTo:routeEndPlace])
        {
            /* we should clear all pending download to prevent lots of pending download block the new route plan request */
            [NaviQueryManager cancelPendingDownload];
            routeDownloadRequest = [NaviQueryManager
                                    getRouteDownloadRequestFrom:routeStartPlace.coordinate
                                    To:routeEndPlace.coordinate];
            routeDownloadRequest.delegate = self;
            [self startRoutePlanTimer];
            mlogInfo(@"plan route\n");
            [NaviQueryManager download:routeDownloadRequest];
        }
        else
        {
            [naviState sendEvent:GR_EVENT_ROUTE_DESTINATION_ERROR];
        }
    }
    else
    {
        [naviState sendEvent:GR_EVENT_ROUTE_DESTINATION_ERROR];
    }
}

-(void) dumpWatchDog
{
#if DEBUG
    NSString *t1 = [NSString stringWithFormat:@"      last GPS Signal Time: %@", [dateFormattor stringFromDate:lastGPSSignalTime]];
    NSString *t2 = [NSString stringWithFormat:@"last Valid Route Line Time: %@", [dateFormattor stringFromDate:lastValidRouteLineTime]];
    NSTimeInterval elapsedTime = [lastGPSSignalTime timeIntervalSinceDate:lastValidRouteLineTime];
    mlogDebug(@"\n%@\n%@\n              elapsed time: %f\n", t1, t2, elapsedTime);
#endif
}


#pragma mark - Location Update
-(void) updateTranslationConstant
{

    carProjectedPoint         = [CoordinateTranslator projectCoordinate:carStatus.location];
    projectionToScreenOffset.x = carScreenCenterPoint.x - carProjectedPoint.x;
    projectionToScreenOffset.y = carScreenCenterPoint.y - carProjectedPoint.y;

    carDrawPoint     = [self getDrawCGPoint:carProjectedPoint];

}

-(void) updateCarLocation:(CLLocationCoordinate2D) location speed:(double)speed heading:(double)heading
{
//    mlogDebug(@"update car location: %.8f, %.8f\n", location.latitude, location.longitude);
    float distanceFromCarToRouteStart;
    RouteLine* firstRouteLine;
    lastCarLocation     = currentCarLocation;
    currentCarLocation  = location;


    firstRouteLine              = [route.routeLines objectAtIndex:0];
    lastRouteLine               = currentRouteLine;
    distanceFromCarToRouteStart = [GeoUtil getGeoDistanceFromLocation:location ToLocation:firstRouteLine.startLocation];

    [carStatus updateLocation:location speed:speed heading:heading];
    
    currentRouteLine = [route findClosestRouteLineByLocation:currentCarLocation LastRouteLine:currentRouteLine distance:&distanceToRouteLine];

    logO(currentRouteLine);
    logO(firstRouteLine);
    
    logF(distanceFromCarInitToRouteStart);
    logF(distanceFromCarToRouteStart);
    /* head to first route line
     * 1. current route line is nil
     * 2. no last route line
     * 3. near to the start location
     */
    
    
    if (nil == currentRouteLine && nil == lastRouteLine && distanceFromCarToRouteStart <= distanceFromCarInitToRouteStart+15)
    {
        currentRouteLine = firstRouteLine;
        lastValidRouteLineTime = [NSDate date];
        [naviState sendEvent:GR_EVENT_ROUTE_LINE_READY];
    }
    
    /* found matched route line */
    else if (nil != currentRouteLine)
    {
        /* reset the out of route line count */
        outOfRouteLineCount = 0;
        
        if ([GeoUtil getGeoDistanceFromLocation:currentCarLocation ToLocation:endRouteLineEndPoint] < ARRIVAL_REGION)
        {
            lastValidRouteLineTime = [NSDate date];
            [naviState sendEvent:GR_EVENT_ARRIVAL];
        }
        else
        {
            lastValidRouteLineTime = [NSDate date];
            [naviState sendEvent:GR_EVENT_ROUTE_LINE_READY];
        }
        
        
    }
    /* cannot find matched route line */
    else
    {
        NSTimeInterval duration;
        /* let the current route line be the last route line */
        currentCarLocation  = lastCarLocation;
        currentRouteLine    = lastRouteLine;
        
        outOfRouteLineCount++;
        
        if (nil != lastValidRouteLineTime)
        {
            duration = -[lastValidRouteLineTime timeIntervalSinceNow];
            /* stay at GPS_READY if missing GPS signal is less than the CONFIG_MAX_OUT_OF_ROUTELINE_COUNT */
            if (duration < [SystemConfig getIntValue:CONFIG_MAX_OUT_OF_ROUTELINE_TIME] && outOfRouteLineCount <= 3)
            {
                [naviState sendEvent:GR_EVENT_GPS_READY];
            }
            /* location lost */
            else
            {
                mlogInfo(@"exceed out of route line time, duration: %.1f, outOfRouteLineCount: %d\n", duration, outOfRouteLineCount);
                outOfRouteLineCount = 0;
                [naviState sendEvent:GR_EVENT_LOCATION_LOST];
                lastValidRouteLineTime = nil;
            }
        }
    }

    
    /* event we lost location now, we still use last route line to draw current navigation map */
    if(currentRouteLine != nil)
    {
        [carFootPrint addObject:[NSValue valueWithCGPoint:carProjectedPoint]];
        [self updateTranslationConstant];
        targetAngle     = [route getCorrectedTargetAngle:currentRouteLine.no distance:[SystemConfig getDoubleValue:CONFIG_TARGET_ANGLE_DISTANCE]];

        _turnAngle      = [route getAngleFromCLLocationCoordinate2D:currentCarLocation
                                                        routeLineNo:currentRouteLine.no
                                                     withInDistance:[SystemConfig getDoubleValue:CONFIG_TURN_ANGLE_BEFORE_DISTANCE]+100];
    }
    

    /* calculate car angle for every 3m */
    if ([GeoUtil getGeoDistanceFromLocation:lastCarLocationForCarAngle ToLocation:currentCarLocation] > 6.0)
    {
        /* far top point -> last car location -> current car location */
        carTargetAngle  = [GeoUtil getAngle360ByLocation1:CLLocationCoordinate2DMake(lastCarLocation.latitude+0.00001, lastCarLocation.longitude)
                                             Location2:lastCarLocation
                                             Location3:currentCarLocation];

        currentLocationImage.transform  = CGAffineTransformMakeRotation(carTargetAngle - currentDrawAngle);
        
        lastCarLocationForCarAngle = currentCarLocation;
        
    }
    else
    {
        currentLocationImage.transform  = CGAffineTransformMakeRotation(0);
    }
    
}

#pragma location update

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
    {
        return false;
    }
    
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
    
/*
    mlogDebug(@"cur angle: %.0f, directionAngle: %.0f, turnAngle:%.0f angleOffset:%.0f, step:%.0f\n",
           TO_ANGLE(currentDrawAngle),
           TO_ANGLE(targetAngle),
           TO_ANGLE(turnAngle),
           TO_ANGLE(angleOffset),
           TO_ANGLE(angleRotateStep)
           );
*/
    
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
/*
    mlogDebug(@"2 cur angle: %.0f, directionAngle: %.0f, turnAngle:%.0f angleOffset:%.0f\n",
           TO_ANGLE(currentDrawAngle),
           TO_ANGLE(targetAngle),
           TO_ANGLE(turnAngle),
           TO_ANGLE(angleOffset)
           );
*/
    
    currentDrawAngle = [self adjustAngle:currentDrawAngle];
    
    
    
    return true;
}

#pragma mark - UI Control
-(void) addUIComponents
{

    clockView                       = [[ClockView alloc] initWithFrame:CGRectMake(8, 60, 120, 50)];
    clockView.backgroundColor       = [UIColor clearColor];
    clockView.opaque                = TRUE;

    systemStatusView                = [[SystemStatusView alloc] initWithFrame:CGRectMake(0, 0, 180, 50)];
    systemStatusView.opaque         = TRUE;

    turnArrowImage                  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"turn_right45.png"]];
    turnArrowFrame                  = CGRectMake(-20, 180, 240, 120);
    turnArrowImage.frame            = turnArrowFrame;

    turnArrowImage.contentMode      = UIViewContentModeScaleAspectFit;
//    turnArrowImage.backgroundColor  = [UIColor grayColor];
    currentLocationImage            = [[UIImageView alloc] initWithFrame:
                                       CGRectMake(carScreenCenterPoint.x + _routeComponentRect.origin.x-15, carScreenCenterPoint.y-15, 30, 60)];

//    currentLocationImage.image      = [[UIImage imageNamed:@"route_current_location.png"] imageTintedWithColor:[UIColor redColor]];
    currentLocationImage.image      = [UIImage imageNamed:@"car_location.png"];
    
    turnArrowImage.contentMode      = UIViewContentModeScaleAspectFit;
    
    
    speedView                       = [[SpeedView alloc] initWithFrame:CGRectMake(8, 105, 150, 50)];

    routeView                       = [[RouteView alloc] initWithFrame:CGRectMake(200, 4, 480-200-4, 320-8)];
    routeView.backgroundColor       = [UIColor grayColor];
    routeView.autoresizingMask      = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    routeView.opaque                = TRUE;
    
    messageBoxLabel                 = [[MessageBoxLabel alloc] initWithFrame:
                                       CGRectMake(10, 40, [SystemManager lanscapeScreenRect].size.width -20, 161)];
    debugMsgLabel                   = [[UILabel alloc] init];
    debugMsgLabel.text              = @"";
    debugMsgLabel.textColor         = [UIColor whiteColor];
    debugMsgLabel.backgroundColor   = [UIColor clearColor];
    debugMsgLabel.frame             = CGRectMake(8, 230, 480, 90);
    debugMsgLabel.numberOfLines     = 3;
    [clockView update];

    
    [self addSubview:turnArrowImage];
    [self addSubview:systemStatusView];
    [self addSubview:clockView];
    [self addSubview:currentLocationImage];
    [self addSubview:speedView];
    [self addSubview:messageBoxLabel];
    [self addSubview:debugMsgLabel];
//    [self addSubview:routeView];

    
}

-(void) active
{
    lastPlayedSpeech         = nil;
    [systemStatusView active];
    [clockView active];
    [speedView active];
    
    debugMsgLabel.hidden = ![SystemConfig getBoolValue:CONFIG_H_IS_DEBUG];
    self.isNetwork  = [SystemManager getNetworkStatus] > 0;
    self.isGps      = [SystemManager getGpsStatus] > 0;

    routeTrack      = [[RouteTrack alloc] init];
//    self.isDebugRouteLineAngle  = TRUE;
//    self.isDebugNormalLine      = TRUE;

    [naviState sendEvent:GR_EVENT_ACTIVE];
}

-(void) inactive
{
    [systemStatusView inactive];
    [clockView inactive];
    [speedView inactive];
    [naviState sendEvent:GR_EVENT_INACTIVE];

    /* clear the last played speech */
    lastPlayedSpeech = @"";

    [routeTrack save];
}


-(void) update
{
    [systemStatusView update];
}

#pragma mark - property

-(void) setIsNetwork:(BOOL)isNetwork
{
    _isNetwork = isNetwork;

    if (NO == _isNetwork)
    {
    
        [naviState sendEvent:GR_EVENT_NETWORK_NO_SIGNAL];
    }
    
    [self setNeedsDisplay];
}

-(void) setIsGps:(BOOL)isGps
{

    _isGps = isGps;
    if (NO == _isGps)
    {
        [naviState sendEvent:GR_EVENT_GPS_NO_SIGNAL];
    }
    [self setNeedsDisplay];
}

-(void) setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    speedView.isSpeedUnitMph = isSpeedUnitMph;
    
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
    
    _color                     = color;
    systemStatusView.color     = self.color;
    clockView.color            = self.color;
    speedView.color            = self.color;
    messageBoxLabel.color      = self.color;
    turnArrowImage.image       = [turnArrowImage.image   imageTintedWithColor:self.color];
    
    [self setNeedsDisplay];
}

-(void) setMessageBoxText:(NSString *)messageBoxText
{
    NSDate *now = [NSDate date];
    BOOL update = FALSE;
    
    if (YES == [messageBoxLabel.text isEqualToString:@""])
    {
        update = TRUE;
    }
    else if ([messageBoxLabel.text isEqualToString:[SystemManager getLanguageString:@"Route Re-Planning"]] ||
             [messageBoxLabel.text isEqualToString:[SystemManager getLanguageString:@"Route Planning"]]
             )
    {
        if (nil != lastUpdateMessageTime)
        {
            NSTimeInterval diff = [lastUpdateMessageTime timeIntervalSinceNow] * (-1);
            if (diff > MESSAGE_BOX_DISPLAY_TIME_MIN)
            {
                update = TRUE;
            }
        }
    }
    else
    {
        update = TRUE;
    }
 
    if (TRUE == update)
    {

        lastUpdateMessageTime   = now;
        messageBoxLabel.text    = pendingMessage;
        hasMessage              = FALSE;
        pendingMessage          = @"";

    }
    else if (nil != pendingMessage && pendingMessage.length > 0)
    {
        [self startChangeMessageTimer];
    }
    else
    {
        [self stopRoutePlanTimer];
    }

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
        [naviState sendEvent:GR_EVENT_GPS_NO_SIGNAL];
    }
    else if (NO == self.checkNetwork)
    {
        [naviState sendEvent:GR_EVENT_NETWORK_NO_SIGNAL];
    }
    else if (NO == self.checkRouteDestination)
    {
        [naviState sendEvent:GR_EVENT_LOCATION_LOST];
    }
    else
    {
        [naviState sendEvent:GR_EVENT_ALL_READY];
    }
}

#pragma mark -- delegate
-(void) downloadRequest:(DownloadRequest*) downloadRequest status:(DownloadStatus) status;
{
 
    if (downloadRequest == routeDownloadRequest)
        [self processRouteDownloadRequestStatusChange];
}

-(void) locationManager:(LocationManager *)locationManager update:(CLLocationCoordinate2D)location speed:(double)speed distance:(int)distance heading:(double)heading
{
    
    currentStep++;
    mlogDebug(@"location update (%.7f, %.7f), step: %d", location.latitude, location.longitude, currentStep);
    
    /* keep track of last GPS signal update time */
    lastGPSSignalTime = [[NSDate alloc] init];
    
    if (GR_STATE_NAVIGATION == naviState.state || GR_STATE_ROUTE_REPLANNING == naviState.state || GR_STATE_ROUTE_REPLANNING == naviState.state)
    {
        [self updateCarLocation:location speed:speed heading:heading];
        [self setNeedsDisplay];
    }
    else
    {
        [naviState sendEvent:GR_EVENT_GPS_READY];
    }
    
    //    mlogDebug(@" current route, (%.7f, %.7f) - > (%.7f, %.7f), step: %d\n", routeStartPoint.y, routeStartPoint.x, routeEndPoint.y, routeEndPoint.x, locationIndex);
    
    [routeTrack addLocation:[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude] event:naviState.event];
    debugMsgLabel.text = [NSString stringWithFormat:@"%.1f, %.1f(%.1f) %.1f(%.1f)\n%.8f, %.8f, %.1f, %.1f \n%@ %@",
                          distanceToRouteLine,
                          distanceToNextStep,
                          [SystemConfig getFloatValue:CONFIG_TURN_ANGLE_BEFORE_DISTANCE],
                          timeToNextStep,
                          [SystemConfig getFloatValue:CONFIG_TURN_ANGLE_BEFORE_TIME],
                          location.latitude,
                          location.longitude,
                          speed,
                          heading,
                          [naviState GR_StateStr:naviState.state],
                          [naviState GR_EventStr:naviState.event]
                          ];
}

-(void) naviState:(NaviState*) ns newState:(GR_STATE) newState;
{
    mlogDebug(@"state %@",[naviState GR_StateStr:newState]);
    switch (newState)
    {
        case GR_STATE_INIT:
        case GR_STATE_NAVIGATION:
            pendingMessage  = @"";
            hasMessage      = TRUE;
            break;
        case GR_STATE_ROUTE_PLANNING:
            pendingMessage  = [SystemManager getLanguageString:@"Route Planning"];
            hasMessage      = TRUE;
            [self planRoute];
            break;
        case GR_STATE_ROUTE_REPLANNING:
            pendingMessage  = [SystemManager getLanguageString:@"Route Re-Planning"];
            hasMessage      = TRUE;
            [self replanRoute];
            break;
        case GR_STATE_GPS_NO_SIGNAL:
            pendingMessage  = [SystemManager getLanguageString:@"No GPS Signal"];
            hasMessage      = TRUE;
            break;
        case GR_STATE_NETWORK_NO_SIGNAL:
            pendingMessage = [SystemManager getLanguageString:@"No Network"];
            hasMessage      = TRUE;
            break;
        case GR_STATE_ARRIVAL:
            pendingMessage = [SystemManager getLanguageString:@"Arrive Destination"];
            hasMessage      = TRUE;
            break;
        case GR_STATE_ROUTE_DESTINATION_ERROR:
            pendingMessage = [SystemManager getLanguageString:@"Destination Error"];
            hasMessage      = TRUE;
            break;
        case GR_STATE_LOOKUP:
            pendingMessage = @"";
            hasMessage      = TRUE;
            [self lookupState];
            break;
        case GR_STATE_NO_ROUTE:
            pendingMessage = [SystemManager getLanguageString:@"Cannot find any Route"];
            hasMessage      = TRUE;
            break;
    }
    
    if (TRUE == hasMessage)
    {
        self.messageBoxText = pendingMessage;
    }
    
}

#pragma mark -- timer
-(void) routePlanTimeout:(NSTimer *)theTimer
{
    mlogInfo(@"route plan timeout\n");
    /* send no gps signal event to force re-out */
    if (nil != routeDownloadRequest)
    {
        mlogInfo(@"route download request status: %@", routeDownloadRequest);
        [NaviQueryManager cancelPendingDownload];
    }
    
    routeDownloadRequest = nil;
    [naviState sendEvent:GR_EVENT_GPS_NO_SIGNAL];
    
}

-(void) startRoutePlanTimer
{
    if (nil == routePlanTimer)
    {
        mlogDebug(@"start route plan timer");
        routePlanTimer     = [NSTimer scheduledTimerWithTimeInterval:[SystemConfig getIntValue:CONFIG_ROUTE_PLAN_TIMEOUT] target:self
                                                        selector:@selector(routePlanTimeout:)
                                                        userInfo:nil
                                                         repeats:NO];
    }

}
-(void) stopRoutePlanTimer
{
    mlogDebug(@"stop route plan timer");
    if (routePlanTimer != nil && [routePlanTimer isValid])
    {
        [routePlanTimer invalidate];
        
    }
    
    routePlanTimer = nil;
}

-(void) changeMessageTimeout:(NSTimer*)theTimer
{
    if (pendingMessage != nil && pendingMessage.length > 0)
    {
        self.messageBoxText = pendingMessage;
    }
}

-(void) startChangeMessageTimer
{
    if (nil == changeMessageTimer)
    {
        changeMessageTimer     = [NSTimer scheduledTimerWithTimeInterval:2 target:self
                                                            selector:@selector(changeMessageTimeout:)
                                                            userInfo:nil
                                                             repeats:NO];
    }
}
-(void) invalidateChangeMessageTimer
{
    if (changeMessageTimer != nil && [changeMessageTimer isValid])
    {
        [changeMessageTimer invalidate];
        
    }
    
    changeMessageTimer = nil;
}

#pragma mark -- notification

- (void)receiveLocationUpdateEvent:(NSNotification *)notification
{
    logfn();
    LocationUpdateEvent *event;
    event = [notification.userInfo objectForKey:@"data"];
    [self locationManager:NULL update:event.location speed:event.speed distance:event.distance heading:event.heading];
}

@end
