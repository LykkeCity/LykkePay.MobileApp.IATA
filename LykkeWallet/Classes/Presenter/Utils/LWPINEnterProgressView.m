//
//  LWPINEnterProgressView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPINEnterProgressView.h"

@interface LWPINEnterProgressView()
{
    NSMutableArray *pointViews;
}

@end

@implementation LWPINEnterProgressView

-(void) awakeFromNib
{
    pointViews=[[NSMutableArray alloc] init];
    
    CGFloat dist=(self.bounds.size.width-12*4)/3;
    for(int i=0;i<4;i++)
    {
        UIView *v=[[UIView alloc] initWithFrame:CGRectMake(i*(dist+12), 0, 12, 12)];
        v.layer.cornerRadius=6;
        v.clipsToBounds=YES;
        [self addSubview:v];
        [pointViews addObject:v];
        v.backgroundColor=[UIColor colorWithRed:234.0/255 green:237.0/255 blue:239.0/255 alpha:1];
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    CGFloat dist=(self.bounds.size.width-12*4)/3;
    for(int i=0;i<4;i++)
    {
        UIView *v=pointViews[i];
        v.frame=CGRectMake(i*(dist+12), 0, 12, 12);
    }

}

-(void) setNumberOfSymbols:(int)num
{
    for(int i=0;i<4;i++)
    {
        if(i<num)
            [pointViews[i] setBackgroundColor:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1]];
        else
            [pointViews[i] setBackgroundColor:[UIColor colorWithRed:234.0/255 green:237.0/255 blue:239.0/255 alpha:1]];


    }
}


@end
