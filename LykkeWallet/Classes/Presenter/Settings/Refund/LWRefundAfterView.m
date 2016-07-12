//
//  LWRefundAfterView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/06/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRefundAfterView.h"
#import "LWCache.h"

@interface LWRefundAfterView()
{
    UISlider *slider;
    UILabel *dayLabel;
    UISwitch *sendSwitch;
    UILabel *sendLabel;
    UIView *middleLine;
}

@end

@implementation LWRefundAfterView


-(id) init
{
    self=[super init];
    slider=[[UISlider alloc] init];
    slider.tintColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    [slider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderFinishedChanging) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self addSubview:slider];
    
    dayLabel=[self createLabel];
    dayLabel.text=@"DAY";
    [self addSubview:dayLabel];
    
    sendSwitch=[[UISwitch alloc] init];
    [sendSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    sendSwitch.tintColor=[UIColor colorWithRed:199.0/255 green:203.0/255 blue:209.0/255 alpha:1];
    sendSwitch.backgroundColor=[UIColor colorWithRed:199.0/255 green:203.0/255 blue:209.0/255 alpha:1];
    sendSwitch.layer.cornerRadius = 16.0;
    [self addSubview:sendSwitch];
    
    sendLabel=[self createLabel];
    sendLabel.text=@"Send automatically";
    [self addSubview:sendLabel];
    
    middleLine=[[UIView alloc] init];
    middleLine.backgroundColor=[UIColor colorWithRed:53.0/255 green:76.0/255 blue:97.0/255 alpha:1];
    [self addSubview:middleLine];
    
    [self sliderChanged];
    
    return self;
}

-(void) switchChanged
{
    [LWCache instance].refundSendAutomatically=sendSwitch.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveRefundSettings" object:nil];

}

-(void) sliderChanged
{
    int day=[self daysValidAfter];
//    if(day==1)
//        dayLabel.text=[NSString stringWithFormat:@"%d DAY", day];
//    else
        dayLabel.text=[NSString stringWithFormat:@"%d DAYS", day];
    
    [dayLabel sizeToFit];
    
    slider.frame=CGRectMake(30, 10, self.frame.size.width-60-dayLabel.bounds.size.width-15, 30);
    dayLabel.center=CGPointMake(self.frame.size.width-30-dayLabel.bounds.size.width/2, self.frame.size.height/4);

}

-(void) sliderFinishedChanging
{
    [LWCache instance].refundDaysValidAfter=self.daysValidAfter;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveRefundSettings" object:nil];
}

-(void) setSendAutomatically:(BOOL)sendAutomatically
{
    sendSwitch.on=sendAutomatically;
}

-(BOOL) sendAutomatically
{
    return sendSwitch.on;
}

-(void) setDaysValidAfter:(int)daysValidAfter
{
    slider.value=(float)(daysValidAfter-14)/(60-14);
    [self sliderChanged];
}
-(int) daysValidAfter
{
    int day=slider.value*(60-14)+14;
    return day;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [dayLabel sizeToFit];
    
    
    slider.frame=CGRectMake(30, 10, frame.size.width-60-dayLabel.bounds.size.width-15, 30);
    dayLabel.center=CGPointMake(frame.size.width-30-dayLabel.bounds.size.width/2, frame.size.height/4);
    
    middleLine.frame=CGRectMake(30, frame.size.height/2, frame.size.width-60, 0.5);
    
    sendLabel.frame=CGRectMake(30, frame.size.height/2+10, frame.size.width-30-90, frame.size.height/2-20);
    
    sendSwitch.center=CGPointMake(frame.size.width-30-sendSwitch.bounds.size.width/2, frame.size.height*0.75);
    
}

-(UILabel *) createLabel
{
    UILabel *label=[[UILabel alloc] init];
    label.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    label.textColor=[UIColor colorWithRed:53.0/255 green:76.0/255 blue:97.0/255 alpha:1];
    label.backgroundColor=nil;
    label.opaque=NO;

    return label;
}

@end
