//
//  LWSettingsTermsTableViewCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 10/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWSettingsTermsTableViewCell.h"
#import "Macro.h"



@implementation LWSettingsTermsTableViewCell

-(void) awakeFromNib
{
    self.termsLabel.text=Localize(@"settings.cell.terms.title");
}
@end
