//
//  LWProgressView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 06/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWProgressView : UIView

+(void) showInView:(UIView *) view;
+(void) hide;

-(void) startAnimating;
-(void) stopAnimating;

@end
