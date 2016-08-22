//
//  LWResultPresenter.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWResultPresenter : UIViewController {
    
}

@property id delegate;

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *textString;
@property (strong, nonatomic) UIImage *image;
@property (strong,nonatomic) NSString *buttonTitle;

@end

@protocol LWResultPresenterDelegate

-(void) resultPresenterDismissed;
-(void) resultPresenterWillDismiss;

@end
