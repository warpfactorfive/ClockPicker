//
//  TBCircularSlider.h
//  TB_CircularSlider
//
//  Created by Yari Dareglia on 1/12/13.
//  Copyright (c) 2013 Yari Dareglia. All rights reserved.
//
//  Modified into ClockPicker by Terry Grossman 9/27/2013
//  www.facebook.com/warpfactorfive
//  

// Sample Useage:
//  //Create the control
//  ClockPicker *slider = [[ClockPicker alloc]initWithFrame:CGRectMake(0,0, 200, 200)];
//
//  //Define Target-Action behaviour
//  [slider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
//
//  [slider setTime:6 withMinutes:30 isInAM:NO];
//
//  [self.view addSubview:slider];  // The control needs to be displayed in a container like a pop up

#import <UIKit/UIKit.h>

/** Parameters **/

//The size of the slider control area is determined by the frame it is drawn in
#define TB_CIRCLE_WIDTH         10
#define TB_HANDLESIZE           30

#define TB_FONTSIZE     24                              //The size of the textfield font
#define TB_FONTFAMILY @"Futura-CondensedExtraBold"  //The font family of the textfield font

#define SNAP_TO_HALF_HOUR  YES

// define colors used to draw control.
// The 'RESPONDS_TO_USER_COLOR' is the color for the handle and AM/PM Buttons
#define CIRCLE_COLOR              [UIColor whiteColor]
#define RESPONDS_TO_USER_COLOR    [UIColor blueColor]
#define TIME_STRING_COLOR         [UIColor whiteColor]
#define CONTROL_BACKGROUND_COLOR  [UIColor lightGrayColor]
#define CONTROL_BORDER_COLOR      [UIColor clearColor]
#define TIC_MARK_COLOR            [UIColor blackColor]
#define TIC_MARK_LENGTH           25

@interface ClockPicker : UIControl

@property (nonatomic,assign) int angle;
@property (nonatomic,assign) BOOL isAM;

-(void) setTime:(NSInteger)hour withMinutes:(NSInteger)minutes isInAM:(BOOL)isAM;
-(NSTimeInterval) getTimeAsSecondsFromMidnight;

@end
