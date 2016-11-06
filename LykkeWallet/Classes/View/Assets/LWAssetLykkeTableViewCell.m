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


@implementation LWAssetLykkeTableViewCell {
    UITapGestureRecognizer *tapGestureRecognizer;
}

- (void)setRate:(LWAssetPairRateModel *)rate {
    _rate = rate;
    
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
    else {
        self.assetPriceLabel.text = @". . .";
        self.assetPriceLabel.textColor = [UIColor colorWithHexString:kAssetDisabledItemColor];
        self.assetChangeLabel.text = @". . .";
        self.assetChangeLabel.textColor = [UIColor colorWithHexString:kMainDarkElementsColor];
        self.assetPriceImageView.image = [UIImage imageNamed:@"AssetPriceDisabledArea"];
    }
}

- (void)setPair:(LWAssetPairModel *)pair {
    _pair = pair;
    
    self.assetNameLabel.text = pair.name;
    
    if (!tapGestureRecognizer) {
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(graphClicked)];
        [self.assetChangeView addGestureRecognizer:tapGestureRecognizer];
    }
}

- (void)graphClicked {
    if (self.rate) {
        [self.delegate graphClicked:self];
    }
}

@end
