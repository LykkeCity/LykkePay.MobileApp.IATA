//
//  LWEmptyHistoryPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWEmptyHistoryPresenter.h"

#import "LWValidator.h"

@interface LWEmptyHistoryPresenter ()

@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation LWEmptyHistoryPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LWValidator setButtonWithClearBackground:self.button enabled:YES];
    
    NSDictionary *attributes=@{NSKernAttributeName:@(1), NSForegroundColorAttributeName: [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Semibold" size:15]};
    [self.button setAttributedTitle:[[NSAttributedString alloc] initWithString:@"MAKE FIRST TRANSACTION" attributes:attributes] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonMakeFirstTransactionPressed) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewDidLayoutSubviews
{
    self.button.layer.cornerRadius=self.button.bounds.size.height/2;
}

-(void)buttonMakeFirstTransactionPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowExchangeViewControllerNotification" object:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
