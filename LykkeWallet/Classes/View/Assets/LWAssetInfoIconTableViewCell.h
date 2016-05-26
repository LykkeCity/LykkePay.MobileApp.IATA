//
//  LWAssetInfoIconTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


@interface LWAssetInfoIconTableViewCell : TKTableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *popularityImageView;

@end
