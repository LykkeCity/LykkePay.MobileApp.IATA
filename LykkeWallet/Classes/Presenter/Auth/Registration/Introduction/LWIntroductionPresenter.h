//
//  LWIntroductionPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWIntroductionPresenter : UIViewController

@property id delegate;

@end

@protocol LWIntroductionPresenterDelegate

-(void) introductionPresenterShouldDismiss:(LWIntroductionPresenter *) presenter;

@end
