//
//  LWExchangeConfirmationView.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWPacketBuySellAsset.h"



@class LWAssetPairModel;
@class LWAssetPairRateModel;


@protocol LWExchangeConfirmationViewDelegate <NSObject>

@optional

-(void) exchangeConfirmationViewPressedFingerPrint;

@required
- (void)cancelClicked;
- (void)requestOperationWithHud:(BOOL)isHudActivated;
- (void)checkPin:(NSString *)pin;
- (void)noAttemptsForPin;

@end


@interface LWExchangeConfirmationView : UIView {
    
}


#pragma mark - Properties

@property (strong, nonatomic) LWAssetPairModel     *assetPair;

@property (copy, nonatomic) NSString *rateString;
@property (copy, nonatomic) NSString *volumeString;
@property (copy, nonatomic) NSString *totalString;
@property LWAssetDealType assetDealType;

@property (strong, nonatomic) UIView *iPadNavShadowView;

#pragma mark - General

+ (LWExchangeConfirmationView *)modalViewWithDelegate:(id<LWExchangeConfirmationViewDelegate>)delegate;


#pragma mark - Utils


-(void) show;
-(void) hide;

- (void)requestOperation;
- (void)pinRejected;
- (void)setLoading:(BOOL)loading withReason:(NSString *)reason;

@end
