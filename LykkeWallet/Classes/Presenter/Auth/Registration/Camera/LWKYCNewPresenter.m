//
//  LWKYCPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWKYCNewPresenter.h"
#import "LWKYCCameraTopBarView.h"
#import "LWCommonButton.h"
#import "LWKYCPhotoContainerView.h"
#import "LWKYCImagePickerController.h"
#import "LWKYCLaterMessageView.h"
#import "UIImage+Resize.h"
#import "LWCameraMessageView.h"
#import "LWCameraMessageView2.h"

@import AVFoundation;


@interface LWKYCNewPresenter () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LWKYCCameraTopBarViewDelegate, LWKYCLaterMessageViewDelegate>
{
    UIImagePickerController *picker;
    
    NSMutableDictionary *photos;
    
    NSArray *titles;
    
    KYCDocumentType activeType;
    
    BOOL flagUploadedNewPhoto;
    
}

@property (weak, nonatomic) IBOutlet LWKYCCameraTopBarView *topBarView;
@property (weak, nonatomic) IBOutlet LWKYCPhotoContainerView *photoContainerView;
@property (weak, nonatomic) IBOutlet LWCommonButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionButtonWidth;

@end

@implementation LWKYCNewPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    flagUploadedNewPhoto=NO;
    
    [_nextButton setTitleColor:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:.2] forState:UIControlStateDisabled];
    
    
    titles=@[@"Take a selfie", @"Take a photo of your passport or another ID", @"Take a photo of your proof of address, such as a utility bill"];
    
    photos=[[NSMutableDictionary alloc] init];
    
    activeType=KYCDocumentTypeSelfie;
    for(KYCDocumentType t=KYCDocumentTypeSelfie;t<=KYCDocumentTypeProofOfAddress;t++)
    {
        if([_documentsStatuses statusForDocument:t]==KYCDocumentStatusEmpty || [_documentsStatuses statusForDocument:t]==KYCDocumentStatusRejected)
        {
            activeType=t;
            break;
        }
    }
    
    
    [_actionButton addTarget:self action:@selector(shootPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _topBarView.documentsStatuses=_documentsStatuses;
    [_topBarView setActiveType:activeType];
    
    _photoContainerView.status=[_documentsStatuses statusForDocument:activeType];
    _photoContainerView.title=titles[activeType];
    _photoContainerView.image=[_documentsStatuses imageForType:activeType];
    _photoContainerView.failedDescription=[_documentsStatuses commentForType:activeType];
    
    [self checkDocumentsStatuses];
    
    UISwipeGestureRecognizer *swipeLeft=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft)];
    swipeLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];

    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    _topBarView.delegate=self;
    
    if([UIScreen mainScreen].bounds.size.width==320)
        _actionButtonWidth.constant=280;

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    NSDictionary *attr=@{NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSKernAttributeName:@(1.5), NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]};
    _titleLabel.attributedText=[[NSAttributedString alloc] initWithString:@"REGISTER" attributes:attr];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) swipedLeft
{
    
    if(activeType==KYCDocumentTypeProofOfAddress)
        return;
    
    [self stepToDirection:1];

}

-(void) swipedRight
{
    if(activeType==KYCDocumentTypeSelfie)
        return;

    [self stepToDirection:-1];
}

-(void) stepToDirection:(int) step
{
    
    
    LWKYCPhotoContainerView *prevContainer=[[LWKYCPhotoContainerView alloc] initWithFrame:_photoContainerView.frame];
    
    prevContainer.status=[_documentsStatuses statusForDocument:activeType];
    prevContainer.title=titles[activeType];
    prevContainer.image=[_documentsStatuses imageForType:activeType];
    prevContainer.failedDescription=[_documentsStatuses commentForType:activeType];
    
    [self.view addSubview:prevContainer];
    
    _photoContainerView.hidden=YES;
    activeType+=step;

    _topBarView.documentsStatuses=_documentsStatuses;
    [_topBarView setActiveType:activeType];
    LWKYCPhotoContainerView *tmpContainer=[[LWKYCPhotoContainerView alloc] initWithFrame:_photoContainerView.frame];
    
    tmpContainer.status=[_documentsStatuses statusForDocument:activeType];
    tmpContainer.title=titles[activeType];
    tmpContainer.image=[_documentsStatuses imageForType:activeType];
    tmpContainer.failedDescription=[_documentsStatuses commentForType:activeType];
    
    tmpContainer.center=CGPointMake(self.view.bounds.size.width*(0.5+(step/abs(step))), _photoContainerView.center.y);
    [self.view addSubview:tmpContainer];
    [UIView animateWithDuration:0.5 animations:^{
        prevContainer.center=CGPointMake(self.view.bounds.size.width*(0.5+(-step/abs(step))), _photoContainerView.center.y);
        tmpContainer.center=CGPointMake(self.view.bounds.size.width*0.5, _photoContainerView.center.y);
        
    } completion:^(BOOL finished){
        [tmpContainer removeFromSuperview];
        [prevContainer removeFromSuperview];
        _photoContainerView.hidden=NO;
        _photoContainerView.status=[_documentsStatuses statusForDocument:activeType];
        _photoContainerView.title=titles[activeType];
        _photoContainerView.image=[_documentsStatuses imageForType:activeType];
        _photoContainerView.failedDescription=[_documentsStatuses commentForType:activeType];;
    }];
    
    [self checkDocumentsStatuses];

}

-(IBAction)crossPressed:(id)sender
{
    BOOL flagOK=YES;
    for(KYCDocumentType t=KYCDocumentTypeSelfie;t<=KYCDocumentTypeProofOfAddress;t++)
    {
        if([_documentsStatuses statusForDocument:t]==KYCDocumentStatusRejected || [_documentsStatuses statusForDocument:t]==KYCDocumentStatusEmpty)
        {
            flagOK=NO;
            break;
        }
    }

    
    if(flagUploadedNewPhoto==NO || flagOK)
    {
        [self laterMessageViewDismissed];
        return;
    }
    LWKYCLaterMessageView *view=[[[NSBundle mainBundle] loadNibNamed:@"LWKYCLaterMessageView" owner:self options:nil] objectAtIndex:0];
    view.delegate=self;
    [view show];
}

-(void) laterMessageViewDismissed
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) shootPressed
{
    [self showCameraView];
//    picker = [[LWKYCImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    if(activeType==KYCDocumentTypeSelfie)
//        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
//    else
//        picker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
//    picker.showsCameraControls = YES;
//    
//    
//    
//    
//    [self presentViewController:picker animated:YES
//                     completion:^ {
//
//                     }];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)_picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)_picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *chosenImage = [info[UIImagePickerControllerOriginalImage] correctImageOrientation];
//    UIImage *flippedImage = [UIImage imageWithCGImage:chosenImage.CGImage scale:chosenImage.scale orientation:UIImageOrientationLeftMirrored];
    _photoContainerView.image=chosenImage;
    _photoContainerView.status=KYCDocumentStatusUploaded;
    
    [_documentsStatuses setDocumentStatus:KYCDocumentStatusUploaded forDocument:activeType];
    [_documentsStatuses saveImage:chosenImage forType:activeType];
    flagUploadedNewPhoto=YES;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self checkDocumentsStatuses];
}

-(void) checkDocumentsStatuses
{
    KYCDocumentStatus status=[_documentsStatuses statusForDocument:activeType];
    if(status==KYCDocumentStatusUploaded || status==KYCDocumentStatusApproved)
        _nextButton.enabled=YES;
    else
        _nextButton.enabled=NO;
    if([_documentsStatuses statusForDocument:activeType]==KYCDocumentStatusEmpty || [_documentsStatuses statusForDocument:activeType]==KYCDocumentStatusRejected)
    {
        
        _actionButton.type=BUTTON_TYPE_COLORED;
    }
    else
    {
        _actionButton.type=BUTTON_TYPE_CLEAR;

    }
    
    _actionButton.hidden=[_documentsStatuses statusForDocument:activeType]==KYCDocumentStatusApproved;
    
    if([_documentsStatuses statusForDocument:activeType]==KYCDocumentStatusEmpty)
        [_actionButton setTitle:@"SHOOT" forState:UIControlStateNormal];
    else
        [_actionButton setTitle:@"RESHOOT" forState:UIControlStateNormal];

    
    [_topBarView adjustStatuses];
}

-(void) kycTopBarViewPressedDocumentType:(KYCDocumentType)type
{
    if(type!=activeType)
        [self stepToDirection:type-activeType];
}

-(IBAction) nextPressed:(id) sender
{
    BOOL flagOK=YES;
    for(KYCDocumentType t=KYCDocumentTypeSelfie;t<=KYCDocumentTypeProofOfAddress;t++)
    {
        if([_documentsStatuses statusForDocument:t]==KYCDocumentStatusRejected || [_documentsStatuses statusForDocument:t]==KYCDocumentStatusEmpty)
        {
            flagOK=NO;
            break;
        }
    }
    if(flagOK)
    {
        [self.delegate kycPresenterUserSubmitted:self];
        return;
    }
    
    for(KYCDocumentType t=activeType;;t++)
    {
        if(t==3)
            t=0;
        if([_documentsStatuses statusForDocument:t]==KYCDocumentStatusRejected || [_documentsStatuses statusForDocument:t]==KYCDocumentStatusEmpty)
        {
            [self stepToDirection:t-activeType];
            break;
        }
    }

}


- (void)showCameraView {
    
    
    void (^block)(void)=^{
        
        picker = [[LWKYCImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if(activeType==KYCDocumentTypeSelfie)
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        else
            picker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
        picker.showsCameraControls = YES;
        
        
        
        
        [self presentViewController:picker animated:YES
                         completion:^ {
                             
                         }];
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


-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
