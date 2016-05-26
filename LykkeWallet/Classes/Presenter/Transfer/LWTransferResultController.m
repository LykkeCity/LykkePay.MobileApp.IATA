//
//  LWTransferResultController.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransferResultController.h"


@interface LWTransferResultController ()

@end


@implementation LWTransferResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Successfull";
}

- (IBAction)closeClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
