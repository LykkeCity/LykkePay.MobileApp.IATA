//
//  LWWalletsNavigationBar.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWalletsNavigationBar.h"
#import "LWWalletsTypeButton.h"

@interface LWWalletsNavigationBar()
{
    UIView *backView;
    LWWalletsTypeButton *buttonTrading;
    LWWalletsTypeButton *buttonPrivate;
}

@end

@implementation LWWalletsNavigationBar



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backView=[[UIView alloc] init];
        backView.backgroundColor=[UIColor whiteColor];
        
        buttonTrading=[[LWWalletsTypeButton alloc] initWithTitle:@"TRADING"];
        [buttonTrading addTarget:self action:@selector(walletButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonTrading];
        
        buttonPrivate=[[LWWalletsTypeButton alloc] initWithTitle:@"PRIVATE"];
        [self addSubview:buttonPrivate];
        [buttonPrivate addTarget:self action:@selector(walletButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        
        buttonTrading.selected=YES;
        
        

        // Do any additional setup
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize s = [super sizeThatFits:size];
    s.height = 56;
    return s;

}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGRect rect=self.frame;
    rect.size.height=56;
    backView.frame=rect;
    buttonTrading.center=CGPointMake(rect.size.width/3, 25);
    buttonPrivate.center=CGPointMake(rect.size.width*0.666, 25);
}

-(void) walletButtonPressed:(UIButton *) button
{
    if(button.selected)
        return;
    buttonTrading.selected=NO;
    buttonPrivate.selected=NO;
    button.selected=YES;
    if(button==buttonPrivate)
        [self.delegate performSelector:@selector(walletsNavigationBarPressedPrivateWallets) withObject:nil];
    else
        [self.delegate performSelector:@selector(walletsNavigationBarPressedTradingWallets) withObject:nil];
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}


@end
