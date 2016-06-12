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

@interface LWExchangeBaseAssetsView()
{
    NSMutableArray *buttons;
//    UIScrollView *scrollView;
    NSArray *assets;
    LWExchangeAssetsPopupView *popup;
}

@end

@implementation LWExchangeBaseAssetsView


-(void) awakeFromNib
{
//    scrollView=[[UIScrollView alloc] init];
//    [self addSubview:scrollView];
    buttons=[[NSMutableArray alloc] init];
    [self createButtons];
}

-(void) createButtons
{
    if(![LWCache instance].baseAssets)
    {
        [self performSelector:@selector(createButtons) withObject:nil afterDelay:0.5];
        return;
    }
    assets=[[LWCache instance].baseAssets copy];
    for(int i=0;i<[assets count]+1 && i<6; i++)
    {
        
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1] forState:UIControlStateNormal];
        button.titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
        [button addTarget:self action:@selector(assetPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        
        if(i<5 && i<assets.count)
        {
            LWAssetModel *asset=assets[i];
            [button setTitle:asset.name forState:UIControlStateNormal];
            
            if([asset.identity isEqualToString:[LWCache instance].baseAssetId])
                button.selected=YES;
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
        popup=[[LWExchangeAssetsPopupView alloc] init];
        [popup show];
        return;
    }
    NSInteger index=[buttons indexOfObject:button];
    LWAssetModel *asset=assets[index];
    if([self.delegate respondsToSelector:@selector(baseAssetsViewChangedBaseAsset:)])
    {
        for(UIButton *b in buttons)
            b.selected=NO;
        button.selected=YES;
        [self.delegate baseAssetsViewChangedBaseAsset:asset.identity];
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
