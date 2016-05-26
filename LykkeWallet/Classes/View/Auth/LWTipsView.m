//
//  LWTipsView.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWTipsView.h"
#import "Macro.h"


@interface LWTipsView () {
    
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


#pragma mark - Actions

- (IBAction)buttonClick:(id)sender;

@end


@implementation LWTipsView


#pragma mark - TKView

- (void)awakeFromNib {
    self.titleLabel.text = Localize(@"utils.tip");
}


#pragma mark - Actions

- (IBAction)buttonClick:(id)sender {
    [self.delegate tipsViewDidPress:self];
}

@end
