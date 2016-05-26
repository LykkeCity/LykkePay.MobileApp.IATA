//
//  LWChooseAssetTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


@interface LWChooseAssetTableViewCell : TKTableViewCell {
    
}

@property (copy, nonatomic) NSString         *assetId;
@property (weak, nonatomic) IBOutlet UILabel *assetName;

@end
