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
#import "UIViewController+Navigation.h"

#import "UIImage+Resize.h"

#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "LWSendImageManager.h"
#import "LWValidator.h"
#import "UIAlertView+Blocks.h"

#import "LWCameraMessageView.h"
#import "LWCameraMessageView2.h"

@import AVFoundation;


@interface LWRegisterCameraPresenter ()<LWAuthManagerDelegate, LWCameraOverlayDelegate, LWSendImageManagerDelegate, UIAlertViewDelegate> {
    LWCameraOverlayPresenter *cameraOverlayPresenter;

    MBProgressHUD        *hud;
    NSURLSessionDataTask *uploadTask;
    
    UIImage *serverImage;
    UIImage *previewImage;
    
    LWSendImageManager *sendImageManager;
    
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
    self.showCameraImmediately=YES;
    [LWValidator setButtonWithClearBackground:self.cancelButton enabled:YES];
    [LWValidator setButton:self.okButton enabled:YES];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = Localize(@"register.title");

    
    [self setBackButton];
    
    [self checkButtonsState];
    
    UIColor *cancelColor = [UIColor colorWithHexString:kMainDarkElementsColor];
    [self.cancelButton setTitleColor:cancelColor forState:UIControlStateNormal];
    
    // hide back button if necessary
    if (self.shouldHideBackButton) {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem=nil;
    }
    
    // if show camera view - reset flag for uploads
    KYCDocumentType type = [LWAuthSteps getDocumentTypeByStep:self.stepId];
    BOOL const croppedStatus = [[LWAuthManager instance].documentsStatus croppedStatus:type];
    if(!serverImage)
        serverImage = [[LWAuthManager instance].documentsStatus lastUploadedImageForType:type];
    [self setupPreviewImageFromServerImage:serverImage shouldCropImage:croppedStatus];

    [[LWAuthManager instance].documentsStatus resetTypeUploaded:type];
    
    if (self.showCameraImmediately && previewImage == nil) {
        [self showCameraView];
    }
    
    [self updateStep:type];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.title = Localize(@"register.title");

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
        self.cancelButton.hidden=NO;
    }
    else {
        [self.okButton setTitle:[Localize(@"register.camera.photo.take") uppercaseString]
                       forState:UIControlStateNormal];
        self.cancelButton.hidden=YES;
    }
}

- (void)showCameraView {
    
    
    void (^block)(void)=^{

    // configure overlay
        if (!cameraOverlayPresenter) {
            cameraOverlayPresenter = [LWCameraOverlayPresenter new];
        }
        
        UIImagePickerController *picker = [UIImagePickerController new];
        // if camera is unavailable - set photo library
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            // configure image picker
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            picker.cameraDevice = ((self.stepId == LWAuthStepRegisterSelfie)
                                   ? UIImagePickerControllerCameraDeviceFront
                                   : UIImagePickerControllerCameraDeviceRear);
            picker.allowsEditing = YES;
            
            if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
            {
                picker.showsCameraControls = NO;
                picker.modalPresentationStyle = UIModalPresentationCurrentContext;
                
                picker.toolbarHidden = YES;
                
                cameraOverlayPresenter.pickerReference = picker;
                cameraOverlayPresenter.view.frame = picker.cameraOverlayView.frame;
                cameraOverlayPresenter.step = self.stepId;
                cameraOverlayPresenter.delegate = self;
                
                picker.cameraViewTransform=CGAffineTransformMakeTranslation(0, 100);
                picker.cameraOverlayView = cameraOverlayPresenter.view;
            }
            else
            {
                picker.showsCameraControls = YES;
                picker.toolbarHidden=YES;
                picker.modalPresentationStyle=UIModalPresentationOverFullScreen;
            }
        }
        else {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        picker.delegate = self;
        
        self.imagePickerController = picker;
        //    [self presentViewController:picker animated:YES completion:nil];
        
        [self.navigationController presentViewController:self.imagePickerController animated:NO completion:^{
            [cameraOverlayPresenter updateView];
        }];
        
        [self checkButtonsState];
    };
    
    void (^messageBlock)(void)=^{
        
        LWCameraMessageView *view=[[NSBundle mainBundle] loadNibNamed:@"LWCameraMessageView" owner:self options:nil][0];
        UIWindow *window=[[UIApplication sharedApplication] keyWindow];
        view.frame=window.bounds;

        
        [window addSubview:view];
        
        [view show];
    };

    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        block();
    } else if(authStatus == AVAuthorizationStatusDenied){
        messageBlock();
        
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        
        LWCameraMessageView2 *view=[[NSBundle mainBundle] loadNibNamed:@"LWCameraMessageView2" owner:self options:nil][0];
        UIWindow *window=[[UIApplication sharedApplication] keyWindow];
        view.center=CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);
        
        [window addSubview:view];
        
        [view showWithCompletion:^(BOOL result){
            if(result)
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(granted){
                            block();
                        } else {
                            messageBlock();
                        }
                    });
                }];
        }];

        
        
     } else {
        // impossible, unknown authorization status
    }

    
    
}



- (void)setupServerImage {
    if (serverImage == nil) {
        return;
    }
    
    serverImage = [serverImage correctImageOrientation];
    
    
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

    [self checkButtonsState];
    if (image == nil) {
        self.photoImageView.image = nil;
        return;
    }
    
    // resize to our view
    previewImage = [serverImage copy];
//    CGFloat coeff = self.view.frame.size.width / previewImage.size.width;
//    CGSize size = CGSizeMake(previewImage.size.width * coeff, previewImage.size.height * coeff);
//    previewImage = [previewImage resizedImage:size interpolationQuality:kCGInterpolationDefault];
    self.photoImageView.clipsToBounds=YES;
    self.photoImageView.contentMode=UIViewContentModeScaleAspectFill;
    // crop image for selfie
//    if (shouldCropImage) {
//        CGRect cropRect = self.photoImageView.frame;
//        // hidden navigation bar
//        CGFloat const navHeight = 56;
//        cropRect.origin.y += navHeight;
//        previewImage = [previewImage croppedImage:cropRect];
//    }
    
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
        
        
        if(self.delegate)
        {
            [self.delegate cameraPresenterDidSendPhoto:self];
        }
        else
        {
            // navigate to next step
            LWAuthNavigationController *navController = (LWAuthNavigationController *)self.navigationController;
            [navController navigateWithDocumentStatus:[LWAuthManager instance].documentsStatus hideBackButton:NO];
        }
    }
    else {
//        __block UIViewController *mainController = self;
        
//        LWPacketKYCSendDocument *pack = [LWPacketKYCSendDocument new];
//        pack.docType = docType;
//
//        // set document compression
//        double const compression = [[LWAuthManager instance].documentsStatus compression:docType];
//        pack.imageJPEGRepresentation = UIImageJPEGRepresentation(image, compression);
        
//        NSURL *url = [NSURL URLWithString:pack.urlBase];
//        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]
//                                         initWithBaseURL:url];
//        manager.requestSerializer = [AFJSONRequestSerializer serializer];
//        
//        NSDictionary *headers = [pack headers];
//        for (NSString *key in headers.allKeys) {
//            [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
//        }
        
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.dimBackground = YES;
        hud.detailsLabelText = Localize(@"register.camera.hud.title");
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(uploadCanceled)];
        [hud addGestureRecognizer:gesture];
        
        sendImageManager=[[LWSendImageManager alloc] init];
        sendImageManager.type=docType;
        sendImageManager.delegate=self;
        [sendImageManager sendImageWithData:UIImageJPEGRepresentation(image, 0.9) type:docType];

    }
}

- (void)updateStep:(KYCDocumentType)docType {
    UIImage *image = nil;
    switch (docType) {
        case KYCDocumentTypeSelfie:
            image = [UIImage imageNamed:@"RegisterLineStep2"];
            break;
        case KYCDocumentTypeIdCard:
            image = [UIImage imageNamed:@"RegisterLineStep2"];
            break;
        case KYCDocumentTypeProofOfAddress:
            image = [UIImage imageNamed:@"RegisterLineStep2"];
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
    
    [sendImageManager stopUploading];
}

#pragma mark - LWSendImageManagerDelegate

-(void) sendImageManager:(LWSendImageManager *)manager didFailWithErrorMessage:(NSString *)message
{
    [hud hide:YES];
    
    
        NSMutableDictionary *errorInfo=[@{@"Message":message, @"Code":@(-1)} mutableCopy];
        [self showReject:errorInfo response:nil];


}

-(void) sendImageManagerSentImage:(LWSendImageManager *)manager
{
    [hud hide:YES];
    
    // modify self documents status
    KYCDocumentType docType = manager.type;
    [[LWAuthManager instance].documentsStatus setTypeUploaded:docType withImage:serverImage];
    
    if(self.delegate)
    {
        [self.delegate cameraPresenterDidSendPhoto:self];
    }
    else
    {
        // navigate to next step
        LWAuthNavigationController *navController = (LWAuthNavigationController *)self.navigationController;
        [navController navigateWithDocumentStatus:[LWAuthManager instance].documentsStatus hideBackButton:NO];
    }

}

-(void) sendImageManager:(LWSendImageManager *)manager changedProgress:(float)progress
{
    hud.progress = progress;
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    [self checkButtonsState];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self setupImage:image shouldCropImage:YES];

    [picker dismissViewControllerAnimated:NO completion:^{
//        [self setupImage:image shouldCropImage:YES];
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
