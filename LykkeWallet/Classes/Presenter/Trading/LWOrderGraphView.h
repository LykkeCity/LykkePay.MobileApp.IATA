//
//  LWOrderGraphView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWAssetPairModel.h"

@interface LWOrderGraphView : UIView

-(id) initWithPrice:(double) price volume:(double) volume;

@property CGFloat graphStartOffset;
@property double graphMaxVolume;
@property double graphMinVolume;


@property (strong, nonatomic) UIColor *graphColor;
@property (strong, nonatomic) LWAssetPairModel *assetPair;
@property (strong, nonatomic) UIColor *volumeColor;

@end
