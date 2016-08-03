//
//  LWPKBackupPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPKBackupPresenter.h"
#import "LWValidator.h"
#import "LWResultPresenter.h"
#import "UIViewController+Loading.h"
#import "LWPrivateWalletsManager.h"

@interface LWPKBackupPresenter () <UITextFieldDelegate, LWResultPresenterDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *proceedButton;

@end

@implementation LWPKBackupPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.proceedButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"PROCEED" attributes:@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]}] forState:UIControlStateDisabled];

    [self.proceedButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"PROCEED" attributes:@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]}] forState:UIControlStateNormal];

    
    [LWValidator setButton:self.proceedButton enabled:NO];
    
    if(self.type==BackupViewTypePassword)
        self.textField.placeholder=@"Enter your passphrase";
    else
        self.textField.placeholder=@"Think of hint to a code phrase";
    self.textField.delegate=self;
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.type==BackupViewTypePassword)
        self.title=@"ENTER PASSPHRASE";
    else
        self.title=@"ENTER HINT";

}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *final=[textField.text stringByReplacingCharactersInRange:range withString:string];
    [LWValidator setButton:self.proceedButton enabled:final.length>0];

    return YES;
}

-(IBAction)proceedPressed:(id)sender
{
    if(self.type==BackupViewTypePassword)
    {
        LWPKBackupPresenter *hint=[[LWPKBackupPresenter alloc] init];
        hint.type=BackupViewTypeHint;
        
        hint.backupModel=self.backupModel;
        self.backupModel.passPhrase=self.textField.text;
        [self.navigationController pushViewController:hint animated:YES];
    }
    else
    {
        self.backupModel.hint=self.textField.text;
        [self.view endEditing:YES];
        [self setLoading:YES];
        
        [[LWPrivateWalletsManager shared] backupPrivateKeyWithModel:self.backupModel withCompletion:^(BOOL success){
            [self setLoading:NO];
            
            LWResultPresenter *presenter=[[LWResultPresenter alloc] init];
            presenter.delegate=self;
            presenter.image=[UIImage imageNamed:@"WithdrawSuccessFlag.png"];
            presenter.titleString=@"SUCCESSFUL!";
            presenter.textString=@"Backup is now being processed by\nour team. The result you will receive\nan email in your Inbox.";
            [self presentViewController:presenter animated:YES completion:nil];
            
             }];

    }
}

-(void) resultPresenterDismissed
{
    NSMutableArray *viewControllers=[NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [viewControllers removeLastObject];
    [viewControllers removeLastObject];
    [self.navigationController setViewControllers:viewControllers animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
