//
//  LWWithdrawCurrencyCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWithdrawCurrencyCell.h"

@interface LWWithdrawCurrencyCell() <UITextViewDelegate>
{
    UILabel *titleLabel;
    UITextView *textField;
    UIView *lineView;

}

@end

@implementation LWWithdrawCurrencyCell

-(id) initWithWidth:(CGFloat)width title:(NSString *) title placeholder:(NSString *) placeholder addBottomLine:(BOOL)flagLine
{
    self=[super initWithFrame:CGRectMake(0, 0, width, 0)];
    
//    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(30, 0, self.scrollView.bounds.size.width-60, 0)];
    self.backgroundColor=nil;
    self.opaque=NO;
    
    titleLabel=[[UILabel alloc] init];
    titleLabel.font=[UIFont systemFontOfSize:14];
    titleLabel.textColor=[UIColor grayColor];
    titleLabel.numberOfLines=0;
    titleLabel.text=title;
    [self addSubview:titleLabel];
    
    textField=[[UITextView alloc] init];
    textField.font=[UIFont systemFontOfSize:16];
    textField.textColor=[UIColor blackColor];
    textField.delegate=self;
    //    textField.numberOfLines=0;
    textField.text=placeholder;
    textField.scrollEnabled=NO;
    
    [self addSubview:textField];
    
    if(flagLine)
    {
        lineView=[[UIView alloc] initWithFrame:CGRectMake(30, 0, self.bounds.size.width-60, 1)];
        lineView.backgroundColor=[UIColor colorWithWhite:0.92 alpha:1];
        [self addSubview:lineView];
    }
    
    [self adjustSize];
    
    return self;
}

-(void) adjustSize
{
    CGFloat prevHeight=self.bounds.size.height;
    CGFloat height=0;
    
    CGFloat minHeight=50;
    CGFloat titleWidth=80;
    CGSize titleSize=[titleLabel sizeThatFits:CGSizeMake(titleWidth, 0)];
    if(titleSize.height>height)
        height=titleSize.height;
    CGSize textSize=[textField sizeThatFits:CGSizeMake(self.bounds.size.width-titleWidth-20-60, 0)];
    if(textSize.height>height)
        height=textSize.height;
    
    height+=20;
    
    if(height<minHeight)
        height=minHeight;
    
    [UIView animateWithDuration:0.3 animations:^{
        titleLabel.frame=CGRectMake(30, 0, titleWidth, titleSize.height);
        textField.frame=CGRectMake(30+titleWidth+20, 0, self.bounds.size.width-titleWidth-20-60, textSize.height);
        
        titleLabel.center=CGPointMake(titleLabel.center.x, height/2);
        textField.center=CGPointMake(textField.center.x, height/2);
        
        self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, height);
        if(lineView)
            lineView.center=CGPointMake(self.bounds.size.width/2, height-1);
        
        }];

    [self.delegate withdrawCurrencyCell:self changedHeightFrom:prevHeight to:height];
}

-(NSString *) text
{
    return textField.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *sss=[textView.text stringByReplacingCharactersInRange:range withString:text];
    textView.text=sss;
    [self adjustSize];
    
    return NO;
}

@end
