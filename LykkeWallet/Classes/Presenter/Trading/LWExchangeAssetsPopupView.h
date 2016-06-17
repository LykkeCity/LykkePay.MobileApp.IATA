//
//  LWExchangeAssetsPopupView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWExchangeAssetsPopupView : UIView


-(void) show;

@property id delegate;

@end


@protocol LWExchangeAssetsPopupViewDelegate

-(void) popupView:(LWExchangeAssetsPopupView *) view didSelectAssetWithId:(NSString *) assetId;

@end