//
//  LWRegisterCameraPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWRegisterCameraPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWConstants.h"
#import "LWCameraOverlayPresenter.h"

#import "UIViewController+Loading.h"
#import "UIImage+Resize.h"

#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>


@interface LWRegisterCameraPresenter ()<LWAuthManagerDelegate, LWCameraOverlayDelegate> {
    LWCameraOverlayPresenter *cameraOverlayPresenter;

    MBProgressHUD        *hud;
    NSURLSessionDataTask *uploadTask;
    
    UIImage *serverImage;
    UIImage *previewImage;
    
    //UIImage *lastUploadedImage;
}

@property (nonatomic) UIImagePickerController *imagePickerController;


#pragma mark - Utils

- (void)checkButtonsState;
- (void)showCameraView;
- (void)setupServerImage;
- (void)setupPreviewImageFromServerImage:(UIImage *)image shouldCropImage:(BOOL)shouldCropImage;
- (void)setupImage:(UIImage *)image shouldCropImage:(BOOL)shouldCropImage;
- (void)uploadImage:(UIImage *)image docType:(KYCDocumentType)docType;
- (void)updateStep:(KYCDocumentType)docType;

@end


@implementation LWRegisterCameraPresenter


#pragma mark - TKPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localize(@"register.title");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkButtonsState];
    
    UIColor *cancelColor = [UIColor colorWithHexString:kMainDarkElementsColor];
    [self.cancelButton setTitleColor:cancelColor forState:UIControlStateNormal];
    
    // hide back button if necessary
    if (self.shouldHideBackButton) {
        self.navigationItem.hidesBackButton = YES;
    }
    
    // if show camera view - reset flag for uploads
    KYCDocumentType type = [LWAuthSteps getDocumentTypeByStep:self.stepId];
    BOOL const croppedStatus = [[LWAuthManager instance].documentsStatus croppedStatus:type];
    serverImage = [[LWAuthManager instance].documentsStatus lastUploadedImageForType:type];
    [self setupPreviewImageFromServerImage:serverImage shouldCropImage:croppedStatus];

    [[LWAuthManager instance].documentsStatus resetTypeUploaded:type];
    
    if (self.showCameraImmediately && previewImage == nil) {
        [self showCameraView];
    }
    
    [self updateStep:type];
}

- (LWAuthStep)stepId {
    return self.currentStep;
}

- (void)localize {
    [self.cancelButton setTitle:[Localize(@"register.camera.photo.cancel") uppercaseString] forState:UIControlStateNormal];
}


#pragma mark - Actions

- (IBAction)cancelButtonClick:(id)sender {
    [self clearImage];
    [self okButtonClick:nil];
}

- (IBAction)okButtonClick:(id)sender {
    if (serverImage) {
        // send photo
        KYCDocumentType type = [LWAuthSteps getDocumentTypeByStep:self.stepId];
        [self uploadImage:serverImage docType:type];
    }
    else {
        [self showCameraView];
    }
}


#pragma mark - Utils

- (void)clearImage {
    previewImage = nil;
    serverImage = nil;
    self.photoImageView.image = nil;
}

- (void)checkButtonsState {
    if (serverImage) {
        [self.okButton setTitle:[Localize(@"register.camera.photo.ok") uppercaseString]
                       forState:UIControlStateNormal];
    }
    else {
        [self.okButton setTitle:[Localize(@"register.camera.photo.take") uppercaseString]
                       forState:UIControlStateNormal];
    }
}

- (void)showCameraView {
    
    // configure overlay
    if (!cameraOverlayPresenter) {
        cameraOverlayPresenter = [LWCameraOverlayPresenter new];
    }
    
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.navigationBar.translucent = NO;
    // if camera is unavailable - set photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // configure image picker
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        picker.showsCameraControls = NO;
        picker.cameraDevice = ((self.stepId == LWAuthStepRegisterSelfie)
                                    ? UIImagePickerControllerCameraDeviceFront
                                    : UIImagePickerControllerCameraDeviceRear);
        picker.toolbarHidden = YES;
        picker.allowsEditing = YES;
        picker.modalPresentationStyle = UIModalPresentationCurrentContext;

        cameraOverlayPresenter.pickerReference = picker;
        cameraOverlayPresenter.view.frame = picker.cameraOverlayView.frame;
        cameraOverlayPresenter.step = self.stepId;
        cameraOverlayPresenter.delegate = self;

        picker.cameraOverlayView = cameraOverlayPresenter.view;
    }
    else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    picker.delegate = self;

    self.imagePickerController = picker;
    [self.navigationController presentViewController:self.imagePickerController animated:NO completion:^{
        [cameraOverlayPresenter updateView];
    }];
    
    [self checkButtonsState];
}

- (void)setupServerImage {
    if (serverImage == nil) {
        return;
    }
    
    serverImage = [serverImage correctImageOrientation];
    
    NSInteger const maxSize = MAX((NSInteger)serverImage.size.height, (NSInteger)serverImage.size.width);
    // validate if image is too large
    if (maxSize > kMaxImageServerSize) {
        // calculate coefficient
        if (maxSize == (NSInteger)serverImage.size.height) {
            CGFloat coeff = serverImage.size.height / kMaxImageServerSize;
            CGSize size = CGSizeMake(serverImage.size.width / coeff, kMaxImageServerSize);
            serverImage = [serverImage resizedImage:size interpolationQuality:kCGInterpolationDefault];
        }
        else if (maxSize == (NSInteger)serverImage.size.width) {
            CGFloat coeff = serverImage.size.width / kMaxImageServerSize;
            CGSize size = CGSizeMake(kMaxImageServerSize, serverImage.size.height / coeff);
            serverImage = [serverImage resizedImage:size interpolationQuality:kCGInterpolationDefault];
        }
    }
    
    NSInteger imageSize = 0;
    double compression = 1.0;
    do {
        compression -= 0.1;
        NSData *imageData = UIImageJPEGRepresentation(serverImage, compression);
        imageSize = imageData.length;
    }
    while (imageSize > kMaxImageServerBytes);
    
    // update cropping status (to restore and show image correctly)
    KYCDocumentType type = [LWAuthSteps getDocumentTypeByStep:self.stepId];
    [[LWAuthManager instance].documentsStatus setDocumentType:type compression:compression];
}

- (void)setupPreviewImageFromServerImage:(UIImage *)image shouldCropImage:(BOOL)shouldCropImage {

    if (image == nil) {
        self.photoImageView.image = nil;
        return;
    }
    
    // resize to our view
    previewImage = [serverImage copy];
    CGFloat coeff = self.view.frame.size.width / previewImage.size.width;
    CGSize size = CGSizeMake(previewImage.size.width * coeff, previewImage.size.height * coeff);
    previewImage = [previewImage resizedImage:size interpolationQuality:kCGInterpolationDefault];
    
    // crop image for selfie
    if (shouldCropImage) {
        CGRect cropRect = self.photoImageView.frame;
        // hidden navigation bar
        CGFloat const navHeight = 56;
        cropRect.origin.y += navHeight;
        previewImage = [previewImage croppedImage:cropRect];
    }
    
    self.photoImageView.image = previewImage;
}

- (void)setupImage:(UIImage *)image shouldCropImage:(BOOL)shouldCropImage {
    serverImage = image;
    
    [self setupServerImage];

    // update cropping status (to restore and show image correctly)
    KYCDocumentType type = [LWAuthSteps getDocumentTypeByStep:self.stepId];
    [[LWAuthManager instance].documentsStatus setCroppedStatus:type withCropped:shouldCropImage];
    
    [self setupPreviewImageFromServerImage:serverImage shouldCropImage:shouldCropImage];
}

- (void)uploadImage:(UIImage *)image docType:(KYCDocumentType)docType {
    
    UIImage *lastImage = [[LWAuthManager instance].documentsStatus lastUploadedImageForType:docType];
    if (lastImage == serverImage) {
        // modify self documents status
        [[LWAuthManager instance].documentsStatus setTypeUploaded:docType withImage:image];
        
        // navigate to next step
        LWAuthNavigationController *navController = (LWAuthNavigationController *)self.navigationController;
        [navController navigateWithDocumentStatus:[LWAuthManager instance].documentsStatus hideBackButton:NO];
    }
    else {
        __block UIViewController *mainController = self;
        
        LWPacketKYCSendDocument *pack = [LWPacketKYCSendDocument new];
        pack.docType = docType;

        // set document compression
        double const compression = [[LWAuthManager instance].documentsStatus compression:docType];
        pack.imageJPEGRepresentation = UIImageJPEGRepresentation(image, compression);
        
        NSURL *url = [NSURL URLWithString:pack.urlBase];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]
                                         initWithBaseURL:url];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        NSDictionary *headers = [pack headers];
        for (NSString *key in headers.allKeys) {
            [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
        
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.dimBackground = YES;
        hud.detailsLabelText = Localize(@"register.camera.hud.title");
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(uploadCanceled)];
        [hud addGestureRecognizer:gesture];
        
        uploadTask = [manager POST:pack.urlRelative parameters:pack.params
                          progress:^(NSProgress * _Nonnull uploadProgress) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  hud.progress = uploadProgress.fractionCompleted;
                              });
                          }
                           success:^(NSURLSessionTask *task, id responseObject) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [hud hide:YES];
                                   
                                   [pack parseResponse:responseObject error:nil];
                                   
                                   // set photo to last image
                                   //lastUploadedImage = photo;
                                   
                                   // modify self documents status
                                   KYCDocumentType docType = ((LWPacketKYCSendDocument *)pack).docType;
                                   [[LWAuthManager instance].documentsStatus setTypeUploaded:docType withImage:serverImage];
                                   
                                   // navigate to next step
                                   LWAuthNavigationController *navController = (LWAuthNavigationController *)mainController.navigationController;
                                   [navController navigateWithDocumentStatus:[LWAuthManager instance].documentsStatus hideBackButton:NO];
                               });
                           }
                           failure:^(NSURLSessionTask *operation, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [hud hide:YES];
                                   
                                   if (error && error.code != NSURLErrorCancelled) {
                                       NSMutableDictionary *errorInfo = [[NSMutableDictionary alloc] initWithObjects:@[ error.localizedDescription, [NSNumber numberWithInt:-1]] forKeys:@[ @"Message", @"Code" ]];
                                       [mainController showReject:errorInfo response:operation.response];
                                   }
                               });
                           }];
    }
}

- (void)updateStep:(KYCDocumentType)docType {
    UIImage *image = nil;
    switch (docType) {
        case KYCDocumentTypeSelfie:
            image = [UIImage imageNamed:@"RegisterLineStep2"];
            break;
        case KYCDocumentTypeIdCard:
            image = [UIImage imageNamed:@"RegisterLineStep3"];
            break;
        case KYCDocumentTypeProofOfAddress:
            image = [UIImage imageNamed:@"RegisterLineStep4"];
            break;
        default:
            break;
    }
    [self.stepImageView setImage:image];
}

- (void)uploadCanceled {
    if (hud) {
        [hud hide:YES];
    }
    if (uploadTask) {
        [uploadTask cancel];
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    [self checkButtonsState];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:NO completion:^{
        [self setupImage:image shouldCropImage:YES];
    }];
    
    [self checkButtonsState];
}


#pragma mark - LWCameraOverlayDelegate

- (void)fileChoosen:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (self.imagePickerController) {
        [self.imagePickerController dismissViewControllerAnimated:NO completion:^{
            [self setupImage:image shouldCropImage:NO];
        }];
    }
    
    [self checkButtonsState];
}

- (void)pictureTaken {
    self.showCameraImmediately = NO;
}


#pragma mark - Properties

- (void)setCurrentStep:(LWAuthStep)currentStep {
    _currentStep = currentStep;
    self.promptLabel.text = Localize([LWAuthSteps titleByStep:currentStep]);
}

@end
