//
//  LWSettingsAssetTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kSettingsAssetTableViewCell           @"LWSettingsAssetTableViewCell"
#define kSettingsAssetTableViewCellIdentifier @"LWSettingsAssetTableViewCellIdentifier"


@interface LWSettingsAssetTableViewCell : TKTableViewCell {
    
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *assetLabel;

@end
