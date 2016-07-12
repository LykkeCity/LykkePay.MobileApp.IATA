//
//  LWKYCManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWKYCManager.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "LWAuthManager.h"
#import "LWRegisterCameraPresenter.h"
#import "LWKYCSubmitPresenter.h"
#import "LWAuthSteps.h"
#import "LWKYCPendingPresenter.h"
#import "LWKYCSuccessPresenter.h"
#import "LWPacketKYCForAsset.h"
#import "LWKYCRestrictedPresenter.h"
#import "LWKYCInvalidDocumentsPresenter.h"

@interface LWKYCManager() <LWAuthManagerDelegate, LWRegisterCameraPresenterDelegate, LWKYCSubmitPresenterDelegate, LWKYCPendingPresenterDelegate, LWKYCSuccessPresenterDelegate, LWKYCInvalidDocumentsPresenterDelegate>
{
    
    void (^completionBlock)(void);
    UINavigationController *navigationController;
    UIViewController *lastViewController;
    
    LWDocumentsStatus *documentsStatus;
}

@end

@implementation LWKYCManager

+ (instancetype)sharedInstance
{
    static LWKYCManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LWKYCManager alloc] init];
        
    });
    return sharedInstance;
}


-(void) manageKYCStatusForAsset:(NSString *)assetId successBlock:(void(^)(void)) completion
{
    navigationController=self.viewController.navigationController;
    lastViewController=[navigationController.viewControllers lastObject];
    completionBlock=completion;
    [self.viewController setLoading:YES];
    [LWAuthManager instance].delegate=self;
    
//    [[LWAuthManager instance] requestKYCStatusGet];
  
    [[LWAuthManager instance] requestKYCStatusForAsset:assetId];
    
//    [[LWAuthManager instance] requestDocumentsToUpload];
}

-(void) manageKYCStatus
{
    navigationController=self.viewController.navigationController;
    lastViewController=[navigationController.viewControllers lastObject];
    
    [self.viewController setLoading:YES];
    [LWAuthManager instance].delegate=self;
    
    [[LWAuthManager instance] requestKYCStatusGet];

}

-(void) authManager:(LWAuthManager *) manager didGetAssetKYCStatusForAsset:(LWPacketKYCForAsset *)status
{
    [self.viewController setLoading:NO];
    
    if(status.kycNeeded==NO)
    {

        if(completionBlock)
            completionBlock();
    }
    else if([status.userKYCStatus isEqualToString:@"Pending"] || [status.userKYCStatus isEqualToString:@"Rejected"])
    {
        LWKYCPendingPresenter *vc=[LWKYCPendingPresenter new];
        vc.delegate=self;
        
        [navigationController pushViewController:vc animated:YES];
    }
    else if([status.userKYCStatus isEqualToString:@"NeedToFillData"])
    {
        [self.viewController setLoading:YES];
        [[LWAuthManager instance] requestDocumentsToUpload];
    }
    else if([status.userKYCStatus isEqualToString:@"RestrictedArea"])
    {
        [self showRestrictedArea];
    }
    else if([status.userKYCStatus isEqualToString:@"Ok"])
    {
        [self showSuccess];
    }
    
}

-(void) authManager:(LWAuthManager *)manager didGetKYCStatus:(NSString *)status personalData:(LWPersonalData *)personalData
{
    if([status isEqualToString:@"NeedToFillData"])
    {
        [self.viewController setLoading:NO];
        LWKYCInvalidDocumentsPresenter *pres=[[LWKYCInvalidDocumentsPresenter alloc] init];
        pres.delegate=self;
        [navigationController presentViewController:pres animated:YES completion:nil];

        return;
    }
    LWPacketKYCForAsset *statusPacket=[LWPacketKYCForAsset new];
    statusPacket.userKYCStatus=status;
    statusPacket.kycNeeded=YES;
    [self authManager:manager didGetAssetKYCStatusForAsset:statusPacket];
}


-(void) showRestrictedArea
{
    LWKYCRestrictedPresenter *vc=[[LWKYCRestrictedPresenter alloc] init];
    [navigationController pushViewController:vc animated:YES];
}


-(void) authManager:(LWAuthManager *) manager didCheckDocumentsStatus:(LWDocumentsStatus *)status
{
    [self.viewController setLoading:NO];
    
    documentsStatus=status;
    [self checkDocumentsStatus];
}

-(void) checkDocumentsStatus
{
    if(documentsStatus.isIdCardUploaded==NO || documentsStatus.isPOAUploaded==NO || documentsStatus.isSelfieUploaded==NO)
    {
        LWAuthStep step;
        if(documentsStatus.isSelfieUploaded==NO)
            step=LWAuthStepRegisterSelfie;
        else if(documentsStatus.isIdCardUploaded==NO)
            step=LWAuthStepRegisterIdentity;
        else
            step=LWAuthStepRegisterUtilityBill;
        
        [self showCameraWithStep:step];
    }
    else
    {
        LWKYCSubmitPresenter *presenter=[LWKYCSubmitPresenter new];
        presenter.delegate=self;
        [navigationController pushViewController:presenter animated:YES];
        
    }

}

-(void) showCameraWithStep:(LWAuthStep) step
{
    LWRegisterCameraPresenter *camera=[LWRegisterCameraPresenter new];
    camera.delegate=self;
    //        camera.shouldHideBackButton=YES;
    UIView *v=camera.view;
    camera.currentStep=step;
    camera.stepImageView.hidden=YES;
    [navigationController pushViewController:camera animated:YES];

}

-(void) showSuccess
{
    LWKYCSuccessPresenter *vc=[LWKYCSuccessPresenter new];
    vc.delegate=self;
    [navigationController pushViewController:vc animated:YES];

}

-(void) cameraPresenterDidSendPhoto:(LWRegisterCameraPresenter *)presenter
{
    [self checkDocumentsStatus];
    
//    if(presenter.currentStep==LWAuthStepRegisterIdentity)
//        [self showCameraWithStep:LWAuthStepRegisterUtilityBill];
//    else
//    {
//        
//        LWKYCSubmitPresenter *presenter=[LWKYCSubmitPresenter new];
//        presenter.delegate=self;
//        [navigationController pushViewController:presenter animated:YES];
//        
//        
//    }
}

-(void) submitPresenterUserSubmitted:(LWKYCSubmitPresenter *)presenter
{
    [presenter.navigationController popToViewController:lastViewController animated:NO];
    
    LWKYCPendingPresenter *vc=[LWKYCPendingPresenter new];
    vc.delegate=self;
    
    [navigationController pushViewController:vc animated:NO];
}

-(void) pendingPresenterDidReceiveConfirm:(LWKYCPendingPresenter *)presenter
{
    [self showSuccess];
}

-(void) pendingPresenterDidReceiveNeedToFillData:(LWKYCPendingPresenter *)presenter
{
    
    
    
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"LYKKE" message:@"Some of your documents were not accepted. Please retake." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alert show];
    [presenter.navigationController popToViewController:lastViewController animated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        LWKYCInvalidDocumentsPresenter *pres=[[LWKYCInvalidDocumentsPresenter alloc] init];
        pres.delegate=self;
        
        [presenter.navigationController presentViewController:pres animated:YES completion:nil];
        
        
    });
}

-(void) invalidDocumentsPresenterDismissed
{
    [self.viewController setLoading:YES];
    [[LWAuthManager instance] requestDocumentsToUpload];
    [LWAuthManager instance].delegate=self;

}



-(void) pendingPresenterDidReceiveRestrictedArea:(LWKYCPendingPresenter *)presenter
{
    [presenter.navigationController popToViewController:lastViewController animated:NO];
    [self showRestrictedArea];
}

-(void) successPresenterGetStarted:(LWKYCSuccessPresenter *)presenter
{
    [navigationController popToViewController:lastViewController animated:NO];
    if(completionBlock)
        completionBlock();
}

@end
