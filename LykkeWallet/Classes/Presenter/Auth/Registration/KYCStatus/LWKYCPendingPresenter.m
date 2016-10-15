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
#import "UIViewController+Navigation.h"
#import "LWProgressView.h"
#import "LWKYCDocumentsModel.h"
#import "LWCommonButton.h"


@interface LWKYCPendingPresenter () {
    
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet LWProgressView *activity;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;
@property (weak, nonatomic) IBOutlet LWCommonButton *button;


@end


@implementation LWKYCPendingPresenter


#pragma mark - LWAuthStepPresenter

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    if([UIScreen mainScreen].bounds.size.width==320)
        _buttonWidth.constant=280;
    _button.type=BUTTON_TYPE_CLEAR;
    
    NSDictionary *attr=@{NSKernAttributeName:@(1.5), NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17]};
    _titleLabel.attributedText=[[NSAttributedString alloc] initWithString:@"YOUR DOCUMENTS HAVE BEEN SUBMITTED" attributes:attr];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self setBackButton];
    
    [self.activity startAnimating];
    [self waitForImagesToUploadAndRequestKYCStatus];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}

-(IBAction)buttonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) waitForImagesToUploadAndRequestKYCStatus
{
    if([[LWKYCDocumentsModel shared] isUploadingImage])
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self waitForImagesToUploadAndRequestKYCStatus];
        });
    else
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
    if (([status isEqualToString:@"Rejected"] || [status isEqualToString:@"Pending"]) ) {//Andrey
        const NSInteger repeatSeconds = 5;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(repeatSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[LWAuthManager instance] requestKYCStatusGet];
        });
    }
    else if([status isEqualToString:@"NeedToFillData"])
    {
        
        if([self.delegate respondsToSelector:@selector(pendingPresenterDidReceiveNeedToFillData:)])
            [self.delegate pendingPresenterDidReceiveNeedToFillData:self];
        
    }
    else if([status isEqualToString:@"RestrictedArea"])
    {
        
        if([self.delegate respondsToSelector:@selector(pendingPresenterDidReceiveRestrictedArea:)])
            [self.delegate pendingPresenterDidReceiveRestrictedArea:self];
        
    }

    else if([status isEqualToString:@"Ok"])
    {
        
        if([self.delegate respondsToSelector:@selector(pendingPresenterDidReceiveConfirm:)])
            [self.delegate pendingPresenterDidReceiveConfirm:self];
//        [navController navigateKYCStatus:status isPinEntered:NO isAuthentication:NO];
    }
}

@end
