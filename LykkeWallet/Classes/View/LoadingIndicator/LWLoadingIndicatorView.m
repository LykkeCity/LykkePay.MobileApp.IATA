//
//  LWLoadingIndicatorView.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWLoadingIndicatorView.h"


@implementation LWLoadingIndicatorView

- (void)setLoading:(BOOL)loading {
    if (loading) {
        CABasicAnimation *rotation;
        rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.fromValue = [NSNumber numberWithFloat:0];
        rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
        rotation.duration = 1.2f;
        rotation.repeatCount = HUGE_VALF;
        [self.layer removeAllAnimations];
        [self.layer addAnimation:rotation forKey:@"Spin"];
    }
    else {
        [self.layer removeAllAnimations];
    }
    
    self.hidden = !loading;
}

@end
