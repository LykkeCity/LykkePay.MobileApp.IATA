//
//  LWAssetLykkeTableViewCell.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetLykkeTableViewCell.h"
#import "LWAssetPairModel.h"
#import "LWAssetPairRateModel.h"
#import "LWConstants.h"
#import "LWColorizer.h"
#import "LWMath.h"

#import "LWAuthManager.h"


@implementation LWAssetLykkeTableViewCell {
    UITapGestureRecognizer *tapGestureRecognizer;
}

-(void) awakeFromNib
{
    self.assetReverseImageView.userInteractionEnabled=YES;
    self.leftAssetNameLabel.userInteractionEnabled=YES;
    self.rightAssetNameLabel.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reverse)];
    [self.assetReverseImageView addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reverse)];
    [self.leftAssetNameLabel addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reverse)];
    [self.rightAssetNameLabel addGestureRecognizer:gesture];
    
    
    self.leftAssetNameLabel.text=nil;
    self.rightAssetNameLabel.text=nil;
}

-(void) reverse
{
    [_rate invert];
    if(_rate)
    {
    [[LWAuthManager instance] requestSetReverted:_rate.inverted assetPairId:_rate.identity];
    
    [self setRate:_rate];
    }
}

- (void)setRate:(LWAssetPairRateModel *)rate {
    _rate = rate;
    
    if(_pair && _rate)
        [self setAssetNames];
    else
    {
        self.assetPriceLabel.text = @". . .";
        self.assetPriceLabel.textColor = [UIColor colorWithHexString:kAssetDisabledItemColor];
        self.assetChangeLabel.text = @". . .";
        self.assetChangeLabel.textColor = [UIColor colorWithHexString:kMainDarkElementsColor];
        self.assetPriceImageView.image = [UIImage imageNamed:@"AssetPriceDisabledArea"];

    }

    
    [self.assetChangeView setChanges:rate.lastChanges];
    [self.assetChangeView setNeedsDisplay];
    
    if (self.rate && self.pair) {
        // price section
        NSString *priceString = [LWMath priceString:rate.ask precision:self.pair.accuracy withPrefix:@""];
        self.assetPriceLabel.text = priceString;
        self.assetPriceLabel.textColor = [UIColor colorWithHexString:kAssetEnabledItemColor];

        // change section
        NSString *sign = (rate.pchng.doubleValue >= 0.0) ? @"+" : @"";
        NSString *changeString = [LWMath priceString:rate.pchng precision:[NSNumber numberWithInt:2] withPrefix:sign];

        UIColor *changeColor = (rate.pchng.doubleValue >= 0.0)
                                ? [UIColor colorWithHexString:kAssetChangePlusColor]
                                : [UIColor colorWithHexString:kAssetChangeMinusColor];
        self.assetChangeLabel.textColor = changeColor;
        self.assetChangeLabel.text = [NSString stringWithFormat:@"%@%%", changeString];
        
        self.assetPriceImageView.image = [UIImage imageNamed:@"AssetPriceArea"];
    }
}

- (void)setPair:(LWAssetPairModel *)pair {
    _pair = pair;
    
    if(_pair && _rate)
        [self setAssetNames];
    
//    self.assetNameLabel.text = pair.name;
    
    
    if (!tapGestureRecognizer) {
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(graphClicked)];
        [self.assetChangeView addGestureRecognizer:tapGestureRecognizer];
    }
}

-(void) setAssetNames
{
    if(_pair.inverted != _rate.inverted)
        _pair.inverted=_rate.inverted;
    NSArray *arr=[_pair.name componentsSeparatedByString:@"/"];
    if(arr.count==2)
    {
        if(_rate.inverted==NO)
        {
            self.leftAssetNameLabel.text=arr[0];
            self.rightAssetNameLabel.text=arr[1];
        }
        else
        {
            self.leftAssetNameLabel.text=arr[1];
            self.rightAssetNameLabel.text=arr[0];
            
        }
    }
}

- (void)graphClicked {
    
    CGRect rrr=self.assetPriceImageView.frame;
    CGRect rr1=self.frame;
    
    if (self.rate) {
        [self.delegate graphClicked:self];
    }
}

@end
