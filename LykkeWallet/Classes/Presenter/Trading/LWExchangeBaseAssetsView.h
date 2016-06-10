//
//  LWExchangeBaseAssetsView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 08/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWExchangeBaseAssetsView : UIView

@property id delegate;

@end

@protocol LWExchangeBaseAssetsViewDelegate

-(void) baseAssetsViewChangedBaseAsset:(NSString *) assetId;

@end
