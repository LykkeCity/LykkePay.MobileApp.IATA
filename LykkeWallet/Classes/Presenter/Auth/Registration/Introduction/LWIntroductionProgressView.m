//
//  LWIntroductionProgressView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWIntroductionProgressView.h"

#define DOTS_COUNT 5

@interface LWIntroductionProgressView()
{
    NSMutableArray *dots;
}

@end

@implementation LWIntroductionProgressView

-(void) awakeFromNib
{
    dots=[[NSMutableArray alloc] init];
    CGFloat interval=self.bounds.size.width/DOTS_COUNT;
    for(int i=0;i<DOTS_COUNT;i++)
    {
        UIView *dot=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
        dot.layer.cornerRadius=dot.bounds.size.height/2;
        dot.center=CGPointMake(interval*i+interval/2, self.bounds.size.height/2);
        [self addSubview:dot];
        [dots addObject:dot];
    }
    
    self.backgroundColor=[UIColor whiteColor];

}

-(void) layoutSubviews
{
    [super layoutSubviews];
    CGFloat interval=self.bounds.size.width/DOTS_COUNT;
    for(int i=0;i<DOTS_COUNT;i++)
    {
        UIView *dot=dots[i];
        dot.center=CGPointMake(interval*i+interval/2, self.bounds.size.height/2);
    }

}


-(void) setActiveDot:(int) num
{
    for(UIView *v in dots)
        v.backgroundColor=[UIColor colorWithWhite:216.0/255 alpha:1];
    UIView *dot=dots[num];
    dot.backgroundColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
}


@end
