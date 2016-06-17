//
//  LWRefundInformationPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRefundInformationPresenter.h"
#import "UIViewController+Navigation.h"


@interface LWRefundInformationPresenter ()

@end

@implementation LWRefundInformationPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setBackButton];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"INFORMATION";
}

-(IBAction)userAgreementPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://wiki.lykkex.com/faq/refundtransaction"]];
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
