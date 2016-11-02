//
//  LWPrivateWalletAddressPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletAddressPresenter.h"
#import "LWWalletsTypeButton.h"
#import "LWPrivateWalletModel.h"
#import "LWPrivateKeyManager.h"
#import "UIImage+Resize.h"
#import "LWCommonButton.h"
#import "UIView+Toast.h"

@interface LWPrivateWalletAddressPresenter ()

@property (weak, nonatomic) IBOutlet LWWalletsTypeButton *bitcoinButton;
@property (weak, nonatomic) IBOutlet LWWalletsTypeButton *coloredButton;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressTitleLabel;

@property (weak, nonatomic) IBOutlet LWCommonButton *buttonCopy;



@end

@implementation LWPrivateWalletAddressPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    _bitcoinButton.selected=YES;
    _coloredButton.selected=NO;
    _buttonCopy.type=BUTTON_TYPE_CLEAR;
    [self adjustThinLines];
    
    [_bitcoinButton addTarget:self action:@selector(addressTypeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_coloredButton addTarget:self action:@selector(addressTypeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];;
    [self setBackButton];
    
    [self.view layoutIfNeeded];
    [self setupQRCode];

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}




-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"WALLET ADDRESS";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) addressTypeButtonPressed:(LWWalletsTypeButton *) button
{
    _bitcoinButton.selected=NO;
    _coloredButton.selected=NO;
    button.selected=YES;
    
    [self setupQRCode];
        
}

- (void)setupQRCode {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    NSString *bitcoinHash;//=_wallet.address;
    if(_bitcoinButton.selected)
    {
        bitcoinHash=_wallet.address;
        _addressTitleLabel.text=@"Bitcoin wallet address";
    }
    else
    {
        bitcoinHash=[[LWPrivateKeyManager shared] coloredAddressFromBitcoinAddress:_wallet.address];
        _addressTitleLabel.text=@"Colored wallet address";

    }
    
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
    CGSize const imageViewSize = self.qrImageView.frame.size;
    UIImage *qrImage = [image resizedImage:imageViewSize
                      interpolationQuality:kCGInterpolationNone];
    
    qrImage=[self removeWhiteFromImage:qrImage];
    self.qrImageView.image = qrImage;

    CGImageRelease(cgImage);
}

- (IBAction)copyClicked:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.addressLabel.text;
    
    [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.copytoast")];
}

- (IBAction)emailClicked:(id)sender {
    [self setLoading:YES];
    
//    [[LWAuthManager instance] requestEmailBlockchainForAssetId:self.assetID?self.assetID:self.issuerId address:_addressLabel.text];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self setLoading:NO];
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void)authManagerDidSendBlockchainEmail:(LWAuthManager *)manager {
    [self setLoading:NO];
    
    [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.sendemail")];
}


-(UIImage *) removeWhiteFromImage:(UIImage *) image
{
    
    CGSize sss=image.size;
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext(); // here you don't need this reference for the context but if you want to use in the future for drawing anything else on the context you could get it for it
    [image drawInRect:CGRectMake(0.f, 0.f, image.size.width, image.size.height)];
    
    
    int width=(int)CGBitmapContextGetWidth(context);
    int height=(int)CGBitmapContextGetHeight(context);
    
    unsigned char *bitmap=CGBitmapContextGetData(context);
    
    int step=(int)CGBitmapContextGetBytesPerRow(context);
    
    for(int x=0;x<width;x++)
        for(int y=0;y<height;y++)
        {
            if(bitmap[y*step+x*4]==0xff)
            {
                bitmap[y*step+x*4]=0x0;
                bitmap[y*step+x*4+1]=0x0;
                bitmap[y*step+x*4+2]=0x0;
                bitmap[y*step+x*4+3]=0x0;
            }
        }
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
