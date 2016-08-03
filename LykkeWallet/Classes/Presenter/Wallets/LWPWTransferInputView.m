//
//  LWPWTransferInputView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 25/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPWTransferInputView.h"

#define TEXT_COLOR [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]

@interface LWPWTransferInputView()
{
    UILabel *titleLabel;
    UILabel *currencyLabel;
}

@end

@implementation LWPWTransferInputView

-(id) init
{
    self=[super init];
    self.clipsToBounds=YES;
    
    self.backgroundColor=[UIColor colorWithRed:234.0/255 green:237.0/255 blue:239.0/255 alpha:1];
    self.layer.borderColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1].CGColor;
    self.layer.borderWidth=0.5;
    
    titleLabel=[[UILabel alloc] init];
    titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    titleLabel.textColor=TEXT_COLOR;
    titleLabel.text=@"Amount";
    [titleLabel sizeToFit];
    [self addSubview:titleLabel];
    
    currencyLabel=[[UILabel alloc] init];
    currencyLabel.font=[UIFont fontWithName:@"ProximaNova-Light" size:22.5];
    currencyLabel.textColor=TEXT_COLOR;
    [self addSubview:currencyLabel];
    
    self.textField=[[UITextField alloc] init];
    self.textField.textColor=TEXT_COLOR;
    self.textField.font=currencyLabel.font;
    self.textField.textAlignment=NSTextAlignmentRight;
    [self addSubview:self.textField];
    
    return self;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:CGRectMake(frame.origin.x-0.5, frame.origin.y, frame.size.width+1, frame.size.height)];
    [self alignSubviews];
}

-(void) setAmountString:(NSString *)amountString
{
    _amountString=amountString;
    self.textField.text=amountString;
}


-(void) alignSubviews
{
    titleLabel.center=CGPointMake(30+titleLabel.bounds.size.width/2, self.frame.size.height/2);
    self.textField.frame=CGRectMake(titleLabel.frame.origin.x+titleLabel.bounds.size.width+30, 0, self.bounds.size.width-(titleLabel.frame.origin.x+titleLabel.bounds.size.width+30)-30, self.frame.size.height);

}



@end
