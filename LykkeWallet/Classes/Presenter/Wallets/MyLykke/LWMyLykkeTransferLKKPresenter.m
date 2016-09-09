//
//  LWMyLykkeTransferLKKPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeTransferLKKPresenter.h"
#import "LWCommonButton.h"
#import "LWPrivateWalletAssetModel.h"
#import "LWPrivateWalletModel.h"
#import "UIImage+Resize.h"
#import "UIViewController+Navigation.h"
#import "LWConstants.h"
#import "UIView+Toast.h"
#import "UIViewController+Loading.h"
#import "LWCache.h"
#import "LWPacketGetEthereumAddress.h"
#import "LWMyLykkeBuyPresenter.h"

@interface LWMyLykkeTransferLKKPresenter ()
{
    NSString *etheriumAddress;
}

@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet LWCommonButton *clipboardButton;
@property (weak, nonatomic) IBOutlet LWCommonButton *emailButton;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UIButton *topTransferButton;


@end

@implementation LWMyLykkeTransferLKKPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    [self adjustThinLines];

    self.emailButton.type=BUTTON_TYPE_COLORED;
    self.clipboardButton.type=BUTTON_TYPE_CLEAR;
    self.emailButton.enabled=YES;
    self.clipboardButton.enabled=YES;
    [self setupQRCode];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        self.addressLabel.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    
    _topTransferButton.layer.cornerRadius=_topTransferButton.bounds.size.height/2;
    _topTransferButton.clipsToBounds=YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        [self setBackButton];
        
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    }
    else
        [self.navigationController setNavigationBarHidden:YES];

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        self.title=@"DEPOSIT LYKKE";

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
    [[LWAuthManager instance] requestEmailBlockchainForAssetId:@"LKK" address:nil];
}

-(IBAction)buyTopButtonPressed:(id)sender
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        LWMyLykkeBuyPresenter *presenter=[LWMyLykkeBuyPresenter new];
        NSMutableArray *arr=[NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [arr removeLastObject];
        [arr addObject:presenter];
        [self.navigationController setViewControllers:arr];

    }
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self setLoading:NO];
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

//- (void)authManagerDidSendBlockchainEmail:(LWAuthManager *)manager {
//    [self setLoading:NO];
//    
//    [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.sendemail")];
//}

-(void) authManagerDidSendBlockchainEmail:(LWAuthManager *)manager
{
    [self setLoading:NO];
    [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.sendemail")];

}



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


@end
