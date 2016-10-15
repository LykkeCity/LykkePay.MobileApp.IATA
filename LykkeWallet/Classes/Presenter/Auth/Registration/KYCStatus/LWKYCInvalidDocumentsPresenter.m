//
//  LWKYCInvalidDocumentsPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCInvalidDocumentsPresenter.h"
#import "LWRegisterCameraPresenter.h"
#import "LWRegistrationData.h"
#import "LWPersonalDataModel.h"
#import "LWKeychainManager.h"
#import "UIViewController+Loading.h"
#import "LWCommonButton.h"
#import "LWConstants.h"
#import "LWValidator.h"
#import "LWKYCManager.h"


@interface LWKYCInvalidDocumentsPresenter () {
    LWAuthStep nextStep;
}

@property (weak, nonatomic) IBOutlet UILabel  *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel  *textLabel;
@property (weak, nonatomic) IBOutlet LWCommonButton *okButton;

@property (weak, nonatomic) IBOutlet UIImageView *selfieStatusImage;
@property (weak, nonatomic) IBOutlet UIImageView *passportStatusImage;
@property (weak, nonatomic) IBOutlet UIImageView *addressStatusImage;

@property (weak, nonatomic) IBOutlet UILabel *selfieDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *passportDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressDescriptionLabel;




#pragma mark - Actions

- (IBAction)okButtonClick:(id)sender;

@end


@implementation LWKYCInvalidDocumentsPresenter

-(void) viewDidLoad
{
    [super viewDidLoad];
    NSArray *imageViews=@[_selfieStatusImage, _passportStatusImage, _addressStatusImage];
    NSArray *labels=@[_selfieDescriptionLabel, _passportDescriptionLabel, _addressDescriptionLabel];
    for(KYCDocumentType t=KYCDocumentTypeSelfie;t<=KYCDocumentTypeProofOfAddress;t++)
    {
        KYCDocumentStatus status=[_documentsStatuses statusForDocument:t];
        UILabel *label=labels[t];

        if(status==KYCDocumentStatusRejected)
        {
            [(UIImageView *)imageViews[t] setImage:[UIImage imageNamed:@"IconInvalid"]];
            label.text=[_documentsStatuses commentForType:t];
        }
        else
        {
            [(UIImageView *)imageViews[t] setImage:[UIImage imageNamed:@"IconValid"]];
            NSLayoutConstraint *constraint=[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
            [label addConstraint:constraint];
        }
        
        
    }
    
    [self adjustThinLines];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    



}



#pragma mark - Actions

- (IBAction)okButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(invalidDocumentsPresenterDismissed:)])
            [self.delegate invalidDocumentsPresenterDismissed:self];
        
    }];
    
}

-(NSString *) nibName
{
    if([UIScreen mainScreen].bounds.size.width==320)
        return @"LWKYCInvalidDocumentsPresenter_iphone5";
    else
        return @"LWKYCInvalidDocumentsPresenter";
}



@end
