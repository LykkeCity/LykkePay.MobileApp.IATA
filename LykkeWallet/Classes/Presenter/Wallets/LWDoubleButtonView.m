//
//  LWDoubleButtonView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 23/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWDoubleButtonView.h"

@interface LWDoubleButtonView()
{
    UIButton *leftButton;
    UIButton *rightButton;
    UIView *middleLineView;
    UIImageView *background;
    
    UILabel *leftLabel;
    UILabel *rightLabel;
}

@end

@implementation LWDoubleButtonView

-(id) initWithTitles:(NSArray *) titles
{
    self=[super init];
    
    background=[[UIImageView alloc] init];
    background.image=[UIImage imageNamed:@"ButtonOK_square.png"];
    [self addSubview:background];
    
    leftLabel=[self createLabelWithText:titles[0]];
    [self addSubview:leftLabel];
    
    rightLabel=[self createLabelWithText:titles[1]];
    [self addSubview:rightLabel];
    
    
    leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:leftButton];
    rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:rightButton];
    
    middleLineView=[[UIView alloc] init];
    middleLineView.backgroundColor=[UIColor whiteColor];
    [self addSubview:middleLineView];
    
    return self;
}


-(UILabel *) createLabelWithText:(NSString *) text
{
    UILabel *label=[[UILabel alloc] init];
    label.textAlignment=NSTextAlignmentCenter;
    
    NSDictionary *attributes=@{NSForegroundColorAttributeName:[UIColor whiteColor], NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"PriximaNova-Semibold" size:15]};
    label.attributedText=[[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    return label;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    background.frame=self.bounds;
    self.layer.cornerRadius=self.bounds.size.height/2;
    leftLabel.frame=CGRectMake(0, 0, self.bounds.size.width/2, self.bounds.size.height);
    leftButton.frame=leftLabel.frame;
    rightLabel.frame=CGRectMake(self.bounds.size.width/2, 0, self.bounds.size.width/2, self.bounds.size.height);
    rightButton.frame=rightLabel.frame;
    middleLineView.frame=CGRectMake(self.bounds.size.width/2, 5, 1, self.bounds.size.height-10);
}

@end
