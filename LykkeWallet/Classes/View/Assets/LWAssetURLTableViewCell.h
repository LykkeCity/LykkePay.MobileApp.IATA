//
//  LWAssetURLTableViewCell.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"

@interface LWAssetURLTableViewCell : TKTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *urlButton;

@end
