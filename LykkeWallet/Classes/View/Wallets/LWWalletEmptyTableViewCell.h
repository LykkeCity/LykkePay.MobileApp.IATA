//
//  LWWalletEmptyTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 28.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kWalletEmptyTableViewCell           @"LWWalletEmptyTableViewCell"
#define kWalletEmptyTableViewCellIdentifier @"LWWalletEmptyTableViewCellIdentifier"


@interface LWWalletEmptyTableViewCell : TKTableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
