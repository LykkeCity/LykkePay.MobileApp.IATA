//
//  LWKYCPendingPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCPendingPresenter.h"
#import "LWRegistrationData.h"
#import "LWAuthManager.h"
#import "LWKeychainManager.h"
#import "LWPacketKYCStatusSet.h"
#import "LWPacketKYCStatusGet.h"
#import "LWAuthNavigationController.h"
#import "UIViewController+Loading.h"


@interface LWKYCPendingPresenter () {
    
}

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end


@implementation LWKYCPendingPresenter


#pragma mark - LWAuthStepPresenter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[LWAuthManager instance] requestKYCStatusGet];
}

- (void)localize {
    self.textLabel.text = [NSString stringWithFormat:Localize(@"register.kyc.pending"),
                           [LWKeychainManager instance].fullName];
}

- (LWAuthStep)stepId {
    return LWAuthStepRegisterKYCPending;
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    GDXNetPacket *pack = context.packet;
    
    if (reject) {
        [self showReject:reject response:context.task.response];
    }
    else {
        // some server error? Then just repeat request after some delay
        const NSInteger repeatSeconds = 5;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(repeatSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (pack.class == LWPacketKYCStatusGet.class) {
                [[LWAuthManager instance] requestKYCStatusGet];
            }
        });
    }
}

- (void)authManager:(LWAuthManager *)manager didGetKYCStatus:(NSString *)status personalData:(LWPersonalData *)personalData {
    LWAuthNavigationController *navController = (LWAuthNavigationController *)self.navigationController;

    // repeat request every x seconds
    if ([status isEqualToString:@"Rejected"] || [status isEqualToString:@"Pending"]) {
        const NSInteger repeatSeconds = 5;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(repeatSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[LWAuthManager instance] requestKYCStatusGet];
        });
    }
    else {
        [navController navigateKYCStatus:status isPinEntered:NO isAuthentication:NO];
    }
}

@end
