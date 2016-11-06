//
//  LWCameraOverlayPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 26.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWCameraOverlayPresenter.h"

#import <Fabric/Fabric.h>


@interface LWCameraOverlayPresenter () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
}

#pragma mark - Actions

- (IBAction)closeButtonClick:(id)sender;
- (IBAction)selectFileButtonClick:(id)sender;
- (IBAction)takePictureButtonClick:(id)sender;
- (IBAction)switchButtonClick:(id)sender;


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIButton        *switchButton;
@property (weak, nonatomic) IBOutlet UIButton        *libraryButton;
@property (weak, nonatomic) IBOutlet UILabel         *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView     *stepImageView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButtonItem;


#pragma mark - Utils

- (void)updateImage;

@end


@implementation LWCameraOverlayPresenter


#pragma mark - Lifecycle

- (void)updateView {
    [self localize];
    [self updateImage];
    
    BOOL const isSelfie = (self.step == LWAuthStepRegisterSelfie);
    self.libraryButton.hidden = isSelfie;
    self.switchButton.hidden = isSelfie;
    
    self.backButtonItem = nil;
}


#pragma mark - TKPresenter

- (void)localize {
    
    self.navigationBar.topItem.title = [Localize(@"register.title") uppercaseString];
    self.subtitleLabel.text = Localize([LWAuthSteps titleByStep:self.step]);
}


#pragma mark - Actions

- (IBAction)closeButtonClick:(id)sender {
    [self.pickerReference.delegate imagePickerControllerDidCancel:self.pickerReference];
    [self.pickerReference dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)selectFileButtonClick:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)takePictureButtonClick:(id)sender {
    [self.delegate pictureTaken];
    [self.pickerReference takePicture];
}

- (IBAction)switchButtonClick:(id)sender {
    if (self.pickerReference.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    else {
        self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:NO completion:^{
        [self.delegate pictureTaken];
        [self.delegate fileChoosen:info];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - Utils

- (void)updateImage {
    UIImage *image = nil;
    switch (self.step) {
        case LWAuthStepRegisterSelfie:
            image = [UIImage imageNamed:@"RegisterLineStep2"];
            break;
        case LWAuthStepRegisterIdentity:
            image = [UIImage imageNamed:@"RegisterLineStep3"];
            break;
        case LWAuthStepRegisterUtilityBill:
            image = [UIImage imageNamed:@"RegisterLineStep4"];
            break;
        default:
            break;
    }
    [self.stepImageView setImage:image];
}

@end
