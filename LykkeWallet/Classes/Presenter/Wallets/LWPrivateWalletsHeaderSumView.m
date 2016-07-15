//
//  LWPrivateWalletsHeaderSumView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletsHeaderSumView.h"

@interface LWPrivateWalletsHeaderSumView()
{
    UILabel *titleLabel;
    UILabel *sumLabel;
}

@end

@implementation LWPrivateWalletsHeaderSumView

-(id) init
{
    self=[super init];
    
    self.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    titleLabel=[[UILabel alloc] init];
    NSDictionary *attributes=@{NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1],
                               NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14]};
    titleLabel.attributedText=[[NSAttributedString alloc] initWithString:@"Total value" attributes:attributes];
    
    titleLabel.frame=CGRectMake(30, 0, 200, 50);
    [self addSubview:titleLabel];
    sumLabel=[[UILabel alloc] init];
    [self addSubview:sumLabel];
    
    return self;
}


-(void) setTotal:(NSNumber *)total
{
    _total=total;
    NSDictionary *attributes=@{NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1],
                               NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:16]};
    sumLabel.attributedText=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"$ %.2f",total.floatValue] attributes:attributes];
    [sumLabel sizeToFit];

}

-(void) layoutSubviews
{
    [super layoutSubviews];
    sumLabel.center=CGPointMake(self.bounds.size.width-30-sumLabel.bounds.size.width/2, self.bounds.size.height/2);
    
}



@end
