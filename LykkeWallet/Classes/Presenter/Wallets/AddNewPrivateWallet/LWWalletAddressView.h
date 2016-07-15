//
//  LWWalletAddressView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWWalletAddressView : UIView

@property (strong, nonatomic) NSString *address;

-(id) initWithWidth:(CGFloat) width;

@end
