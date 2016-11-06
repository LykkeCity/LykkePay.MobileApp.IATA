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
{
    NSString *etheriumAddress;
}

@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet LWCommonButton *clipboardButton;
@property (weak, nonatomic) IBOutlet LWCommonButton *emailButton;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation LWMyLykkeDepositBTCPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    [self adjustThinLines];

//    if([self.assetId isEqualToString:@"BTC"])
//    {
//        [self setupQRCode];
//        self.titleLabel.text=@"To buy Lykke coins, send BTC to this address";
//        self.textLabel.text=@"Lykke coins will be transferred to your Lykke Wallet as soon as the BTC transaction is detected";
//    }
//    else
//    {
//        self.titleLabel.text=@"To buy Lykke coins, send ETH to this address";
//        self.textLabel.text=@"Lykke coins will be transferred to your Lykke Wallet as soon as the ETH transaction is detected";
//
//    }
    
    self.emailButton.type=BUTTON_TYPE_COLORED;
    self.clipboardButton.type=BUTTON_TYPE_CLEAR;
    self.emailButton.enabled=YES;
    self.clipboardButton.enabled=YES;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        self.addressLabel.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    [self setupQRCode];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
//    {
//    [self setBackButton];
//    UIColor *color = [UIColor colorWithHexString:kMainGrayElementsColor];
//    [self.navigationController.navigationBar setBarTintColor:color];
//    }
//    else
//        [self.navigationController setNavigationBarHidden:YES];

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (IBAction)copyClicked:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.addressLabel.text;
    
    [self.navigationController.view makeToast:@"Copied."];
//    [self showCopied];
}

-(IBAction)emailClicked:(id)sender
{
    [self setLoading:YES];
    [[LWAuthManager instance] requestEmailBlockchainForAssetId:@"LKK" address:[LWCache instance].coloredMultiSig];
//    [[LWAuthManager instance] requestSendMyLykkeCashInEmail:@{@"AssetId":_assetId, @"Amount":@(_amount), @"LkkAmount":@(_lkkAmount), @"Price":@(_price)}];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self setLoading:NO];
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void)authManagerDidSendBlockchainEmail:(LWAuthManager *)manager {
    [self setLoading:NO];
    
    [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.sendemail")];
}

//-(void) authManagerDidSendMyLykkeCashInEmail:(LWAuthManager *)manager
//{
//    [self setLoading:NO];
//    [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.sendemail")];
//
//}

//-(void) authManagerDidGetEthereumAddress:(LWPacketGetEthereumAddress *)ethereumAddressPacket
//{
//    [self setLoading:NO];
//    etheriumAddress=ethereumAddressPacket.ethereumAddress;
//    [self setupQRCode];
//}


- (void)setupQRCode {
    self.qrCodeImageView.hidden=NO;
    self.addressLabel.hidden=NO;
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    
    self.addressLabel.text = [LWCache instance].coloredMultiSig;
    
    //    NSString *qrCodeString = [NSString stringWithFormat:@"%@%@", @"bitcoin:", bitcoinHash];
    NSString *qrCodeString = self.addressLabel.text;
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


-(NSString *) nibName
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        return @"LWMyLykkeDepositBTCPresenter_ipad";
    }
    else
    {
        if([UIScreen mainScreen].bounds.size.width==320)
            return @"LWMyLykkeDepositBTCPresenter_iphone5";
        else
            return @"LWMyLykkeDepositBTCPresenter_iphone";
    }
}



@end
