//
//  LWKYCCheckDocumentsPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 29.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCCheckDocumentsPresenter.h"
#import "LWRegisterCameraPresenter.h"
#import "LWPersonalDataModel.h"


@interface LWKYCCheckDocumentsPresenter () {
    
}

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end


@implementation LWKYCCheckDocumentsPresenter


#pragma mark - LWAuthStepPresenter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [[LWAuthManager instance] requestPersonalData];
}

- (void)authManager:(LWAuthManager *)manager didReceivePersonalData:(LWPersonalDataModel *)data {
#warning TODO: five places with the same code - refactoring
    if ([data isFullNameEmpty]) {
        LWAuthNavigationController *navigation = (LWAuthNavigationController *)self.navigationController;
        [navigation navigateToStep:LWAuthStepRegisterFullName
                  preparationBlock:^(LWAuthStepPresenter *presenter) {
                  }];
    }
    else if ([data isPhoneEmpty]) {
        LWAuthNavigationController *navigation = (LWAuthNavigationController *)self.navigationController;
        [navigation navigateToStep:LWAuthStepRegisterPhone
                  preparationBlock:^(LWAuthStepPresenter *presenter) {
                  }];
    }
    else {
        [[LWAuthManager instance] requestDocumentsToUpload];
    }
}

- (LWAuthStep)stepId {
    return LWAuthStepCheckDocuments;
}

- (void)localize {
    self.textLabel.text = [NSString stringWithFormat:Localize(@"register.check.documents.label")];
}

#ifdef PROJECT_IATA
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
#endif


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didCheckDocumentsStatus:(LWDocumentsStatus *)status {
    [((LWAuthNavigationController *)self.navigationController) navigateWithDocumentStatus:status hideBackButton:YES];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    
    [((LWAuthNavigationController *)self.navigationController) logout];
}

@end
