//
//  LWKYCImagePickerController.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 08/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWKYCImagePickerController.h"

@import AVFoundation;

@interface LWKYCImagePickerController ()

@end

@implementation LWKYCImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraIsReadyNotification) name:AVCaptureSessionDidStartRunningNotification object:nil];
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

}

//-(void) cameraIsReadyNotification
//{
//    dispatch_async(dispatch_get_main_queue(), ^{  self.cameraViewTransform=CGAffineTransformMakeScale(2.0, 2.0);});
//}
//
//-(void) dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return NO;
//}
//
//-(UIInterfaceOrientationMask) supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
