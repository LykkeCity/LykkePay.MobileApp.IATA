//
//  LWPrivateWalletAssetCell.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWPrivateWalletAssetModel.h"

@interface LWPrivateWalletAssetCell : UITableViewCell

@property (strong, nonatomic) LWPrivateWalletAssetModel *asset;

+(CGFloat) height;

@end
