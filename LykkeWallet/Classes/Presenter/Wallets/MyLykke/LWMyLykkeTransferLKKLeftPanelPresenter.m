//
//  LWMyLykkeTransferLKKLeftPanelPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeTransferLKKLeftPanelPresenter.h"

@interface LWMyLykkeTransferLKKLeftPanelPresenter ()

@property (weak, nonatomic) IBOutlet UIButton *topTransferButton;

@end

@implementation LWMyLykkeTransferLKKLeftPanelPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    _topTransferButton.layer.cornerRadius=_topTransferButton.bounds.size.height/2;
    _topTransferButton.clipsToBounds=YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)buyTopButtonPressed:(id)sender
{
    [self.delegate leftPanelPressedBuy:self];
}
@end
