//
//  TKButton.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 25.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKButton : UIButton {
    
}


#pragma mark - Properties

@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;


#pragma mark - Customization

- (void)setGrayPalette;
- (void)setColoredPalette;
- (void)setGreenPalette;
- (void)setDisabledPalette;

@end
