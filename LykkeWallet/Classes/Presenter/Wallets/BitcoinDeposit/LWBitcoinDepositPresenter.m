//
//  LWBitcoinDepositPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 15.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBitcoinDepositPresenter.h"
#import "LWAuthManager.h"
#import "LWConstants.h"
#import "LWCache.h"
#import "TKButton.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "UIView+Toast.h"
#import "UIImage+Resize.h"


@interface LWBitcoinDepositPresenter () {
    UIColor *navigationTintColor;
}

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *bitcoinHashLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bitcoinQRImageView;
@property (nonatomic, weak) IBOutlet TKButton *copyingButton;
@property (nonatomic, weak) IBOutlet TKButton *emailButton;


#pragma mark - Utils

- (void)updateView;
- (BOOL)isColoredMultisig;

@end

@implementation LWBitcoinDepositPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:Localize(@"wallets.bitcoin.deposit"), self.assetName];
    
    [self setupQRCode];
    [self setBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#ifdef PROJECT_IATA
#else
    [self.copyingButton setGrayPalette];
    [self.bitcoinHashLabel setTextColor:[UIColor colorWithHexString:kMainElementsColor]];
#endif
    
    [self updateView];
}

- (void)colorize {
    navigationTintColor = self.navigationController.navigationBar.barTintColor;
    
#ifdef PROJECT_IATA
#else
    UIColor *color = [UIColor colorWithHexString:kMainGrayElementsColor];
    [self.navigationController.navigationBar setBarTintColor:color];
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.barTintColor = navigationTintColor;
    
    [super viewWillDisappear:animated];
}


#pragma mark - Actions

- (IBAction)copyClicked:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.bitcoinHashLabel.text;
    
    [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.copytoast")];
}

- (IBAction)emailClicked:(id)sender {
    [self setLoading:YES];
    [[LWAuthManager instance] requestEmailBlockchainForAssetId:self.assetID?self.assetID:self.issuerId];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void)authManagerDidSendBlockchainEmail:(LWAuthManager *)manager {
    [self setLoading:NO];

    [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.sendemail")];
}


#pragma mark - Private

- (void)setupQRCode {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    NSString *bitcoinHash = [self isColoredMultisig]
    ? [LWCache instance].coloredMultiSig
    : [LWCache instance].multiSig;
    
    self.bitcoinHashLabel.text = bitcoinHash;
    
    NSString *qrCodeString = [NSString stringWithFormat:@"%@%@", @"bitcoin:", bitcoinHash];
    NSData *data = [qrCodeString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
    
    // Resize without interpolating
    CGSize const imageViewSize = self.bitcoinQRImageView.frame.size;
    UIImage *qrImage = [image resizedImage:imageViewSize
                      interpolationQuality:kCGInterpolationNone];
    
    self.bitcoinQRImageView.image = qrImage;
    
    CGImageRelease(cgImage);
}


#pragma mark - Utils

- (void)updateView {
    
}

- (BOOL)isColoredMultisig {
    if ([self.issuerId isEqualToString:@"BTC"]) {
        return NO;
    }
    else if ([self.issuerId isEqualToString:@"LKE"]) {
        return YES;
    }
    return NO;
}

@end
