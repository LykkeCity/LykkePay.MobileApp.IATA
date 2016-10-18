//
//  LWKYCInvalidDocumentsPresenter.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"
#import "LWKYCDocumentsModel.h"


@interface LWKYCInvalidDocumentsPresenter : LWAuthComplexPresenter {
    
}

@property (strong, nonatomic) LWKYCDocumentsModel *documentsStatuses;

@property id delegate;

@end

@protocol LWKYCInvalidDocumentsPresenterDelegate

-(void) invalidDocumentsPresenterDismissed:(LWKYCInvalidDocumentsPresenter *) presenter;

@end
