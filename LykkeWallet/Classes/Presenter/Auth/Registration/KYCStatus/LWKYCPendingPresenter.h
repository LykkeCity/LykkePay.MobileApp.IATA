//
//  LWKYCPendingPresenter.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCPresenter.h"


@interface LWKYCPendingPresenter : LWKYCPresenter {
    
}

@property id delegate;

@end

@protocol LWKYCPendingPresenterDelegate

-(void) pendingPresenterDidReceiveConfirm:(LWKYCPendingPresenter *) presenter;
-(void) pendingPresenterDidReceiveNeedToFillData:(LWKYCPendingPresenter *) presenter;
-(void) pendingPresenterDidReceiveRestrictedArea:(LWKYCPendingPresenter *) presenter;

@end