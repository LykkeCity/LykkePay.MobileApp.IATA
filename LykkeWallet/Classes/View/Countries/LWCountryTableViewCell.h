//
//  LWCountryTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kCountryTableViewCell           @"LWCountryTableViewCell"
#define kCountryTableViewCellIdentifier @"LWCountryTableViewCellIdentifier"


@class LWCountryModel;


@interface LWCountryTableViewCell : TKTableViewCell {
    
}

@property (nonatomic, copy) LWCountryModel *model;

@property (nonatomic, weak) IBOutlet UILabel *countryLabel;
@property (nonatomic, weak) IBOutlet UILabel *codeLabel;

@end
