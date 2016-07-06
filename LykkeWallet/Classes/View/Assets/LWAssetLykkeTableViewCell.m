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
#import "LWCache.h"
#import "LWUtils.h"

#import "LWAuthManager.h"

@interface LWAssetLykkeTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *touchCatchView;

@end


@implementation LWAssetLykkeTableViewCell {
    
    UITapGestureRecognizer *tapGestureRecognizer;
}



-(void) awakeFromNib
{
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reverse)];
    [_touchCatchView addGestureRecognizer:gesture];
    
    
    self.leftAssetNameLabel.text=nil;
    self.rightAssetNameLabel.text=nil;
    
    self.assetPriceLabel.layer.borderColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1].CGColor;
    self.assetPriceLabel.layer.borderWidth=1;
    [self.assetPriceImageView removeFromSuperview];
    
}

-(void) reverse
{
    if(!_pair)
        return;
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
//        NSString *priceString = [LWMath priceString:rate.ask precision:self.pair.accuracy withPrefix:@""];
        
        NSString *priceString=[LWUtils formatVolumeNumber:rate.ask currencySign:@"" accuracy:self.pair.accuracy.intValue removeExtraZeroes:YES];
        priceString=[priceString stringByReplacingOccurrencesOfString:@"." withString:@","];
        
        self.assetPriceLabel.text = [NSString stringWithFormat:@"%@ %@", [[LWCache instance] currencySymbolForAssetId:self.pair.quotingAssetId],priceString];
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
        [self addGestureRecognizer:tapGestureRecognizer];
        tapGestureRecognizer.delegate=self;
    }
}


-(BOOL) gestureRecognizer:(UIGestureRecognizer *)sender shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self.assetChangeView];
//    if (sender!=tapGestureRecognizer || CGRectContainsPoint(CGRectMake(self.assetChangeView.frame.origin.x, 0, self.assetChangeView.bounds.size.width, self.bounds.size.height), location)==NO)
    if (sender!=tapGestureRecognizer || location.x<0 || location.x>self.assetChangeView.bounds.size.width)
        return NO;
    return YES;
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
    [self setNeedsLayout];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.assetPriceLabel.layer.cornerRadius=self.assetPriceLabel.bounds.size.height/2;

    
}

- (void)graphClicked {
    
    CGRect rrr=self.assetPriceImageView.frame;
    CGRect rr1=self.frame;
    
    if (self.rate) {
        [self.delegate graphClicked:self];
    }
}

@end
