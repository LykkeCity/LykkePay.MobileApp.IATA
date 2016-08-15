//
//  LWLeftDetailTableViewCell.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWLeftDetailTableViewCell.h"

@interface LWLeftDetailTableViewCell()
{
    BOOL shouldShowCopyButton;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonTrailingConstraint;

@property (weak, nonatomic) IBOutlet UIButton *buttonCopy;

@end


@implementation LWLeftDetailTableViewCell

-(id) init
{
    self=[super init];
    
    return self;
}

-(void) setShowCopyButton:(BOOL)showCopyButton
{
    shouldShowCopyButton=showCopyButton;
    if(self.showCopyButton)
    {
        
        [self.buttonWidthConstraint setConstant:30];
        [self.buttonTrailingConstraint setConstant:0];
//        self.buttonCopy.hidden=NO;
    }
    else
    {
        [self.buttonWidthConstraint setConstant:0];
        [self.buttonTrailingConstraint setConstant:0];
//        self.buttonCopy.hidden=YES;
        
    }

}

-(BOOL) showCopyButton
{
    return shouldShowCopyButton;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    shouldShowCopyButton=NO;
    self.buttonCopy.clipsToBounds=YES;
    [self.buttonWidthConstraint setConstant:0];
    [self.buttonTrailingConstraint setConstant:0];
    
    [self.buttonCopy addTarget:self action:@selector(copyPressed) forControlEvents:UIControlEventTouchUpInside];

}


-(void) copyPressed
{
    if([self.delegate respondsToSelector:@selector(leftDetailCellCopyPressed:)])
        [self.delegate leftDetailCellCopyPressed:self];
}




@end
