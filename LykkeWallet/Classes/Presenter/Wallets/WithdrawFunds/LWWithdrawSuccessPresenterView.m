//
//  LWWithdrawSuccessPresenterView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWithdrawSuccessPresenterView.h"
#import "Macro.h"

@implementation LWWithdrawSuccessPresenterView

-(id) initWithFrame:(CGRect)frame
{
    self=[super initWithFrame: frame];
    
    self.backgroundColor=[UIColor whiteColor];
    
    UIView *container=[[UIView alloc] init];
    
    CGFloat offset=0;
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width*0.4, self.bounds.size.width*0.4)];
    imageView.center=CGPointMake(self.bounds.size.width/2, imageView.bounds.size.height/2);
    imageView.image=[UIImage imageNamed:@"WithdrawSuccessFlag.png"];
    [container addSubview:imageView];
    
    offset+=imageView.bounds.size.height*1.3;
    
    
    UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(0, offset, self.bounds.size.width, 30)];
    
    title.font=[UIFont boldSystemFontOfSize:20];
    title.text=Localize(@"wallets.currency.withdraw.success.title");
    title.textColor=[UIColor blackColor];
    title.textAlignment=NSTextAlignmentCenter;
    [container addSubview:title];
    
    offset+=title.bounds.size.height+40;
    
    UILabel *text=[[UILabel alloc] init];
    text.font=[UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    text.textColor=[UIColor colorWithWhite:90.0/255 alpha:1];
    text.numberOfLines=0;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:Localize(@"wallets.currency.withdraw.success.text")];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 1.2;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    
    text.attributedText = attributedString;
    
    [text sizeToFit];
    
    [container addSubview:text];
    
    text.center=CGPointMake(self.bounds.size.width/2, offset+text.bounds.size.height/2);
    offset+=text.bounds.size.height;
    
    
    [self addSubview:container];
    
    container.frame=CGRectMake(0, 0, self.bounds.size.width, offset);
    
    container.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height*0.4);
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(30, self.bounds.size.height-45-40, self.bounds.size.width-60, 45);
    [button setBackgroundImage:[UIImage imageNamed:@"ButtonOK_square.png"] forState:UIControlStateNormal];
    [button setTitle:@"RETURN TO WALLET" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(returnToWalletPressed) forControlEvents:UIControlEventTouchUpInside];
    
    button.layer.cornerRadius=button.bounds.size.height/2;
    button.clipsToBounds=YES;
    [self addSubview:button];
    
    
    return self;
}

-(void) returnToWalletPressed
{
    if([self.delegate respondsToSelector:@selector(withdrawSuccessPresenterViewPressedReturn:)])
    {
        [self.delegate withdrawSuccessPresenterViewPressedReturn:self];
    }
}

@end
