//
//  LWMyLykkeDepositBTCPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeDepositBTCPresenter.h"
#import "LWCommonButton.h"
#import "LWPrivateWalletAssetModel.h"
#import "LWPrivateWalletModel.h"
#import "UIImage+Resize.h"
#import "UIViewController+Navigation.h"
#import "LWConstants.h"
#import "UIView+Toast.h"
#import "UIViewController+Loading.h"
#import "LWCache.h"

@interface LWMyLykkeDepositBTCPresenter ()

@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet LWCommonButton *clipboardButton;
@property (weak, nonatomic) IBOutlet LWCommonButton *emailButton;

@end

@implementation LWMyLykkeDepositBTCPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupQRCode];
    self.emailButton.type=BUTTON_TYPE_COLORED;
    self.clipboardButton.type=BUTTON_TYPE_CLEAR;
    self.emailButton.enabled=YES;
    self.clipboardButton.enabled=YES;
    self.addressLabel.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setBackButton];
    UIColor *color = [UIColor colorWithHexString:kMainGrayElementsColor];
    [self.navigationController.navigationBar setBarTintColor:color];


}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"BUY LYKKE";
}

- (IBAction)copyClicked:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.addressLabel.text;
    
//    [self.navigationController.view makeToast:@"COPIED"];
    [self showCopied];
}

-(IBAction)emailClicked:(id)sender
{
    [self setLoading:YES];
    [[LWAuthManager instance] requestEmailBlockchainForAssetId:@"LKK" address:[LWCache instance].btcConversionWalletAddress];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self setLoading:NO];
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void)authManagerDidSendBlockchainEmail:(LWAuthManager *)manager {
    [self setLoading:NO];
    
    [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.sendemail")];
}



- (void)setupQRCode {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    NSString *bitcoinHash = [LWCache instance].btcConversionWalletAddress;
    
    self.addressLabel.text = bitcoinHash;
    
    //    NSString *qrCodeString = [NSString stringWithFormat:@"%@%@", @"bitcoin:", bitcoinHash];
    NSString *qrCodeString = bitcoinHash;
    NSData *data = [qrCodeString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
    
    // Resize without interpolating
    CGSize const imageViewSize = self.qrCodeImageView.frame.size;
    UIImage *qrImage = [image resizedImage:imageViewSize
                      interpolationQuality:kCGInterpolationNone];
    
    self.qrCodeImageView.image = qrImage;
    
    CGImageRelease(cgImage);
}


@end
