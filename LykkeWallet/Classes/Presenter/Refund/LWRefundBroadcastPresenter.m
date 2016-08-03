//
//  LWRefundBroadcastPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRefundBroadcastPresenter.h"
#import "LWValidator.h"
#import "UIViewController+Navigation.h"

#define BAR_GRAY_COLOR [UIColor colorWithRed:245.0/255 green:246.0/255 blue:248.0/255 alpha:1]
#define TextColor [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]


@interface LWRefundBroadcastPresenter ()
{
    
    
    
}

@property (weak, nonatomic) IBOutlet UIButton *copypasteButton;
@property (weak, nonatomic) IBOutlet UIButton *broadcastButton;
@property (weak, nonatomic) IBOutlet UITextView *transactionTextView;


@end

@implementation LWRefundBroadcastPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTitle:@"REFUND"];
    [self.navigationController setNavigationBarHidden:NO];
    [self setCrossCloseButton];
    
    self.navigationController.navigationBar.barTintColor = BAR_GRAY_COLOR;
    
    self.transactionTextView.text=self.transactionText;
    
    NSDictionary *attrDisabled = @{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:TextColor};
    NSDictionary *attrEnabled = @{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [self.broadcastButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"BROADCAST" attributes:attrEnabled] forState:UIControlStateNormal];
    [self.copypasteButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"COPY" attributes:attrDisabled] forState:UIControlStateNormal];
    [LWValidator setButton:self.broadcastButton enabled:YES];
    [LWValidator setButtonWithClearBackground:self.copypasteButton enabled:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
