//
//  LWSettingsConfirmationPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthPresenter.h"


@class LWSettingsConfirmationPresenter;


@protocol LWSettingsConfirmationPresenter <NSObject>

@required
- (void)operationRejected;
- (void)operationConfirmed:(LWSettingsConfirmationPresenter *)presenter;

@end


@interface LWSettingsConfirmationPresenter : LWAuthPresenter {
    
}


#pragma mark - Properties

@property (weak,   nonatomic) id<LWSettingsConfirmationPresenter> delegate;
@property (assign, nonatomic) BOOL isOn;

@end
