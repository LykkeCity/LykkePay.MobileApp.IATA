//
//  LWAnimatedView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWAnimatedView : UIView

-(id) initWithFrame:(CGRect)frame name:(NSString *) name;

-(void) startAnimationIfNeeded;

-(void) animateUntilFrame:(int) frame;

@end
