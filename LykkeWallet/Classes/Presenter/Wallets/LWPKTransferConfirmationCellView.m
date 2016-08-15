//
//  LWPKTransferConfirmationCellView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 08/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPKTransferConfirmationCellView.h"

@interface LWPKTransferConfirmationCellView()
{
    UILabel *leftLabel;
    UILabel *rightLabel;
    UIView *lineView;
}

@end

@implementation LWPKTransferConfirmationCellView

- (id)init {
    self=[super init];
    
    leftLabel=[self createLabel];
    [self addSubview:leftLabel];
    
    rightLabel=[self createLabel];
    rightLabel.textAlignment=NSTextAlignmentRight;
    [self addSubview:rightLabel];
    rightLabel.numberOfLines=0;
    
    
    lineView=[[UIView alloc] init];
    lineView.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [self addSubview:lineView];
    
    return self;
}

-(void) setLeftText:(NSString *)leftText
{
    leftLabel.text=leftText;
    _leftText=leftText;
    [leftLabel sizeToFit];
}

-(void) setRightText:(NSString *)rightText
{
    rightLabel.text=rightText;
    _rightText=rightText;
}


-(UILabel *) createLabel
{
    UILabel *label=[[UILabel alloc] init];
    label.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    label.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    
    return label;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    CGFloat height=[self heightForWidth:self.bounds.size.width];
    leftLabel.center=CGPointMake(leftLabel.bounds.size.width/2+30, height/2);
    rightLabel.frame=CGRectMake(leftLabel.frame.origin.x+leftLabel.bounds.size.width+30, 0, self.bounds.size.width-(leftLabel.frame.origin.x+leftLabel.bounds.size.width+30)-60, height);
    lineView.frame=CGRectMake(30, height-0.5, self.bounds.size.width-60, 0.5);
}


-(CGFloat) heightForWidth:(CGFloat) width
{
    CGSize size=[rightLabel sizeThatFits:CGSizeMake(width-60-leftLabel.bounds.size.width-30, 0)];
    if(size.height<50)
        return 50;
    return size.height;
    
}



@end
