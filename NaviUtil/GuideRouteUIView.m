//
//  GuideRouteUIView.m
//  GoogleDirection
//
//  Created by Coming on 13/1/12.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "GuideRouteUIView.h"

@implementation GuideRouteUIView
#define radians(degrees) (degrees * M_PI/180)
-(void) initSelf
{
    int i;
    CLLocation* st = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    
    for(i=0; i<100; i++)
    {
        CLLocation* end = [[CLLocation alloc] initWithLatitude:i/100000.0 longitude:i/100000.0];
        
        printf("%.5f distance: %.2f\n", i/100000.0, [st distanceFromLocation:end]);
    }
    
    
    route = [[Route alloc] initWithJsonRouteFile:@"GoogleDirectionAPI.json"];
    margin = 0.1;
    routeDisplayBound.origin.x = floor(320*margin);
    routeDisplayBound.origin.y = floor(460*margin);
    
    
    routeDisplayBound.size.width   = floor(320*(1-margin*2));
    routeDisplayBound.size.height  = floor(460*(1-margin*2));
    
    msgRect.origin.x = 10;
    msgRect.origin.y = 100;
    msgRect.size.width = 300;
    msgRect.size.height = 300;
   
    
    printf("bounds: (%f, %f, %f, %f)\n", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    printf("routeDisplayBound: (%f, %f, %f, %f)\n", routeDisplayBound.origin.x, routeDisplayBound.origin.y, routeDisplayBound.size.width, routeDisplayBound.size.height);
    ratio = 1;
    [self generateRoutePoints];
    for (NSValue *v in routePoints)
    {
        PointD p = [v PointDValue];
        printf("(%.5f, %.5f)\n", p.x, p.y);
    }
 #if 0
    routePoints= [NSArray arrayWithObjects:
                  [NSValue valueWithPointD:PointDMake(120.25071, 23.14299)],
                  [NSValue valueWithPointD:PointDMake(120.24962, 23.14294)],
                  [NSValue valueWithPointD:PointDMake(120.24877, 23.14299)],
                  [NSValue valueWithPointD:PointDMake(120.24810, 23.14306)],
                  nil];
    

    routePoints= [NSArray arrayWithObjects:
                  [NSValue valueWithPointD:PointDMake(50, 350)],
                  [NSValue valueWithPointD:PointDMake(50, 300)],
                  [NSValue valueWithPointD:PointDMake(100,250)],
                  [NSValue valueWithPointD:PointDMake(150,250)],
                  [NSValue valueWithPointD:PointDMake(150,200)],
                  [NSValue valueWithPointD:PointDMake(100,200)],
                  [NSValue valueWithPointD:PointDMake(80, 250)],
                  
                  [NSValue valueWithPointD:PointDMake(50,50)],
                  nil];
#endif
//    NSTimer *theTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(timerTimeout) userInfo:nil repeats:YES];
    // Assume a there's a property timer that will retain the created timer for future reference.
//    timer = theTimer;
    
    
    //oneStep = 0.00013; // for 1 meter
    oneStep = 0.00013;
    
    directionAngle = 0;
    screenSize.width = 320;
    screenSize.height = 460;
    carCenterPoint.x = screenSize.width/2;
    carCenterPoint.y = screenSize.height/4;
    carPoint.x = 0;
    carPoint.y = 0;
    locationIndex = 0;
    routeLineM = 0;
    routeLineB = 0;
    isRouteLineMUndefind = false;
    ratio = 122000;
    [self nextRouteLine];
    carPoint = routeStartPoint;
    [self updateTranslationConstant];
    printf("car center point (%.5f, %.5f)\n", carCenterPoint.x, carCenterPoint.y);
    printf("car start at (%.5f, %.5f)\n", carPoint.x, carPoint.y);
    
    
}

- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        [self initSelf];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
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





// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    printf("drawRect (%f, %f)", rect.size.width, rect.size.height);
    // Drawing code
    PointD prePoint;
    PointD curPoint;
//    CGRect startRect;
//    CGRect carRect;
    CGRect endRect;
    CGRect routeRect = rect;
   
    PointD prevLocation;
    
    NSMutableArray *drawedPoint;
    
    [super drawRect:rect];
    routeRect.origin.x -= 200;
    routeRect.origin.y -= 200;
    routeRect.size.width +=400;
    routeRect.size.height +=400;
    
    drawedPoint = [[NSMutableArray alloc] init];
    //printf("bounds: (%f, %f, %f, %f)", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 3.0);
    CGColorSpaceRef  colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);
    
    CGContextSetStrokeColorWithColor(context, [UIColor cyanColor].CGColor);
    
    CGContextAddRect(context, routeDisplayBound);
    CGContextStrokeRect(context, routeDisplayBound);
    
    
//    CGContextMoveToPoint(context, 0, 0);
//    CGContextAddLineToPoint(context, 100,100);
    
//    CGContextStrokePath(context);


    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    
    CGContextSetLineWidth(context, 10.0);


    prevLocation = [[routePoints objectAtIndex:0] PointDValue];
    
    prePoint = [self getDrawPoint:prevLocation];
    [drawedPoint addObject:[NSValue valueWithPointD:prePoint]];
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);

    CGContextMoveToPoint(context, prePoint.x, prePoint.y);
    

    for(NSValue *v in routePoints)
    {
        curPoint = [self getDrawPoint:[v PointDValue]];
        
        if(curPoint.x == prePoint.x && curPoint.y == prePoint.y)
            continue;
        
        if(!CGRectContainsPoint(routeRect, [GeoUtil getCGPoint:curPoint]))
        {
            CGContextMoveToPoint(context, curPoint.x, curPoint.y);
            continue;
        }
        [drawedPoint addObject:[NSValue valueWithPointD:curPoint]];
        CGContextAddLineToPoint(context, curPoint.x, curPoint.y);
//        CGContextDrawPath(context, kCGPathFillStroke);
//          CGContextMoveToPoint(pathRef, prePoint.x, prePoint.y);
//          CGContextAddLineToPoint(pathRef, curPoint.x, curPoint.y);
        
        endRect.origin.x = curPoint.x-2;
        endRect.origin.y = curPoint.y-2;
        endRect.size.width = 4;
        endRect.size.height = 4;
        
        CGContextAddEllipseInRect(context, endRect);
        
//        printf("line to %.1f %.1f\n", curPoint.x, curPoint.y);
        prePoint = curPoint;

    }

    CGContextStrokePath(context);
    
    //[[UIColor colorWithWhite:0.0 alpha:0.2] set];
    //UIRectFillUsingBlendMode(msgRect, kCGBlendModeNormal);
    


#if 0
    prevLocation = [[routePoints objectAtIndex:0] PointDValue];
    
  
    prePoint = [self getRawDrawPoint:prevLocation];
    [drawedPoint addObject:[NSValue valueWithPointD:PointDMake(prePoint.x, prePoint.y)]];
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    
    CGContextMoveToPoint(context, prePoint.x, prePoint.y);

    
    for(NSValue *v in routePoints)
    {
        curPoint = [self getRawDrawPoint:[v PointDValue]];
        
   
        [drawedPoint addObject:[NSValue valueWithPointD:PointDMake(curPoint.x, curPoint.y)]];
        CGContextAddLineToPoint(context, curPoint.x, curPoint.y);
        //        CGContextDrawPath(context, kCGPathFillStroke);
        //          CGContextMoveToPoint(pathRef, prePoint.x, prePoint.y);
        //          CGContextAddLineToPoint(pathRef, curPoint.x, curPoint.y);
        
        endRect.origin.x = curPoint.x-2;
        endRect.origin.y = curPoint.y-2;
        endRect.size.width = 4;
        endRect.size.height = 4;
        
        CGContextAddEllipseInRect(context, endRect);
        
        //        printf("line to %.1f %.1f\n", curPoint.x, curPoint.y);
        prePoint = curPoint;
        
    }
    
    CGContextStrokePath(context);
#endif
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    for(NSValue *v in drawedPoint)
    {
        int size = 20;
        curPoint = [v PointDValue];
    
        endRect.origin.x = curPoint.x-size/2;
        endRect.origin.y = curPoint.y-size/2;
        endRect.size.width = size;
        endRect.size.height = size;
        
//        printf("Draw at (%.0f, %.0f)\n", curPoint.x, curPoint.y);
        CGContextFillEllipseInRect(context, endRect);
    }
    
    
    prePoint = [self getDrawPoint:[[routePoints objectAtIndex:0] PointDValue]];
    curPoint = [self getDrawPoint:[[routePoints objectAtIndex:routePoints.count-1] PointDValue]];
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGRect startPosText;
    CGRect endPosText;
    
    startPosText.origin.x = 70;
    startPosText.origin.y = 335;
    startPosText.size.width = 100;
    startPosText.size.height = 60;
    
    endPosText.origin.x = 220;
    endPosText.origin.y = 120;
    endPosText.size.width = 100;
    endPosText.size.height = 60;
    
    NSString *startText = @"台南";
    [startText drawInRect:startPosText withFont:[UIFont boldSystemFontOfSize:32.0]];
    
    NSString *endText = @"宜蘭";
    [endText drawInRect:endPosText withFont:[UIFont boldSystemFontOfSize:32.0]];

#if 0
    int i=0;
//    for(i=0; i<30; i+=6)
    {
        startRect.origin.x = carScreenPoint.x-i;
        startRect.origin.y = carScreenPoint.y-i;
        startRect.size.width = i*2;
        startRect.size.height = i*2;
        
        endRect.origin.x = curPoint.x-i;
        endRect.origin.y = curPoint.y-i;
        endRect.size.width = i*2;
        endRect.size.height = i*2;
        
//        carRect.origin.x = carScreenPoint.x - (carImage.size.width/2)*0.1;
//        carRect.origin.y = carScreenPoint.y - (carImage.size.width/2)*0.1;
        PointD carImagePoint;
        carImagePoint.x = carScreenPoint.x - carImage.size.width/2;
        carImagePoint.y = carScreenPoint.y - carImage.size.height/2;
        
        if(0)
        {
           
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextAddRect(context, startRect);
            CGContextFillRect(context, startRect);
            
            CGContextAddRect(context, endRect);
            CGContextFillRect(context, endRect);
            
//            CGAffineTransform rotate = CGAffineTransformMakeRotation( directionAngle );
        
//            [[self getCarImage] drawAtPoint:carImagePoint];
          
            
        }
        else
        {
            CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
            CGContextAddEllipseInRect(context, startRect);
            CGContextStrokeEllipseInRect(context, startRect);
            
            CGContextAddEllipseInRect(context, endRect);
            CGContextStrokeEllipseInRect(context, endRect);
            
        }
    }
   
#endif


    [self drawCar:context];
    [self drawMessageBox:context];

    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
}

-(void) drawMessageBox:(CGContextRef) context
{
    CGRect rect = msgRect;
    int radius = 20;

    
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
//    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextStrokePath(context);
    
}

-(void) drawCar:(CGContextRef) context
{
    int size = 20;
    CGPoint left;
    CGPoint right;
    CGPoint top;
    CGPoint bottom;
    screenSize.width = 320;
    screenSize.height = 460;
    carCenterPoint.x = screenSize.width/2;
    carCenterPoint.y = screenSize.height/4;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    
    left.x = carCenterPoint.x - size;
    left.y = (screenSize.height - carCenterPoint.y);
    right.x = left.x + size*2;
    right.y = left.y;
    top.x = carCenterPoint.x;
    top.y = (screenSize.height - carCenterPoint.y) - size;
    bottom.x = top.x;
    bottom.y = top.y + size*2;
    
    CGContextMoveToPoint(context, left.x, left.y);
    CGContextAddLineToPoint(context, right.x, right.y);
    CGContextStrokePath(context);
    CGContextFillPath(context);
    
    CGContextMoveToPoint(context, top.x, top.y);
    CGContextAddLineToPoint(context, bottom.x, bottom.y);
    CGContextStrokePath(context);
    CGContextFillPath(context);
    
}

-(void) generateRoutePoints
{
    double widthRatio;
    double heightRatio;
    if (route.status != RouteStatusCodeOK)
        return;
    
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
    
    printf("%.5f\n", fabs(-0.1));
    printf("%.5f\n", (fabs(topMost.y- bottomMost.y)*1.0));
    printf("%.5f\n", (fabs(rightMost.x - leftMost.x)*1.0));

    printf("leftMost     %9.5f\n", leftMost.x);
    printf("rightMost    %9.5f\n", rightMost.x);
    printf("topMost      %9.5f\n", topMost.y);
    printf("bottomMost   %9.5f\n", bottomMost.y);

    

//    ratio = fitRatio;
    printf("fitratio: %.2f\n", fitRatio);
    printf("   ratio: %.2f\n", ratio);
    
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

-(PointD) getDrawPoint:(PointD)p
{
    
    PointD tmpPoint;
    PointD translatedPoint;

    
    //
  
    // let carPoint be the origin
    tmpPoint.x = (p.x - carPoint.x);
    tmpPoint.y = (p.y - carPoint.y);
    

//    printf("       tmpPoint (%.8f, %.8f)\n", tmpPoint.x, tmpPoint.y);
    
    
    translatedPoint.x = tmpPoint.x*cos(directionAngle) - tmpPoint.y*sin(directionAngle) + carPoint.x;
    translatedPoint.y = tmpPoint.x*sin(directionAngle) + tmpPoint.y*cos(directionAngle) + carPoint.y;
    

//    printf("translatedPoint (%.8f, %.8f)\n", translatedPoint.x, translatedPoint.y);
    
    translatedPoint.x = translatedPoint.x*ratio + mapOffset.x;
    translatedPoint.y = translatedPoint.y*ratio + mapOffset.y;

//    printf("translatedPoint (%.8f, %.8f)\n", translatedPoint.x, translatedPoint.y);
    translatedPoint.y = screenSize.height - translatedPoint.y;
    
    
//    printf("     draw point (%.5f, %.5f) - > (%.0f, %.0f)\n\n", p.x, p.y, translatedPoint.x, translatedPoint.y);
    
    return translatedPoint;
}

-(void) timerTimeout
{
    if(locationIndex < [routePoints count])
//    if(locationIndex < 1)
    {
//        [self nextRouteLine];
//        carPoint = routeStartPoint;

        [self updateLocation];
        [self updateTranslationConstant];
        [self setNeedsDisplay];
    }
    else
    {
//        [timer invalidate];
//        timer = nil;
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


-(void) updateLocation
{
    PointD nextCarPoint = [self getNextCarPoint];
    
    if(routeUnitVector.y > 0)
    {
        // (1) ++
        if(routeUnitVector.x > 0)
        {
            if (nextCarPoint.x > routeEndPoint.x &&  nextCarPoint.y > routeEndPoint.y)
            {
                [self nextRouteLine];
                nextCarPoint = routeStartPoint;
            }
        }
        // (2) -+
        else
        {
            if (nextCarPoint.x <= routeEndPoint.x &&  nextCarPoint.y > routeEndPoint.y)
            {
                [self nextRouteLine];
                nextCarPoint = routeStartPoint;
            }
        }
    }
    else
    {
        // (4) +-
        if(routeUnitVector.x > 0)
        {
            if (nextCarPoint.x > routeEndPoint.x &&  nextCarPoint.y <= routeEndPoint.y)
            {
                [self nextRouteLine];
                nextCarPoint = routeStartPoint;
            }
        }
        // (3) --
        else
        {
            if (nextCarPoint.x <= routeEndPoint.x &&  nextCarPoint.y <= routeEndPoint.y)
            {
                [self nextRouteLine];
                nextCarPoint = routeStartPoint;
            }
        }
    }
    
    printf("car (%.8f, %.8f) -> (%.8f, %.8f), distance: %.8f\n",
          carPoint.x, carPoint.y,
          nextCarPoint.x, nextCarPoint.y,
          [GeoUtil getLength:carPoint ToPoint:nextCarPoint]
        );
    carPoint = nextCarPoint;
    [self updateTranslationConstant];

}

-(void) updateTranslationConstant
{
    mapOffset.x = carCenterPoint.x - carPoint.x*ratio;
    mapOffset.y = carCenterPoint.y - carPoint.y*ratio;
    
//    printf("mapOffset (%.8f, %.8f)\n", mapOffset.x, mapOffset.y);
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
    directionAngle = [GeoUtil getAngle:routeStartPoint Point1:tmpPoint Point2:routeEndPoint];
    
    if(tmpPoint.x > routeEndPoint.x)
    {
        directionAngle *= -1;
    }
    
//    directionAngle = 0;
    
//    printf("angle: %.5f\n", directionAngle*(180.0/M_PI));
    printf("route: (%.5f, %.5f) -> (%.5f, %.5f)\n", routeStartPoint.x, routeStartPoint.y, routeEndPoint.x, routeEndPoint.y);


    if(isRouteLineMUndefind == true)
        printf("x = %.8f\n", routeStartPoint.x);
    else if(routeLineM == 0)
        printf("y = %.8f\n", routeLineB);
    else
        printf("y = %.8fx + %.8f\n", routeLineM, routeLineB);
    
    locationIndex++;
    if(locationIndex >= routePoints.count -1)
        locationIndex = 0;
  
    routeDistance = [GeoUtil getLength:routeStartPoint ToPoint:routeEndPoint];
    routeUnitVector.x = (routeEndPoint.x - routeStartPoint.x)/routeDistance;
    routeUnitVector.y = (routeEndPoint.y - routeStartPoint.y)/routeDistance;
    
    printf("routeUnitVector: (%.8f, %.8f)\n", routeUnitVector.x, routeUnitVector.y);
   
    printf("move distance point: (%.8f, %.8f)\n", routeUnitVector.x*oneStep, routeUnitVector.y*oneStep);
    
    
    
}
@end
