//
//  LWAssetBlockchainIconTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kAssetBlockchainIconTableViewCell           @"LWAssetBlockchainIconTableViewCell"
#define kAssetBlockchainIconTableViewCellIdentifier @"LWAssetBlockchainIconTableViewCellIdentifier"
#define kAssetBlockchainIconTableViewCellHeight 345.0


@interface LWAssetBlockchainIconTableViewCell : TKTableViewCell {
    
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *title;

@end
