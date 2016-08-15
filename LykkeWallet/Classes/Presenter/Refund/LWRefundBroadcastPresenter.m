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
#import "LWPrivateKeyManager.h"

#define BAR_GRAY_COLOR [UIColor colorWithRed:245.0/255 green:246.0/255 blue:248.0/255 alpha:1]
#define TextColor [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]


@interface LWRefundBroadcastPresenter ()
{
    
    NSString *lockTimeString;
    
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

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"REFUND";
    
    NSTimeInterval now=[[NSDate date] timeIntervalSince1970];
    self.lockTime+=3600;
    if(now<self.lockTime)
    {
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:self.lockTime];
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        lockTimeString=[formatter stringFromDate:date];
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"WARNING" message:[NSString stringWithFormat:@"Please remember that you will not be able to broadcast this refund transaction to blockchain before %@", lockTimeString] delegate:nil cancelButtonTitle:@"I GOT IT" otherButtonTitles: nil];
        [alert show];

    }
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

}

-(IBAction)copyPressed:(id)sender
{
    UIPasteboard *board=[UIPasteboard generalPasteboard];
    board.string=self.transactionText;
    [self showCopied];
}

-(IBAction)broadcastPressed:(id)sender
{
    NSTimeInterval now=[[NSDate date] timeIntervalSince1970];
    if(now<self.lockTime)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"SORRY" message:[NSString stringWithFormat:@"You can not broadcast this refund transaction to blockchain before %@", lockTimeString] delegate:nil cancelButtonTitle:@"I GOT IT" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    UIPasteboard *board=[UIPasteboard generalPasteboard];
    board.string=self.transactionText;
    if([LWPrivateKeyManager shared].isDevServer)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://test-insight.bitpay.com/tx/send"]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://blockchain.info/pushtx"]];
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
