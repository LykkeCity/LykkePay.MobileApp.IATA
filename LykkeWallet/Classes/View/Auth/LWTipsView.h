//
//  LWTipsView.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKView.h"

@class LWTipsView;


@protocol LWTipsViewDelegate
@required
- (void)tipsViewDidPress:(LWTipsView *)view;

@end


@interface LWTipsView : TKView {
    
}

@property (weak, nonatomic) id<LWTipsViewDelegate> delegate;

@end
