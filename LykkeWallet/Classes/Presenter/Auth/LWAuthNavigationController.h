//
//  LWAuthNavigationController.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKNavigationPresenter.h"
#import "LWAuthStepPresenter.h"

typedef void (^LWAuthStepPushPreparationBlock)(LWAuthStepPresenter *presenter);


@interface LWAuthNavigationController : TKNavigationPresenter {
    
}

@property (readonly, nonatomic) LWAuthStep currentStep;


#pragma mark - Common

- (void)navigateToStep:(LWAuthStep)step preparationBlock:(LWAuthStepPushPreparationBlock)block;
- (void)navigateKYCStatus:(NSString *)status isPinEntered:(BOOL)isPinEntered isAuthentication:(BOOL)isAuthentication;
- (void)navigateWithDocumentStatus:(LWDocumentsStatus *)status hideBackButton:(BOOL)hideBackButton;


#pragma mark - Auth

- (void)logout;


#pragma mark - Root Controller Configuration

- (void)setRootMainTabScreen;

@end
