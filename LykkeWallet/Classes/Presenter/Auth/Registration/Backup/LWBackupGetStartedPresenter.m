//
//  LWBackupGetStartedPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupGetStartedPresenter.h"
#import "LWValidator.h"
#import "LWBackupSingleWordPresenter.h"
#import "LWPrivateKeyManager.h"

@interface LWBackupGetStartedPresenter ()

@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;

@end

@implementation LWBackupGetStartedPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dict=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [self.getStartedButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"GET STARTED!" attributes:dict] forState:UIControlStateNormal];
    
    [LWValidator setButton:self.getStartedButton enabled:YES];

    
    
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:244.0/255 green:246.0/255 blue:247.0/255 alpha:1];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
    [self setTitle:@"BACK UP"];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.getStartedButton.layer.cornerRadius=self.getStartedButton.bounds.size.height/2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)getStartedPressed:(id)sender
{
    LWBackupSingleWordPresenter *presenter=[[LWBackupSingleWordPresenter alloc] init];
    presenter.wordsList=[LWPrivateKeyManager generateSeedWords];
    presenter.currentWordNum=0;
    [self.navigationController pushViewController:presenter animated:YES];
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
