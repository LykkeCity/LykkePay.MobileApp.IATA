//
//  LWPKTransferConfirmationView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>


@class LWPKTransferModel;

@interface LWPKTransferConfirmationView : UIView

+(void) showTransfer:(LWPKTransferModel *) transfer withCompletion:(void(^)(BOOL result)) completion;

@end
