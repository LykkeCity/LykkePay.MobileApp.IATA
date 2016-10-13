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


@interface LWKYCNewPresenter () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController *picker;
    
    NSMutableDictionary *photos;
    
    NSArray *titles;
    
    KYCDocumentType activeType;
    
}

@property (weak, nonatomic) IBOutlet LWKYCCameraTopBarView *topBarView;
@property (weak, nonatomic) IBOutlet LWKYCPhotoContainerView *photoContainerView;
@property (weak, nonatomic) IBOutlet LWCommonButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LWKYCNewPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titles=@[@"Make a selfie", @"Make a photo of your passport or other ID", @"Make a photo of Proof of Address, e.g. utility bill"];
    
    photos=[[NSMutableDictionary alloc] init];
    
    activeType=KYCDocumentTypeSelfie;
    
//    _documentsStatuses=@{@(KYCDocumentTypeSelfie):@(KYCDocumentStatusEmpty), @(KYCDocumentTypePassport):@(KYCDocumentStatusEmpty), @(KYCDocumentTypeAddress):@(KYCDocumentStatusRejected), @"ActiveType":@(KYCDocumentTypeSelfie)};
    
    
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


    // Do any additional setup after loading the view from its nib.
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
    
    
    LWKYCPhotoContainerView *prevContainer=[[LWKYCPhotoContainerView alloc] initWithFrame:_photoContainerView.frame];

    prevContainer.status=[_documentsStatuses statusForDocument:activeType];
    prevContainer.title=titles[activeType];
    prevContainer.image=[_documentsStatuses imageForType:activeType];
    prevContainer.failedDescription=[_documentsStatuses commentForType:activeType];

    [self.view addSubview:prevContainer];
    
    _photoContainerView.hidden=YES;

    
    activeType++;

    [_topBarView setActiveType:activeType];
    LWKYCPhotoContainerView *tmpContainer=[[LWKYCPhotoContainerView alloc] initWithFrame:_photoContainerView.frame];
    
    tmpContainer.status=[_documentsStatuses statusForDocument:activeType];
    tmpContainer.title=titles[activeType];
    tmpContainer.image=[_documentsStatuses imageForType:activeType];
    tmpContainer.failedDescription=[_documentsStatuses commentForType:activeType];

    tmpContainer.center=CGPointMake(self.view.bounds.size.width*1.5, _photoContainerView.center.y);
    [self.view addSubview:tmpContainer];
    
    
//    self.view.translatesAutoresizingMaskIntoConstraints=NO;
    [UIView animateWithDuration:0.5 animations:^{
        prevContainer.center=CGPointMake(self.view.bounds.size.width*-0.5, _photoContainerView.center.y);
        tmpContainer.center=CGPointMake(self.view.bounds.size.width*0.5, _photoContainerView.center.y);
    
    } completion:^(BOOL finished){
        [tmpContainer removeFromSuperview];
        [prevContainer removeFromSuperview];
        _photoContainerView.hidden=NO;


        _photoContainerView.status=[_documentsStatuses statusForDocument:activeType];
        _photoContainerView.title=titles[activeType];
        _photoContainerView.image=[_documentsStatuses imageForType:activeType];
        _photoContainerView.failedDescription=[_documentsStatuses commentForType:activeType];

    }];
    
    [self checkDocumentsStatuses];
}

-(void) swipedRight
{
    
    if(activeType==KYCDocumentTypeSelfie)
        return;
    
    LWKYCPhotoContainerView *prevContainer=[[LWKYCPhotoContainerView alloc] initWithFrame:_photoContainerView.frame];
    
    prevContainer.status=[_documentsStatuses statusForDocument:activeType];
    prevContainer.title=titles[activeType];
    prevContainer.image=[_documentsStatuses imageForType:activeType];
    prevContainer.failedDescription=[_documentsStatuses commentForType:activeType];
    
    [self.view addSubview:prevContainer];
    
    _photoContainerView.hidden=YES;
    activeType--;

    _topBarView.documentsStatuses=_documentsStatuses;
    [_topBarView setActiveType:activeType];
    LWKYCPhotoContainerView *tmpContainer=[[LWKYCPhotoContainerView alloc] initWithFrame:_photoContainerView.frame];
    
    tmpContainer.status=[_documentsStatuses statusForDocument:activeType];
    tmpContainer.title=titles[activeType];
    tmpContainer.image=[_documentsStatuses imageForType:activeType];
    tmpContainer.failedDescription=[_documentsStatuses commentForType:activeType];
    
    tmpContainer.center=CGPointMake(self.view.bounds.size.width*-0.5, _photoContainerView.center.y);
    [self.view addSubview:tmpContainer];
    [UIView animateWithDuration:0.5 animations:^{
        prevContainer.center=CGPointMake(self.view.bounds.size.width*1.5, _photoContainerView.center.y);
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
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) shootPressed
{
    picker = [[LWKYCImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if(activeType==KYCDocumentTypeSelfie)
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    else
        picker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
    picker.showsCameraControls = YES;
    
    
    
//    UIView *overlay=[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    
//    picker.cameraOverlayView=overlay;
    
    
//    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//    float cameraAspectRatio = 4.0 / 3.0;
//    float imageHeight = screenSize.width * cameraAspectRatio;
//    float verticalAdjustment;
//    if (screenSize.height - imageHeight <= 54.0f) {
//        verticalAdjustment = 0;
//    } else {
//        verticalAdjustment = (screenSize.height - imageHeight) / 2.0f;
//        verticalAdjustment /= 2.0f; // A little bit upper than centered
//    }
//    CGAffineTransform transform = picker.cameraViewTransform;
//    
//    verticalAdjustment=100;
//    
//    transform.ty += verticalAdjustment;
//    
//    picker.cameraViewTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 200);
    
    
//    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
//    
//    CGFloat cameraAspectRatio = 4.0f/3.0f;
//    
//    CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
//    CGFloat scale = screenBounds.height / camViewHeight;
//    
//    UIView *vvv=picker.view;
//    picker.cameraViewTransform=CGAffineTransformMakeScale(2.0, 2.0);

//    picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
//    picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale);
    
    
    
    [self presentViewController:picker animated:YES
                     completion:^ {

                     }];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)_picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)_picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
//    UIImage *flippedImage = [UIImage imageWithCGImage:chosenImage.CGImage scale:chosenImage.scale orientation:UIImageOrientationLeftMirrored];
    _photoContainerView.image=chosenImage;
    _photoContainerView.status=KYCDocumentStatusUploaded;
    
    [_documentsStatuses setDocumentStatus:KYCDocumentStatusUploaded forDocument:activeType];
    [_documentsStatuses saveImage:chosenImage forType:activeType];
    
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
    
    if([_documentsStatuses statusForDocument:activeType]==KYCDocumentStatusEmpty)
        [_actionButton setTitle:@"SHOOT" forState:UIControlStateNormal];
    else
        [_actionButton setTitle:@"RESHOOT" forState:UIControlStateNormal];

    
    [_topBarView adjustStatuses];
}





//-(void) photoCaptured:(NSNotification *) notification
//{
//    if(picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
//    {
//        
//        NSArray *arr=picker.view.subviews;
//        id uuu=picker.cameraOverlayView;
////        [picker dismissViewControllerAnimated:YES completion:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//        [picker takePicture];
//        return;
//        id ooo=notification.object;
//        picker.cameraViewTransform = CGAffineTransformIdentity;
//        picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, -1,     1);
//    }
//}
//
//- (void)cameraChanged:(NSNotification *)notification
//{
//    
//    picker.cameraViewTransform = CGAffineTransformIdentity;
//
////    if(picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
////    {
////        picker.cameraViewTransform = CGAffineTransformIdentity;
////        picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, -1,     1);
////    } else {
////        picker.cameraViewTransform = CGAffineTransformIdentity;
////    }
//}



-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
