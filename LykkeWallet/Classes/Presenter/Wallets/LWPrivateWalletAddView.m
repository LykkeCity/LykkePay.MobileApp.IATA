//
//  LWPrivateWalletAddView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletAddView.h"
#import "Macro.h"

@implementation LWPrivateWalletAddView

-(id) init
{
    self=[super init];
    
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    if(window.bounds.size.width>320)
    {
        UILabel *label=[[UILabel alloc] init];
        NSDictionary *attributes=@{NSForegroundColorAttributeName:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1],
                                   NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size:14],
                                   NSKernAttributeName: @(0.5)};
        label.attributedText=[[NSAttributedString alloc] initWithString:Localize(@"privatewallets.addnew") attributes:attributes];
        [label sizeToFit];
        [self addSubview:label];
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 44/2-7, 14, 14)];
        imageView.image=[UIImage imageNamed:@"AddNewWallet"];
        [self addSubview:imageView];
        
        self.frame=CGRectMake(0, 0, imageView.bounds.size.width+label.bounds.size.width+5, 44);
        
        label.center=CGPointMake(self.bounds.size.width-label.bounds.size.width/2, self.bounds.size.height/2);
    }
    else
    {
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 44/2-8, 17, 17)];
        imageView.image=[UIImage imageNamed:@"AddNewWallet"];
        [self addSubview:imageView];
        
        self.frame=CGRectMake(0, 0, imageView.bounds.size.width, 44);

    }
    
    
    return self;
}


@end
