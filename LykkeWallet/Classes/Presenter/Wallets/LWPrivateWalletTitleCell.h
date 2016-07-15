//
//  LWPrivateWalletTitleCell.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWPrivateWalletModel.h"

@interface LWPrivateWalletTitleCell : UITableViewCell


@property (strong, nonatomic) LWPrivateWalletModel *wallet;


+(CGFloat) height;

@end
