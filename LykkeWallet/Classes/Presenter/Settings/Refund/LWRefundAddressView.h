//
//  LWRefundAddressView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/06/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWRefundAddressView : UIView

@property (strong, nonatomic) NSString *address;

@property id delegate;

@property BOOL isOpened;

@end


@protocol LWRefundAddressViewDelegate

-(void) addressViewPressedApply:(LWRefundAddressView *) view;
-(void) addressViewScanQRCode:(LWRefundAddressView *) view;

@end