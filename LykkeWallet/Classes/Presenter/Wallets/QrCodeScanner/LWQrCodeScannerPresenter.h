//
//  LWQrCodeScannerPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 30.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthPresenter.h"
#import "QRCodeReader.h"


@class LWQrCodeScannerPresenter;


@protocol AMScanViewControllerDelegate <NSObject>

@optional
- (void)scanViewController:(LWQrCodeScannerPresenter *)controller didTapToFocusOnPoint:(CGPoint)point;
- (void)scanViewController:(LWQrCodeScannerPresenter *)controller didSuccessfullyScan:(NSString *)scannedValue;

@end


@interface LWQrCodeScannerPresenter : LWAuthPresenter {
    
}

@property (weak, nonatomic) id<AMScanViewControllerDelegate> delegate;

@end
