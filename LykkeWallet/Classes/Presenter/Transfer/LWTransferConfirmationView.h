//
//  LWTransferConfirmationView.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LWTransferConfirmationViewDelegate <NSObject>

@required
- (void)cancelClicked;
- (void)requestOperationWithHud:(BOOL)isHudActivated;
- (void)checkPin:(NSString *)pin;
- (void)noAttemptsForPin;

@end


@interface LWTransferConfirmationView : UIView {
    
}

#pragma mark - Properties

@property (copy, nonatomic) NSString *recepientId;
@property (copy, nonatomic) NSString *recepientName;
@property (copy, nonatomic) NSString *recepientAmount;
@property (copy, nonatomic) NSString *selectedAssetId;
@property (copy, nonatomic) NSString *volumeString;


#pragma mark - General

+ (LWTransferConfirmationView *)modalViewWithDelegate:(id<LWTransferConfirmationViewDelegate>)delegate;


#pragma mark - Utils

- (void)requestOperation;
- (void)pinRejected;
- (void)setLoading:(BOOL)loading withReason:(NSString *)reason;

@end
