//
//  LWMyLykkeIpadController.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeIpadController.h"
#import "LWMyLykkeBuyPresenter.h"
#import "LWMyLykkeCreditCardDepositPresenter.h"
#import "LWMyLykkeBuyAssetPresenter.h"
#import "LWMyLykkeIPadNavigationController.h"
#import "UIViewController+Loading.h"
#import "LWMyLykkeTransferLKKLeftPanelPresenter.h"
#import "LWMyLykkeTransferLKKPresenter.h"

@interface LWMyLykkeIpadController () <LWMyLykkeBuyPresenterDelegate, LWMyLykkeTransferLKKLeftPanelPresenterDelegate>
{
    LWMyLykkeBuyPresenter *buyPresenter;
    LWMyLykkeIPadNavigationController *navController;
    
    LWMyLykkeTransferLKKLeftPanelPresenter *transferLeftPanel;
    LWMyLykkeTransferLKKPresenter *transferLKKPresenter;
    
    NSString *prevDetailsLabelValue;
    
    BOOL prevBackButtonState;
}

@property (weak, nonatomic) IBOutlet UIView *buyContainer;
@property (weak, nonatomic) IBOutlet UIView *detailsContainer;

@property (weak, nonatomic) IBOutlet UILabel *buyLykkeTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailsViewControllerLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailsBackButton;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation LWMyLykkeIpadController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self adjustThinLines];
    buyPresenter=[LWMyLykkeBuyPresenter new];
    buyPresenter.delegate=self;
    [_buyContainer insertSubview:buyPresenter.view atIndex:0];
    [self addChildViewController:buyPresenter];
    buyPresenter.view.frame=_buyContainer.bounds;
    
    
    navController=[[LWMyLykkeIPadNavigationController alloc] init];
    navController.titleLabel=_detailsViewControllerLabel;
    navController.backButton=self.detailsBackButton;
    [navController setNavigationBarHidden:YES];

    NSDictionary *dict=@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]};
    NSAttributedString *string=[[NSAttributedString alloc] initWithString:@"DEPOSIT LYKKE" attributes:dict];
    self.buyLykkeTitleLabel.attributedText=string;
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) buyPresenterChosenAsset:(NSString *)assetId
{
    if(navController.view.superview==nil)
    {
        [_detailsContainer addSubview:navController.view];
        navController.view.frame=_detailsContainer.bounds;
        [self addChildViewController:navController];
    }
    
    _detailsBackButton.hidden=YES;
        
        LWMyLykkeBuyAssetPresenter *presenter=[[LWMyLykkeBuyAssetPresenter alloc] init];
        presenter.assetId=assetId;
//        [self.navigationController pushViewController:presenter animated:YES];

//        LWMyLykkeCreditCardDepositPresenter *presenter=[LWMyLykkeCreditCardDepositPresenter new];
        [navController setViewControllers:@[presenter]];

    
}

-(void) buyPresenterSelectedTransfer
{
    transferLeftPanel=[LWMyLykkeTransferLKKLeftPanelPresenter new];
    [_buyContainer insertSubview:transferLeftPanel.view aboveSubview:buyPresenter.view];
    [self addChildViewController:buyPresenter];
    transferLeftPanel.view.frame=_buyContainer.bounds;
    transferLeftPanel.delegate=self;

    transferLKKPresenter=[LWMyLykkeTransferLKKPresenter new];
    transferLKKPresenter.view.frame=_detailsContainer.bounds;
    [_detailsContainer addSubview:transferLKKPresenter.view];
    [self addChildViewController:transferLKKPresenter];
    
    prevDetailsLabelValue=_detailsViewControllerLabel.attributedText.string;
    
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Semibold" size:17];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSForegroundColorAttributeName,
                                font, NSFontAttributeName,
                                @(1.5f), NSKernAttributeName,
                                nil];
    
    _detailsViewControllerLabel.attributedText=[[NSAttributedString alloc] initWithString:@"TRANSFER LKK" attributes:attributes];

    prevBackButtonState=_detailsBackButton.hidden;
    _detailsBackButton.hidden=YES;
    
}

-(void) leftPanelPressedBuy:(LWMyLykkeTransferLKKLeftPanelPresenter *)panel
{
    [panel.view removeFromSuperview];
    [panel removeFromParentViewController];
    transferLeftPanel.delegate=nil;
    transferLeftPanel=nil;
    [transferLKKPresenter removeFromParentViewController];
    [transferLKKPresenter.view removeFromSuperview];
    transferLKKPresenter=nil;
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Semibold" size:17];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSForegroundColorAttributeName,
                                font, NSFontAttributeName,
                                @(1.5f), NSKernAttributeName,
                                nil];
    
    _detailsViewControllerLabel.attributedText=[[NSAttributedString alloc] initWithString:prevDetailsLabelValue attributes:attributes];
    _detailsBackButton.hidden=prevBackButtonState;
}

-(void) backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
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
