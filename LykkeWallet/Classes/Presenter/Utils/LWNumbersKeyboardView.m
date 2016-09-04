//
//  LWNumbersKeyboardView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWNumbersKeyboardView.h"
#import "LWNumbersKeyboardViewCell.h"
#import "LWMathKeyboardCursorView.h"



@interface LWNumbersKeyboardView() <LWNumbersKeyboardViewCellDelegate>
{
    UIView *topBarView;
    UIButton *doneButton;
    NSMutableArray *buttonViews;
    BOOL shouldShowTopBarView;
    BOOL shouldShowDotButton;
    BOOL shouldShowPredefinedSums;
    BOOL shouldShowSeparators;
    UILabel *dotLabel;
    LWMathKeyboardCursorView *cursor;
    NSMutableArray *predefinedSumButtons;
    
    CGFloat STEP;
}


@end

@implementation LWNumbersKeyboardView

-(id) init
{
    self=[super init];
    
    [self firstInit];
    
    
    return self;
}

-(void) awakeFromNib
{
    [self firstInit];
}

-(void) firstInit
{
    shouldShowTopBarView=YES;
    
    self.clipsToBounds=YES;
    self.userInteractionEnabled=YES;
    shouldShowDotButton=NO;
    shouldShowPredefinedSums=NO;
    shouldShowSeparators=YES;
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
    
    NSArray *predefined=@[@"100", @"1000", @"10000"];
    predefinedSumButtons=[[NSMutableArray alloc] init];
    for(int i=0;i<3;i++)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:predefined[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1] forState:UIControlStateNormal];
        button.titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
        [topBarView addSubview:button];
        button.tag=[predefined[i] intValue];
        [button addTarget:self action:@selector(predefinedSumPressed:) forControlEvents:UIControlEventTouchUpInside];
        [predefinedSumButtons addObject:button];
    }
    
    
    for(int i=1;i<=12;i++)
    {
        LWNumbersKeyboardViewCell *view=[[LWNumbersKeyboardViewCell alloc] init];
        view.delegate=self;
        view.tag=0;
        view.backgroundColor=[UIColor whiteColor];
        UILabel *label=[[UILabel alloc] init];
        int fontSize=40;
        if([UIScreen mainScreen].bounds.size.width==320)
            fontSize=30;

        label.font=[UIFont fontWithName:@"ProximaNovaT-Thin" size:fontSize];
        label.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
        if(i<10)
        {
            label.text=[@(i) stringValue];
            view.tag=i;
        }
        else if(i==10)
        {
            label.text=@".";
            dotLabel=label;
            dotLabel.hidden=!shouldShowDotButton;
            view.tag=11;
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
    
    

}

-(void) removeFromSuperview
{
    [super removeFromSuperview];
    [cursor removeFromSuperview];
}

-(void) setShowSeparators:(BOOL)showSeparators
{
    shouldShowSeparators=showSeparators;
    [self layoutSubviews];
}

-(BOOL) showSeparators
{
    return shouldShowSeparators;
}



-(void) setTextField:(UITextField *)textField
{
    _textField=textField;
    [cursor removeFromSuperview];
    if(shouldShowDotButton)
    {
        cursor=[[LWMathKeyboardCursorView alloc] init];
        CGPoint point=CGPointMake(_textField.bounds.size.width+3, _textField.bounds.size.height/2);
        point=[_textField.superview convertPoint:point fromView:_textField];
        cursor.center=point;
        [textField.superview addSubview:cursor];
    }
}

-(void) setShowDoneButton:(BOOL)showDoneButton
{
    shouldShowTopBarView=showDoneButton;
    [self layoutSubviews];
}

-(BOOL) showDoneButton
{
    return shouldShowTopBarView;
}

-(void) setShowDotButton:(BOOL)showDotButton
{
    dotLabel.hidden=!showDotButton;
    shouldShowDotButton=showDotButton;
}

-(void) setShowPredefinedSums:(BOOL)showPredefinedSums
{
    shouldShowPredefinedSums=showPredefinedSums;
    [self layoutSubviews];
}

-(BOOL) showPredefinedSums
{
    return shouldShowPredefinedSums;
}



-(BOOL) showDotButton
{
    return shouldShowDotButton;
}



-(void) predefinedSumPressed:(UIButton *) button
{
    self.textField.text=[NSString stringWithFormat:@"%d", (int)button.tag];
    [self.delegate numbersKeyboardChangedText:self];
}



-(void) layoutSubviews
{
    [super layoutSubviews];
    CGSize size=self.bounds.size;
    if(shouldShowSeparators)
        STEP=0.5;
    else
        STEP=0;
    
    topBarView.frame=CGRectMake(0,STEP, size.width, 40-STEP*2);
    if(shouldShowTopBarView==NO)
    {
        topBarView.frame=CGRectMake(0, 0, size.width, 0);
        topBarView.hidden=YES;
    }
    
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
    

    CGFloat widthOfButton=topBarView.bounds.size.width/4;
    for(int i=0;i<3;i++)
    {
        UIButton *button=predefinedSumButtons[i];
        button.frame=CGRectMake(widthOfButton*i, 0, widthOfButton, topBarView.bounds.size.height);
        button.hidden=!shouldShowPredefinedSums;
            
    }
    
    doneButton.center=CGPointMake(topBarView.bounds.size.width-doneButton.bounds.size.width/2-27, topBarView.bounds.size.height/2);
    
    
}

-(void) numberCellPressedSymbol:(NSString *)symbol
{
    if(shouldShowDotButton==NO)
    {
        if([symbol isEqualToString:@"."])
            return;
        self.textField.text=[self.textField.text stringByAppendingString:symbol];
    }
    else
    {
        if([symbol isEqualToString:@"."])
        {
            
            if([self.textField.text rangeOfString:@"."].location!=NSNotFound || self.accuracy==0)
                return;
            
        }
        NSString *prev=self.textField.text;
        if(self.prefix)
            prev=[prev stringByReplacingOccurrencesOfString:_prefix withString:@""];
        
        if([prev isEqualToString:@"0"] && [symbol isEqualToString:@"."]==NO)
            prev=@"";
        prev=[prev stringByAppendingString:symbol];
        NSArray *arr=[prev componentsSeparatedByString:@"."];
        if(arr.count==2 && [arr[1] length]==self.accuracy+1)
        {
            return;
        }
        
        if(_prefix)
            self.textField.text=[_prefix stringByAppendingString:prev];
        else
            self.textField.text=prev;
    }
    if([self.delegate respondsToSelector:@selector(numbersKeyboardChangedText:)])
        [self.delegate numbersKeyboardChangedText:self];
}

-(void) numberCellPressedBackspace
{
    if(self.textField.text.length==0)
        return;
    if(shouldShowDotButton==NO)
    {
        self.textField.text=[self.textField.text substringToIndex:self.textField.text.length-1];
    }
    else
    {
        NSString *prev=self.textField.text;
        if(_prefix)
        {
            prev=[prev stringByReplacingOccurrencesOfString:_prefix withString:@""];
        }
        
        prev=[prev substringToIndex:prev.length-1];
        if(prev.length==0)
            prev=@"0";
        
        if(_prefix)
            self.textField.text=[_prefix stringByAppendingString:prev];
        else
            self.textField.text=prev;

    }
    
    
    if([self.delegate respondsToSelector:@selector(numbersKeyboardChangedText:)])
        [self.delegate numbersKeyboardChangedText:self];
    
}








@end
