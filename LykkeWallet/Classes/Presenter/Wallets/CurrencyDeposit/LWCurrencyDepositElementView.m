//
//  LWCurrencyDepositElementView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCurrencyDepositElementView.h"

@interface LWCurrencyDepositElementView()
{
    UILabel *textLabel;
    
    UIButton *copyButton;
    UILabel *titleLabel;
    UIView *lineView;
}

@end

@implementation LWCurrencyDepositElementView

-(id) initWithTitle:(NSString *) title text:(NSString *) text
{
    self=[super init];
    
    
    
    titleLabel=[[UILabel alloc] init];
    titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    titleLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.6];
    titleLabel.numberOfLines=0;
    titleLabel.text=title;
    [self addSubview:titleLabel];
    
    
    
    textLabel=[[UILabel alloc] init];
    textLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:16];
    textLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    textLabel.numberOfLines=0;
    textLabel.text=text;
    
    [self addSubview:textLabel];
    
    copyButton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    
    [copyButton setBackgroundImage:[UIImage imageNamed:@"CopyInDepositIcon"] forState:UIControlStateNormal];
    [copyButton addTarget:self action:@selector(copyPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:copyButton];
    
    lineView=[[UIView alloc] init];
    lineView.backgroundColor=[UIColor colorWithWhite:216.0/255 alpha:1];
    [self addSubview:lineView];
    
    return self;
}

-(void) copyPressed
{
    [self.delegate elementViewCopyPressed:self];
}


-(void) setWidth:(CGFloat) width
{
    self.frame=CGRectMake(0, 0, width, 0);
    CGFloat height=0;
    
    CGFloat minHeight=50;
    CGFloat titleWidth=80;
    CGFloat copyIconWidth=25;

    
    CGSize size=[titleLabel sizeThatFits:CGSizeMake(titleWidth, 0)];
    if(size.height>height)
        height=size.height;

    size=[textLabel sizeThatFits:CGSizeMake(self.bounds.size.width-titleWidth-20-(copyIconWidth+10), 0)];
    if(size.height>height)
        height=size.height;

    copyButton.frame=CGRectMake(0, 0, copyIconWidth, copyIconWidth);

    height+=20;
    
    if(height<minHeight)
        height=minHeight;
    
    titleLabel.frame=CGRectMake(0, 0, titleWidth, height);
    textLabel.frame=CGRectMake(titleWidth+20, 0, self.bounds.size.width-titleWidth-20-(copyIconWidth+10), height);
    
    titleLabel.center=CGPointMake(titleLabel.center.x, height/2);
    textLabel.center=CGPointMake(textLabel.center.x, height/2);
    
    copyButton.center=CGPointMake(self.bounds.size.width-copyButton.bounds.size.width/2, height/2);
    
    
    self.frame=CGRectMake(self.frame.origin.x, 0, self.bounds.size.width, height);
    
    lineView.frame=CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 1);
}


@end
