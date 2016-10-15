//
//  LWKYCLaterMessageView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface LWKYCLaterMessageView : UIView

-(void) show;

@property id delegate;

@end

@protocol LWKYCLaterMessageViewDelegate

-(void) laterMessageViewDismissed;

@end

