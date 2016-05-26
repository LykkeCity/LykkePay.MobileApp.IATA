//
//  LWAssetBlockchainTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kAssetBlockchainTableViewCell           @"LWAssetBlockchainTableViewCell"
#define kAssetBlockchainTableViewCellIdentifier @"LWAssetBlockchainTableViewCellIdentifier"


@interface LWAssetBlockchainTableViewCell : TKTableViewCell {
    
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
