//
//  LWErrorView.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWErrorView.h"
#import "LWConstants.h"
#import "UIColor+Generic.h"


@interface LWErrorView () {
    
}

@property (weak, nonatomic) IBOutlet UIView   *topView;
@property (weak, nonatomic) IBOutlet UILabel  *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel  *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;


#pragma mark - Utils

- (void)updateView;

@end


@implementation LWErrorView


#pragma mark - General

+ (LWErrorView *)modalViewWithDescription:(NSString *)description {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"LWErrorView"
                                                  owner:self
                                                options:nil] objectAtIndex:0];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [view sizeToFit];
    
    LWErrorView *result = (LWErrorView *)view;
    result.descriptionLabel.text = description;
    [result updateView];
    return result;
}


#pragma mark - Utils

- (void)updateView {
    [UIView setAnimationsEnabled:NO];
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    self.titleLabel.textColor = [UIColor colorWithHexString:kErrorTextColor];
    
    self.topView.backgroundColor = [UIColor whiteColor];
    self.topView.opaque = NO;
}


#pragma mark - Actions

- (IBAction)closeClicked:(id)sender {
    [self removeFromSuperview];
}

@end
