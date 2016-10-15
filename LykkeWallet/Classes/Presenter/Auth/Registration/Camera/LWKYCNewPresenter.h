//
//  LWKYCPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWKYCDocumentsModel.h"

@interface LWKYCNewPresenter : UIViewController

@property (strong, nonatomic) LWKYCDocumentsModel *documentsStatuses;

@property id delegate;

@end

@protocol LWKYCNewPresenterDelegate

-(void) kycPresenterUserSubmitted:(LWKYCNewPresenter *) presenter;

@end
