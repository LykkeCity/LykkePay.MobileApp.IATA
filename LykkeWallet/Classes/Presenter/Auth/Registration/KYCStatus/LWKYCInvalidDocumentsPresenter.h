//
//  LWKYCInvalidDocumentsPresenter.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCPresenter.h"
#import "LWKYCDocumentsModel.h"


@interface LWKYCInvalidDocumentsPresenter : LWKYCPresenter {
    
}

@property (strong, nonatomic) LWKYCDocumentsModel *documentsStatuses;

@property id delegate;

@end

@protocol LWKYCInvalidDocumentsPresenterDelegate

-(void) invalidDocumentsPresenterDismissed:(LWKYCInvalidDocumentsPresenter *) presenter;

@end
