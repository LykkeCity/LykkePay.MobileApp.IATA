//
//  LWAuthNavigationController.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthNavigationController.h"
#import "LWAuthEntryPointPresenter.h"
#import "LWAuthValidationPresenter.h"
#import "LWKYCCheckDocumentsPresenter.h"

#import "LWRegisterBasePresenter.h"
#import "LWSMSCodeStepPresenter.h"
#import "LWRegisterFullNamePresenter.h"
#import "LWRegisterPhonePresenter.h"
#import "LWRegisterPhoneConfirmPresenter.h"
#import "LWRegisterPasswordPresenter.h"
#import "LWRegisterConfirmPasswordPresenter.h"

#import "LWAuthenticationPresenter.h"
#import "LWAuthValidationPresenter.h"
#import "LWAuthPINEnterPresenter.h"
#import "LWKYCSubmitPresenter.h"
#import "LWKYCPendingPresenter.h"
#import "LWKYCInvalidDocumentsPresenter.h"
#import "LWKYCRestrictedPresenter.h"
#import "LWKYCSuccessPresenter.h"
#import "LWRegisterPINSetupPresenter.h"
#import "LWRegisterCameraPresenter.h"

// tab presenters
#import "LWTabController.h"
#import "LWWalletsPresenter.h"
#import "LWExchangePresenter.h"
#import "LWHistoryPresenter.h"
#import "LWSettingsPresenter.h"

#ifdef PROJECT_IATA
#import "LWTransferPresenter.h"
#endif

#import "LWKeychainManager.h"
#import "LWConstants.h"
#import "UIImage+Resize.h"


@interface LWAuthNavigationController () {
    NSArray *classes;
    NSMutableDictionary<NSNumber *, LWAuthStepPresenter *> *activeSteps;
}


#pragma mark - Root Controller Configuration

+ (LWAuthStepPresenter *)authPresenter;
- (void)setRootAuthScreen;


#pragma mark - Utils

- (UITabBarItem *)createTabBarItemWithTitle:(NSString *)title withImage:(NSString *)image;

@end


@implementation LWAuthNavigationController


#pragma mark - Root

- (instancetype)init {
    self = [super initWithRootViewController:[LWAuthNavigationController authPresenter]];
    if (self) {
        _currentStep = ([LWKeychainManager instance].isAuthenticated
                        ? LWAuthStepValidation
                        : LWAuthStepEntryPoint);
        // set controllers classes
        classes = @[LWAuthValidationPresenter.class,
                    LWAuthEntryPointPresenter.class,
                    LWAuthenticationPresenter.class,
                    LWAuthPINEnterPresenter.class,
                    LWKYCCheckDocumentsPresenter.class,

                    LWSMSCodeStepPresenter.class,
                    LWRegisterPasswordPresenter.class,
                    LWRegisterConfirmPasswordPresenter.class,
                    LWRegisterFullNamePresenter.class,
                    LWRegisterPhonePresenter.class,
                    LWRegisterPhoneConfirmPresenter.class,
                    LWRegisterCameraPresenter.class,
                    LWRegisterCameraPresenter.class,
                    LWRegisterCameraPresenter.class,
                    LWKYCSubmitPresenter.class,
                    LWKYCPendingPresenter.class,
                    LWKYCInvalidDocumentsPresenter.class,
                    LWKYCRestrictedPresenter.class,
                    LWKYCSuccessPresenter.class,
                    LWRegisterPINSetupPresenter.class];
        
        activeSteps = [NSMutableDictionary new];
        activeSteps[@(self.currentStep)] = self.viewControllers.firstObject;
    }

    return self;
}


#pragma mark - Common

- (void)navigateToStep:(LWAuthStep)step preparationBlock:(LWAuthStepPushPreparationBlock)block {
    // check whether we can just unwind to step
    if ([activeSteps.allKeys containsObject:@(step)]) {
        if (block) {
            LWAuthStepPresenter *ctrl = activeSteps[@(step)];
            block(ctrl);
        }
        [self popToViewController:activeSteps[@(step)] animated:YES];
    }
    else {
        // otherwise create new step presenter
        LWAuthStepPresenter *presenter = [classes[step] new];
        activeSteps[@(step)] = presenter;
        // prevent lazy view loading
        NSLog(@"PreventingLazyLoad: %@", presenter.view);
        // prepare to push if necessary
        if (block) {
            block(presenter);
        }
        [self pushViewController:presenter animated:YES];
    }
    // change current step
    _currentStep = step;
}

- (void)navigateKYCStatus:(NSString *)status isPinEntered:(BOOL)isPinEntered isAuthentication:(BOOL)isAuthentication {
    NSLog(@"KYC GetStatus: %@", status);
    
    if ([status isEqualToString:@"NeedToFillData"]) {
        if (isAuthentication) {
            [self navigateToStep:LWAuthStepCheckDocuments preparationBlock:nil];
        }
        else {
            [self navigateToStep:LWAuthStepRegisterKYCInvalidDocuments preparationBlock:nil];
        }
    }
    else if ([status isEqualToString:@"RestrictedArea"]) {
        [self navigateToStep:LWAuthStepRegisterKYCRestricted preparationBlock:nil];
    }
    else if ([status isEqualToString:@"Rejected"] || [status isEqualToString:@"Pending"]) {
        [self navigateToStep:LWAuthStepRegisterKYCPending preparationBlock:nil];
    }
    else if ([status isEqualToString:@"Ok"]) {
        if (!isAuthentication) {
            [self navigateToStep:LWAuthStepRegisterKYCSuccess preparationBlock:nil];
        }
        else {
            if (isPinEntered) {
                [self navigateToStep:LWAuthStepValidatePIN preparationBlock:nil];
            }
            else  {
                [self navigateToStep:LWAuthStepRegisterPINSetup preparationBlock:nil];
            }
        }
    }
    else {
        NSAssert(0, @"Unknown KYC status.");
    }
}

- (void)navigateWithDocumentStatus:(LWDocumentsStatus *)status hideBackButton:(BOOL)hideBackButton {
    LWAuthStep step = [LWAuthSteps getNextDocumentByStatus:status];

    if (status.documentTypeRequired) {
        if (step != LWAuthStepRegisterKYCSubmit) {
            [self navigateToStep:step
                preparationBlock:^(LWAuthStepPresenter *presenter) {
                    LWRegisterCameraPresenter *camera = (LWRegisterCameraPresenter *)presenter;
                    camera.shouldHideBackButton = hideBackButton;
                    camera.showCameraImmediately = YES;
                    camera.currentStep = step;
                }];
        }
        else {
            [self navigateToStep:step preparationBlock:nil];
        }
    }
    else {
        [self navigateToStep:LWAuthStepRegisterKYCSubmit preparationBlock:nil];
    }
}


#pragma mark - Auth

- (void)logout {
    [[LWKeychainManager instance] clear];
    [activeSteps removeAllObjects];
    [self setRootAuthScreen];
}


#pragma mark - Root Controller Configuration

+ (LWAuthStepPresenter *)authPresenter {
    return ([LWKeychainManager instance].isAuthenticated
            ? [LWAuthValidationPresenter new]
            : [LWAuthEntryPointPresenter new]);
}

- (void)setRootAuthScreen {
    [self setViewControllers:@[[LWAuthNavigationController authPresenter]] animated:NO];
}

- (void)setRootMainTabScreen {
    LWTabController *tab = [LWTabController new];
    
    LWWalletsPresenter *pWallets = [LWWalletsPresenter new];
    pWallets.tabBarItem = [self createTabBarItemWithTitle:@"tab.wallets"
                                                withImage:@"WalletsTab"];
    LWExchangePresenter *pTrading = [LWExchangePresenter new];
    pTrading.tabBarItem = [self createTabBarItemWithTitle:@"tab.trading"
                                                withImage:@"TradingTab"];
    LWHistoryPresenter *pHistory = [LWHistoryPresenter new];
    pHistory.title = Localize(@"tab.history");
    pHistory.tabBarItem = [self createTabBarItemWithTitle:@"tab.history"
                                                withImage:@"HistoryTab"];
    LWSettingsPresenter *pSettings = [LWSettingsPresenter new];
    pSettings.tabBarItem = [self createTabBarItemWithTitle:@"tab.settings"
                                                 withImage:@"SettingsTab"];

#ifdef PROJECT_IATA
    LWTransferPresenter *pTransfer = [LWTransferPresenter new];
    pTransfer.tabBarItem = [self createTabBarItemWithTitle:@"tab.transfer"
                                                 withImage:@"TransferTab"];
    tab.viewControllers = @[pWallets, pTransfer, pTrading, pHistory, pSettings];
#else
    tab.viewControllers = @[pWallets, pTrading, pHistory, pSettings];
#endif

    // init tab controller
    tab.tabBar.translucent = NO;
    
    [self setViewControllers:@[tab] animated:NO];
}


#pragma mark - Utils

- (UITabBarItem *)createTabBarItemWithTitle:(NSString *)title withImage:(NSString *)image {
#ifdef PROJECT_IATA
    UIImage *unselected = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selected = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UITabBarItem *result = [[UITabBarItem alloc] initWithTitle:Localize(title)
                                                         image:unselected
                                                 selectedImage:selected];
#else
    UIImage *selectedImage = [UIImage imageNamed:image];
    UITabBarItem *result = [[UITabBarItem alloc] initWithTitle:Localize(title)
                                                         image:selectedImage
                                                 selectedImage:selectedImage];
#endif

    return result;
}


#pragma mark - UINavigationController

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *result = [super popViewControllerAnimated:animated];
    // clean steps
    for (NSNumber *key in activeSteps.allKeys) {
        if (![self.viewControllers containsObject:activeSteps[key]]) {
            [activeSteps removeObjectForKey:key];
        }
    }
    return result;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray *result = [super popToViewController:viewController animated:animated];
    // clean steps
    for (NSNumber *key in activeSteps.allKeys) {
        if (![self.viewControllers containsObject:activeSteps[key]]) {
            [activeSteps removeObjectForKey:key];
        }
    }
    return result;
}

@end
