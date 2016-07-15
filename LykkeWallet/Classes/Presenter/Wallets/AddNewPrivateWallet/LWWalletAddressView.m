//
//  LWWalletAddressView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWalletAddressView.h"

@interface LWWalletAddressView()
{
    UILabel *titleLabel;
    UILabel *addressLabel;
}

@end

@implementation LWWalletAddressView

-(id) initWithWidth:(CGFloat) width
{
    self=[super initWithFrame:CGRectMake(0, 0, width, 0)];
    
    titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, width, 18)];
    titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    titleLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.6];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    addressLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 38, width, 44)];
    addressLabel.numberOfLines=2;
    addressLabel.textAlignment=NSTextAlignmentCenter;
    addressLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    addressLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    [self addSubview:addressLabel];
    
    self.address=nil;
    
    return self;
}

-(void) setAddress:(NSString *)address
{
    if([address length])
    {
        addressLabel.text=address;
        addressLabel.hidden=NO;
        titleLabel.text=@"Wallet address";
        
        self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, 92);
    }
    else
    {
        addressLabel.hidden=YES;
        titleLabel.text=@"Wallet address is not defined";
        self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, 35);

    }
}



@end
