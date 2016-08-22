//
//  LWNumbersKeyboardView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWNumbersKeyboardView.h"
#import "LWNumbersKeyboardViewCell.h"

#define STEP 0.5

@interface LWNumbersKeyboardView() <LWNumbersKeyboardViewCellDelegate>
{
    UIView *topBarView;
    UIButton *doneButton;
    NSMutableArray *buttonViews;
}


@end

@implementation LWNumbersKeyboardView

-(id) init
{
    self=[super init];
    self.clipsToBounds=YES;
    self.userInteractionEnabled=YES;
    self.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    
    topBarView=[[UIView alloc] init];
    topBarView.backgroundColor=[UIColor colorWithRed:244.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    doneButton=[UIButton buttonWithType:UIButtonTypeCustom];
    NSDictionary *attributes=@{NSKernAttributeName:@(0.5), NSForegroundColorAttributeName:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14]};
    NSAttributedString *str=[[NSAttributedString alloc] initWithString:@"DONE" attributes:attributes];
    [doneButton setAttributedTitle:str forState:UIControlStateNormal];
    [doneButton addTarget:self.delegate action:@selector(numbersKeyboardViewPressedDone) forControlEvents:UIControlEventTouchUpInside];
    
    [doneButton sizeToFit];
    [topBarView addSubview:doneButton];
    [self addSubview:topBarView];
    
    buttonViews=[[NSMutableArray alloc] init];
    
    
    for(int i=1;i<=12;i++)
    {
        LWNumbersKeyboardViewCell *view=[[LWNumbersKeyboardViewCell alloc] init];
        view.delegate=self;
        view.tag=0;
        view.backgroundColor=[UIColor whiteColor];
        UILabel *label=[[UILabel alloc] init];
        
        label.font=[UIFont fontWithName:@"ProximaNova-Light" size:40];
        label.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
        if(i<10)
        {
            label.text=[@(i) stringValue];
            view.tag=i;
        }
        else if(i==11)
        {
            label.text=@"0";
            view.tag=10;
        }
        else if(i==12)
        {
            UIImageView *backArrow=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 23)];
            backArrow.image=[UIImage imageNamed:@"PINArrowBack"];
            [view addSubview:backArrow];
        }
        
        [label sizeToFit];
        
        if(view.tag>0)
            [view addSubview:label];
        
        [buttonViews addObject:view];
        [self addSubview:view];
        
        
        
    }
    
    //
    
    
    return self;
}



-(void) layoutSubviews
{
    [super layoutSubviews];
    CGSize size=self.bounds.size;
    
    topBarView.frame=CGRectMake(0,STEP, size.width, 40-STEP*2);
    
    CGFloat width=(size.width-STEP*2)/3;
    CGFloat height=(size.height-(topBarView.bounds.size.height+STEP*2)-STEP*3)/4;
    
    for(int i=0;i<12;i++)
    {
        
        CGFloat x=(float)(i%3)*(width+STEP);
        CGFloat y=(float)(i/3)*(height+STEP)+topBarView.bounds.size.height+STEP*2;
        UIView *vvv=buttonViews[i];
        vvv.frame=CGRectMake(x, y, width, height);
        for(UIView *v in vvv.subviews)
        {
//            if([v isKindOfClass:[UILabel class]])
                v.center=CGPointMake(width/2, height/2);
        }
        
    }
    
    doneButton.center=CGPointMake(topBarView.bounds.size.width-doneButton.bounds.size.width/2-27, topBarView.bounds.size.height/2);
    
    
}

-(void) numberCellPressedSymbol:(NSString *)symbol
{
    self.textField.text=[self.textField.text stringByAppendingString:symbol];
    [self.delegate numbersKeyboardChangedText];
}

-(void) numberCellPressedBackspace
{
    if(self.textField.text.length)
    {
        self.textField.text=[self.textField.text substringToIndex:self.textField.text.length-1];
        [self.delegate numbersKeyboardChangedText];
    }
}








@end
