//
//  LWWithdrawConfirmationView.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LWWithdrawConfirmationViewDelegate <NSObject>

@required
- (void)cancelClicked;
- (void)requestOperationWithHud:(BOOL)isHudActivated;
- (void)checkPin:(NSString *)pin;
- (void)noAttemptsForPin;

@end


@interface LWWithdrawConfirmationView : UIView {
    
}


#pragma mark - Properties

@property (copy, nonatomic) NSString *amountString;
@property (copy, nonatomic) NSString *bitcoinString;


#pragma mark - General

+ (LWWithdrawConfirmationView *)modalViewWithDelegate:(id<LWWithdrawConfirmationViewDelegate>)delegate;


#pragma mark - Utils

- (void)requestOperation;
- (void)pinRejected;
- (void)setLoading:(BOOL)loading withReason:(NSString *)reason;

@end
