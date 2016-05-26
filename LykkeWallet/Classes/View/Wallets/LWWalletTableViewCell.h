//
//  LWWalletTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kWalletTableViewCell           @"LWWalletTableViewCell"
#define kWalletTableViewCellIdentifier @"LWWalletTableViewCellIdentifier"


@class LWWalletTableViewCell;


@protocol LWWalletTableViewCellDelegate<NSObject>

@required
- (void)addWalletClicked:(LWWalletTableViewCell *)cell;

@end


@interface LWWalletTableViewCell : TKTableViewCell {
    
}


#pragma mark - Properties

@property (weak, nonatomic) id<LWWalletTableViewCellDelegate> delegate;

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel     *walletLabel;
@property (weak, nonatomic) IBOutlet UIImageView *walletImageView;
@property (weak, nonatomic) IBOutlet UIButton    *addWalletButton;

@end
