//
//  LWKYCSubmitPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 21.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthStepPresenter.h"


@interface LWKYCSubmitPresenter : LWAuthStepPresenter {
    
}

@property id delegate;

@end


@protocol LWKYCSubmitPresenterDelegate

-(void) submitPresenterUserSubmitted:(LWKYCSubmitPresenter *) presenter;

@end