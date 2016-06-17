//
//  LWExchangeBaseAssetsView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 08/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeBaseAssetsView.h"
#import "LWCache.h"
#import "LWAssetModel.h"
#import "LWExchangeAssetsPopupView.h"

//#define DISTANCE 64.0

@interface LWExchangeBaseAssetsView() <LWExchangeAssetsPopupViewDelegate>
{
    NSMutableArray *buttons;
//    UIScrollView *scrollView;
    NSArray *assets;
    
}

@end

@implementation LWExchangeBaseAssetsView


-(void) awakeFromNib
{
//    scrollView=[[UIScrollView alloc] init];
//    [self addSubview:scrollView];
 //    [self createButtons];
}

-(void) createButtonsWithAssets:(NSArray *) lastBaseAssets
{
    buttons=[[NSMutableArray alloc] init];

    for(UIView *v in self.subviews)
        [v removeFromSuperview];
    
    assets=lastBaseAssets;
    for(int i=0;i<[assets count]+1 && i<6; i++)
    {
        
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1] forState:UIControlStateNormal];
        button.titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
        [button addTarget:self action:@selector(assetPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        if(i<5 && i<assets.count)
        {
            LWAssetModel *asset=assets[i];
            [button setTitle:asset.name forState:UIControlStateNormal];
            
            if([asset.identity isEqualToString:[LWCache instance].baseAssetId])
                button.selected=YES;
            button.tag=i;
            [button sizeToFit];

        }
        else
        {
            [button setBackgroundImage:[UIImage imageNamed:@"ThreeDots.png"] forState:UIControlStateNormal];
            button.frame=CGRectMake(0, 0, 40, 20);
            button.tag=100;
        }
        
        [buttons addObject:button];
        [self addSubview:button];
    }
    [self setNeedsLayout];

}



-(void) checkCurrentBaseAsset
{
        for(UIButton *b in buttons)
        {
            if(b.tag==100)
                continue;
            b.selected=NO;
            int index=(int)[buttons indexOfObject:b];
            LWAssetModel *asset=assets[index];
            if([asset.identity isEqualToString:[LWCache instance].baseAssetId])
                b.selected=YES;
        }
}

-(void) assetPressed:(UIButton *) button
{
    if(button.selected)
        return;
    if(button.tag==100)
    {
        LWExchangeAssetsPopupView *popup=[[LWExchangeAssetsPopupView alloc] init];
        popup.delegate=self;
        [popup show];
        return;
    }
    NSInteger index=[buttons indexOfObject:button];
    LWAssetModel *asset=assets[index];
    [self changeBaseAsset:asset.identity];
    
}

-(void) popupView:(LWExchangeAssetsPopupView *)view didSelectAssetWithId:(NSString *)assetId
{
    [self changeBaseAsset:assetId];
}

-(void) changeBaseAsset:(NSString *) assetId
{
    LWAssetModel *asset;
    for(LWAssetModel *a in assets)
    {
        if([a.identity isEqualToString:assetId])
        {
            asset=a;
            break;
        }
    }
    
    if([self.delegate respondsToSelector:@selector(baseAssetsViewChangedBaseAsset:)])
    {
        if(asset)
        {
            for(UIButton *b in buttons)
            {
                b.selected=NO;
                if(b.tag==[assets indexOfObject:asset])
                    b.selected=YES;
            }
        }
        
        [self.delegate baseAssetsViewChangedBaseAsset:assetId];
    }

}


-(void) layoutSubviews
{
    [super layoutSubviews];
//    scrollView.frame=self.bounds;
    
    CGFloat distance=(self.bounds.size.width-30)/buttons.count;
    
    CGRect ttt=self.bounds;
    for(UIButton *b in buttons)
    {
        
        b.center=CGPointMake(15+distance*[buttons indexOfObject:b]+distance/2, self.bounds.size.height/2);
        CGRect rrr=b.frame;
//        NSLog(@"%d %d", rrr.origin.x, rrr.origin.y);
    
    }
//    scrollView.contentSize=CGSizeMake(DISTANCE*buttons.count, scrollView.bounds.size.height);
}



@end
