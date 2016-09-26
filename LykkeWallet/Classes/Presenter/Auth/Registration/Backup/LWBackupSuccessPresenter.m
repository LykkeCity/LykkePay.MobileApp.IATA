//
//  LWBackupSuccessPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupSuccessPresenter.h"
#import "LWValidator.h"
#import "LWAuthNavigationController.h"
#import "LWKeychainManager.h"
#import "LWWebViewDocumentPresenter.h"
#import "LWCache.h"

@interface LWBackupSuccessPresenter ()

@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *okButtonWidthConstraint;



@end

@implementation LWBackupSuccessPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *attributes=@{NSKernAttributeName:@(1.5), NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17]};
    self.informationLabel.attributedText=[[NSAttributedString alloc] initWithString:@"INFORMATION" attributes:attributes];
    self.titleLabel.attributedText=[[NSAttributedString alloc] initWithString:@"Your backup is complete" attributes:attributes];
    
    
    _okButton.enabled=YES;
    [_okButton addTarget:self action:@selector(okButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    if([UIScreen mainScreen].bounds.size.width==320)
        _okButtonWidthConstraint.constant=280;

}

-(void) okButtonPressed
{
    if([[self.navigationController.viewControllers firstObject] isKindOfClass:[UITabBarController class]])
        [self.navigationController popToRootViewControllerAnimated:YES];
    else
        [((LWAuthNavigationController *)self.navigationController) setRootMainTabScreen];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

    [self.navigationController setNavigationBarHidden:YES animated:NO];

}

-(IBAction)userAgreementPressed:(id)sender
{
    LWWebViewDocumentPresenter *presenter=[[LWWebViewDocumentPresenter alloc] init];
    presenter.urlString=[LWCache instance].userAgreementUrl;
    presenter.documentTitle=@"USER AGREEMENT";
    [self.navigationController pushViewController:presenter animated:YES];

}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.okButton.layer.cornerRadius=self.okButton.bounds.size.height/2;
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
