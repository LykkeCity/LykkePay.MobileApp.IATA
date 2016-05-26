//
//  LWWalletPagePresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWalletPagePresenter.h"
#import "LWBankCardsData.h"


@interface LWWalletPagePresenter () {
    
}

@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardExpirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardOwnerLabel;

@end


@implementation LWWalletPagePresenter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.cardNumberLabel.text = [NSString stringWithFormat:@"... %@", self.cardData.lastDigits];
    self.cardExpirationLabel.text = [NSString stringWithFormat:@"%@/%@", self.cardData.monthTo, self.cardData.yearTo];
    self.cardOwnerLabel.text = [self.cardData.name uppercaseString];
}

@end
