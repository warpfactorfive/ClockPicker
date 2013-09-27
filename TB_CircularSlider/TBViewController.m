//
//  TBViewController.m
//  TB_CircularSlider
//
//  Created by Yari Dareglia on 1/12/13.
//  Copyright (c) 2013 Yari Dareglia. All rights reserved.
//

#import "TBViewController.h"
#import "ClockPicker.h"

#define TB_SLIDER_SIZE          200

@interface TBViewController ()

@end

@implementation TBViewController

- (void)viewDidLoad
{
    NSLog(@"%s ",__PRETTY_FUNCTION__);

    [super viewDidLoad];
    
    //Create the Circular Slider
    ClockPicker *slider = [[ClockPicker alloc]initWithFrame:CGRectMake((320 - TB_SLIDER_SIZE)/2, (480 - TB_SLIDER_SIZE)/2, TB_SLIDER_SIZE, TB_SLIDER_SIZE)];
    
    //Define Target-Action behaviour
    [slider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    
    [slider setTime:6 withMinutes:30 isInAM:NO];
    
    [self.view addSubview:slider];
}

/** This function is called when Circular slider value changes **/
-(void)newValue:(ClockPicker*)slider{
    //TBCircularSlider *slider = (TBCircularSlider*)sender;
    NSLog(@"Slider %d = secondsFromMidnight:%f",slider.angle, [slider getTimeAsSecondsFromMidnight]);    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
