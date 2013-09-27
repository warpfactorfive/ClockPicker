//
//  TBCircularSlider.m
//  TB_CircularSlider
//
//  Created by Yari Dareglia on 1/12/13.
//  Copyright (c) 2013 Yari Dareglia. All rights reserved.
//

#import "ClockPicker.h"
#import <QuartzCore/QuartzCore.h>

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

#pragma mark - Private -

@interface ClockPicker(){
    UITextField *_textField;
    int radius;
}

@end


#pragma mark - Implementation -

@implementation ClockPicker

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self)
    {        
        self.layer.borderColor = CONTROL_BORDER_COLOR .CGColor;
        self.layer.borderWidth = 2.0f;
        self.layer.backgroundColor = CONTROL_BACKGROUND_COLOR .CGColor;
        
        self.opaque = NO;
        
        //Define the circle radius taking into account a little padding
        radius = self.frame.size.width/2 - ((TB_HANDLESIZE/2)+5);

        //Initialize the Angle to 12:00 (90 degrees)
        self.angle = 90;
                
        //Define the Font
        UIFont *font = [UIFont fontWithName:TB_FONTFAMILY size:TB_FONTSIZE];
        NSString *str = @"00:00 PM ";
        CGSize fontSize = [str sizeWithFont:font];
        
        //Using a TextField area we can easily modify the control to get user input from this field
        _textField = [[UITextField alloc]initWithFrame:CGRectMake((frame.size.width  - fontSize.width) /2,
                                                                  (frame.size.height - fontSize.height) /2,
                                                                  fontSize.width,
                                                                  fontSize.height)];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = [UIColor whiteColor];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = font;

        [self updateTimeDisplay];
        
        _textField.enabled = NO;
        [self addSubview:_textField];
        
        // add in AM and PM buttons
        CGRect amRect = CGRectMake((frame.size.width/2)-22, (frame.size.height/2) - 50, 46, 46);
        CGRect pmRect = CGRectMake((frame.size.width/2)-22, (frame.size.height/2) + 5, 46, 46);

        UIButton *amButton = [[UIButton alloc] initWithFrame:amRect];
        UIButton *pmButton = [[UIButton alloc] initWithFrame:pmRect];
        
        [amButton setTitle:@"AM" forState:UIControlStateNormal];
        [pmButton setTitle:@"PM" forState:UIControlStateNormal];
        
        [amButton setTitleColor:RESPONDS_TO_USER_COLOR forState:UIControlStateNormal];
        [pmButton setTitleColor:RESPONDS_TO_USER_COLOR forState:UIControlStateNormal];
        
        [amButton addTarget:self action:@selector(amButtonTouch) forControlEvents:UIControlEventTouchUpInside];
        [pmButton addTarget:self action:@selector(pmButtonTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:amButton];
        [self addSubview:pmButton];
    }
    
    return self;
}

-(void) amButtonTouch;
{
    //NSLog(@"%s ",__PRETTY_FUNCTION__);
    self.isAM = YES;

    [self updateTimeDisplay];
    [self setNeedsDisplay];    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}
-(void) pmButtonTouch;
{
    //NSLog(@"%s ",__PRETTY_FUNCTION__);
    self.isAM = NO;

    [self updateTimeDisplay];
    [self setNeedsLayout];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void) updateTimeDisplay
{
    NSInteger hour;
    NSInteger minutes;
    
    NSInteger clockAngle = [self convertCircleAngleToClockAngle:self.angle];
    
    NSString *timeOfDay = @"PM";
    if (self.isAM)
    {
        timeOfDay = @"AM";
    }

    if (SNAP_TO_HALF_HOUR)
    {
        if (clockAngle > (345 + 7))  // handle edge condition for wrapping around 360 degrees to 0
        {
            hour = 12;
            minutes = 0;
        }
        else
        {
            NSInteger nearest15 = (clockAngle + 7) / 15;
            hour = nearest15 / 2;
            minutes = 0;
            if (nearest15 % 2 != 0 )
            {
                minutes = 30;
            }        
        }
    }
    else
    {
        // There are 12 divisions, so every 30 degrees = one major tick (1:00, 2:00, 3:00 = 3*30 = 90 degrees)
        hour = clockAngle / 30;
        // figure out the minutes...if 30 degrees between hours and 60 minutes, each degree = 2 minutes.
        minutes =  (clockAngle - (hour * 30) ) * 2;
    }

    if (hour < 1)
    {
        hour = 12;
    }
    
    _textField.text =  [NSString stringWithFormat:@"%d:%02d %@", hour, minutes, timeOfDay];
}


#pragma mark - UIControl Override -

/** Tracking is started **/
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    
    //Use the location to design the Handle
    [self movehandle:lastPoint];
    
    //Control value has changed, let's notify that
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    //We need to track continuously
    return YES;
}

/** Track continuous touch event (like drag) **/
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];

    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];

    //Use the location to design the Handle
    [self movehandle:lastPoint];
    
    //Control value has changed, let's notify any watchers
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

/** Track is finished **/
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
}


#pragma mark - Drawing Functions - 

//Use the draw rect to draw the Background, the Circle and the Handle 
-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //Draw the circle
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, 0, M_PI *2, 0);    
    CGContextSetLineWidth(ctx, TB_CIRCLE_WIDTH);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    [CIRCLE_COLOR setStroke];    
    CGContextDrawPath(ctx, kCGPathStroke);

    [self drawTicMarks];
    [self drawTheHandle:ctx];
}

-(void) drawTicMarks
{
    if ([TIC_MARK_COLOR isEqual:[UIColor clearColor]])
    {
        return; // if no tics, no work needed
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx, 1);
    [TIC_MARK_COLOR set];

    for (int x=0; x<360; x+=30)
    {
        CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        //The point position on the circumference
        CGPoint outerPoint;
        outerPoint.y = round(centerPoint.y + (radius - (TB_CIRCLE_WIDTH/2)) * sin(ToRad(-x)));
        outerPoint.x = round(centerPoint.x + (radius - (TB_CIRCLE_WIDTH/2)) * cos(ToRad(-x)));
        
        // A point slightly inset from the circumference
        CGPoint innerPoint;
        innerPoint.y = round(centerPoint.y + (radius - TIC_MARK_LENGTH) * sin(ToRad(-x)));
        innerPoint.x = round(centerPoint.x + (radius - TIC_MARK_LENGTH)  * cos(ToRad(-x)));
        
        // move to inner point, draw to outer point
        CGContextMoveToPoint(ctx, innerPoint.x, innerPoint.y);
        CGContextAddLineToPoint(ctx, outerPoint.x, outerPoint.y);      
    }
    
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
}

/** Draw a white knob over the circle **/
-(void) drawTheHandle:(CGContextRef)ctx{
    
    CGContextSaveGState(ctx);
    
    //I Love shadows [Yari]
    //Sorry, had to take them out to fit in with iOS7!  [Terry]
    //CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, [UIColor blackColor].CGColor);
    
    //Get the handle position
    CGPoint handleCenter =  [self pointFromAngle: self.angle];
    
    [RESPONDS_TO_USER_COLOR set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, TB_HANDLESIZE, TB_HANDLESIZE));
    
    CGContextRestoreGState(ctx);
}


#pragma mark - Math -

-(NSInteger) convertCircleAngleToClockAngle:(NSInteger)circleAngle;
{
    // flip angle direction CCW to CW
    NSInteger cwAngle = 360 - circleAngle;
    
    // rotate through 90 so that 0 is straight up
    NSInteger adjusted90 = cwAngle + 90;
    
    if (adjusted90 > 359)
    {
        adjusted90 = adjusted90 - 360;
    }
    
    return adjusted90;
}

-(NSInteger) convertClockAngleToCircleAngle:(NSInteger)clockAngle;
{
    // reverse the previous calculations
    NSInteger adjusted90 = clockAngle - 90;    
    NSInteger ccwAngle = 360 - adjusted90;    
    return ccwAngle;
}

/** Move the Handle **/
-(void)movehandle:(CGPoint)lastPoint{
    
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //Calculate the direction from a center point and a arbitrary position.
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floor(currentAngle);
    
    self.angle = 360 - angleInt;    // 0 angle = 3:00

    [self updateTimeDisplay];
    [self setNeedsDisplay];
}

/** Given the angle, get the point position on circumference **/
-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - TB_HANDLESIZE/2, self.frame.size.height/2 - TB_HANDLESIZE/2);
    
    //The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(-angleInt))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(-angleInt)));
    
    return result;
}

//Sourcecode from Apple example clockControl 
//Calculate the direction in degrees from a center point to an arbitrary position.
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    //NSLog(@"anglefromnorth result:%f",result);
    return (result >=0  ? result : result + 360.0);
}

#pragma mark - Public Methods to set/get values

-(void) setTime:(NSInteger)hour withMinutes:(NSInteger)minutes isInAM:(BOOL)isAM;
{
    NSInteger clockAngle = (hour * 30) + (minutes/2);
    NSInteger circleAngle = [self convertClockAngleToCircleAngle:clockAngle];    
    self.angle = circleAngle;
    
    self.isAM = isAM;
    
    [self updateTimeDisplay];
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];    
}

-(NSTimeInterval) getTimeAsSecondsFromMidnight;
{
    NSTimeInterval results;    
    NSInteger hour;
    NSInteger minutes;
    
    NSInteger clockAngle = [self convertCircleAngleToClockAngle:self.angle];
    
    if (SNAP_TO_HALF_HOUR)
    {
        if (clockAngle > (345 + 7))  // handle edge condition for wrapping around 360 degrees to 0
        {
            hour = 12;
            minutes = 0;
        }
        else
        {
            NSInteger nearest15 = (clockAngle + 7) / 15;
            hour = nearest15 / 2;
            minutes = 0;
            if (nearest15 % 2 != 0 )
            {
                minutes = 30;
            }
        }
    }
    else
    {
        // There are 12 divisions, so every 30 degrees = one major tick (1:00, 2:00, 3:00 = 3*30 = 90 degrees)
        hour = clockAngle / 30;
        minutes =  (clockAngle - (hour * 30) ) * 2;
    }
    
    if (!self.isAM)
    {
        hour = hour + 12;
    }
    
    results = (hour * 60) + minutes;    
    return results;
}

@end
