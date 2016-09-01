//
//  LWWithdrawCurrencyPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWithdrawCurrencyPresenter.h"
#import "LWAuthManager.h"
#import "LWConstants.h"
#import "LWCache.h"
#import "TKButton.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "UIView+Toast.h"
#import "UIImage+Resize.h"
#import "LWAuthPINEnterPresenter.h"
#import "LWResultPresenter.h"
#import "LWTradingWalletPresenter.h"
#import "LWPacketCurrencyWithdraw.h"
#import "LWWithdrawCurrencyCell.h"
#import "LWIPadModalNavigationControllerViewController.h"

#define BAR_GRAY_COLOR [UIColor colorWithRed:245.0/255 green:246.0/255 blue:248.0/255 alpha:1]



@interface LWWithdrawCurrencyPresenter() <UITextFieldDelegate, LWResultPresenterDelegate, LWWithdrawCurrencyCellDelegate>
{
    UILabel *infoLabel;
    NSArray *lineTitles;
    NSArray *lineValues;
    
    CGRect originalScrollViewFrame;
    
    UIButton *termsOfUseButton;
    UIButton *prospectusButton;
    
    UIView *buttonsContainer;
    
    NSString *currencySymbol;
    
    UILabel *currencySymbolLabel;
    
    NSMutableArray *textCells;
    
}

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *withdrawButton;
@property (weak, nonatomic) IBOutlet UIView *container;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *withdrawButtonTopConstraint;

@end

@implementation LWWithdrawCurrencyPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setBackButton];
    self.withdrawButton.hidden=YES;
    
    UIView *topBackView=[[UIView alloc] initWithFrame:CGRectMake(0, -300, 1024, 300)];
    topBackView.backgroundColor=BAR_GRAY_COLOR;
    [self.scrollView addSubview:topBackView];
    self.navigationController.navigationBar.barTintColor = BAR_GRAY_COLOR;
    self.navigationController.navigationBar.translucent = NO;
    
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, _infoView.bounds.size.height-1, 704, 1)];
    lineView.backgroundColor=[UIColor colorWithRed:210.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [_infoView addSubview:lineView];

    
    CGRect rrr=self.view.frame;
    self.infoView.backgroundColor=BAR_GRAY_COLOR;
    
    infoLabel=[[UILabel alloc] init];
    infoLabel.numberOfLines=0;
    infoLabel.textAlignment=NSTextAlignmentCenter;
    infoLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:16];
    infoLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    
    lineTitles=@[@"BIC (SWIFT)",
                 @"Account Number",
                 @"Account Name",
//                 @"Postcheck"
                 ];
    
//    lineValues=@[@"POFICHBEXXX",
//                 @"CH06 0900 0000 8016 5421 0",
//                 @"Richard Olsen",
//                 @"80-165 421-0"
//                 
//                 ];
    
    lineValues=@[@"",
                 @"",
                 @"",
//                 @""
                 
                 ];

    
    [self.infoView addSubview:infoLabel];
    
    
    self.withdrawButton.layer.cornerRadius=self.withdrawButton.bounds.size.height/2;
    self.withdrawButton.clipsToBounds=YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    buttonsContainer=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 20)];
    termsOfUseButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [termsOfUseButton setTitle:@"Terms of Use" forState:UIControlStateNormal];
    termsOfUseButton.titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    [termsOfUseButton setTitleColor:[UIColor colorWithRed:171.0/255 green:0.0/255 blue:255.0/255 alpha:1] forState:UIControlStateNormal];
    [termsOfUseButton addTarget:self action:@selector(termsOfUsePressed) forControlEvents:UIControlEventTouchUpInside];
    
    [termsOfUseButton sizeToFit];
    
    prospectusButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [prospectusButton setTitle:@"Information Brochure" forState:UIControlStateNormal];
    prospectusButton.titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    [prospectusButton setTitleColor:[UIColor colorWithRed:171.0/255 green:0.0/255 blue:255.0/255 alpha:1] forState:UIControlStateNormal];
    [prospectusButton addTarget:self action:@selector(informationBrochurePressed) forControlEvents:UIControlEventTouchUpInside];
    
    [prospectusButton sizeToFit];
    
    [buttonsContainer addSubview:termsOfUseButton];
    [buttonsContainer addSubview:prospectusButton];
    
    CGFloat s1=termsOfUseButton.bounds.size.width;
    CGFloat s2=prospectusButton.bounds.size.width;
    termsOfUseButton.center=CGPointMake(buttonsContainer.bounds.size.width/2-(s1+s2+40)/2+s1/2, buttonsContainer.bounds.size.height/2);
    prospectusButton.center=CGPointMake(buttonsContainer.bounds.size.width/2+(s1+s2+40)/2-s2/2, buttonsContainer.bounds.size.height/2);
    
    [self.infoView addSubview:buttonsContainer];
    
    //    CGRect rect=self.view.bounds;
    
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id vvv=self.navigationController;
    
    infoLabel.text=[NSString stringWithFormat:@"For the withdrawal of funds, the following\n account details will be used"];
    [infoLabel sizeToFit];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = Localize(@"wallets.currency.withdraw");
    self.navigationController.navigationBar.barTintColor = BAR_GRAY_COLOR;

    if(!textCells)
    {
        
        textCells=[[NSMutableArray alloc] init];
        
        currencySymbol=[[LWCache instance] currencySymbolForAssetId:self.assetID];
        
        originalScrollViewFrame=self.scrollView.frame;
        
        CGFloat offset=self.infoView.bounds.size.height;
        for(int i=0;i<lineTitles.count;i++)
        {
            BOOL needLine=NO;
//            if(i<lineTitles.count-1)
                needLine=YES;
            
            LWWithdrawCurrencyCell *view=[[LWWithdrawCurrencyCell alloc] initWithWidth:self.view.bounds.size.width title:lineTitles[i] placeholder:lineValues[i] addBottomLine:needLine];
            view.delegate=self;
            view.center=CGPointMake(_scrollView.bounds.size.width/2, offset+view.bounds.size.height/2);
            [_scrollView addSubview:view];
            
            offset+=view.bounds.size.height;
            
            [textCells addObject:view];
            
        }
        
        
        offset+=30;
        
//        self.withdrawButton.frame=CGRectMake(30, offset, _scrollView.bounds.size.width-60, 45);
        
        [self.withdrawButtonTopConstraint setConstant:offset];
        self.withdrawButton.hidden=NO;
        offset+=(_withdrawButton.bounds.size.height+20);
        
        _scrollView.contentSize=CGSizeMake(_scrollView.bounds.size.width, offset);
        
        
 
    }
    
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

}

-(void) withdrawCurrencyCell:(LWWithdrawCurrencyCell *)cell changedHeightFrom:(CGFloat)prevHeight to:(CGFloat)curHeight
{
    NSInteger index=[textCells indexOfObject:cell];
    [UIView animateWithDuration:0.3 animations:^{
    for(NSInteger i=index+1;i<textCells.count;i++)
    {
        LWWithdrawCurrencyCell *c=textCells[i];
        c.center=CGPointMake(c.center.x, c.center.y+(curHeight-prevHeight));
    }
        [self.withdrawButtonTopConstraint setConstant:self.withdrawButtonTopConstraint.constant+(curHeight-prevHeight)];
//        self.withdrawButton.center=CGPointMake(self.withdrawButton.center.x, self.withdrawButton.center.y+(curHeight-prevHeight));
        self.scrollView.contentSize=CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height+(curHeight-prevHeight));
        }];
}



-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
//    infoLabel.center=CGPointMake(self.infoView.bounds.size.width/2, self.infoView.bounds.size.height/2-20);
//    buttonsContainer.center=CGPointMake(self.infoView.bounds.size.width/2, self.infoView.bounds.size.height/2+infoLabel.bounds.size.height/2+10);
    [self.scrollView layoutIfNeeded];
    infoLabel.center=CGPointMake(self.scrollView.bounds.size.width/2, self.infoView.bounds.size.height/2-20);
    buttonsContainer.center=CGPointMake(self.scrollView.bounds.size.width/2, self.infoView.bounds.size.height/2+infoLabel.bounds.size.height/2+10);

}


-(void) keyboardWillShowNotification:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.bottom = keyboardRect.size.height;
    self.scrollView.contentInset = contentInset;
    
    self.scrollView.contentOffset=CGPointMake(0, _scrollView.contentSize.height-(_scrollView.bounds.size.height-contentInset.bottom));
    
}

-(void) keyboardWillHideNotification:(NSNotification *)notification
{
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.bottom = 0;
    self.scrollView.contentInset = contentInset;
}

-(IBAction)withdrawButtonPressed:(id)sender
{
    [self.view endEditing:YES];
    
    BOOL const shouldSignOrder = [LWCache instance].shouldSignOrder;

    void (^requestBlock)(void)=^{ LWPacketCurrencyWithdraw *packet=[LWPacketCurrencyWithdraw new];
        packet.bic=[textCells[0] text];
        packet.accountNumber=[textCells[1] text];
        packet.accountName=[textCells[2] text];
//        packet.postCheck=[textCells[3] text];
        packet.amount=self.amount;
        packet.assetId=self.assetID;
        [[LWAuthManager instance] requestCurrencyWithdraw:packet];
        [self setLoading:YES];};
    
    if(shouldSignOrder)
    {
        LWAuthPINEnterPresenter *auth=[LWAuthPINEnterPresenter new];
        
        auth.isSuccess=^(BOOL success){
            if(success)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), requestBlock);
            }
        };
        
        [self.navigationController pushViewController:auth animated:YES];
    }
    else
        requestBlock();
}

-(void) resultPresenterWillDismiss
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        NSArray *array=self.navigationController.viewControllers;
        for(UIViewController *v in array)
        {
            if([v isKindOfClass:[LWTradingWalletPresenter class]])
            {
                [self.navigationController popToViewController:v animated:NO];
                break;
            }
        }
    }
    else
    {
        self.navigationController.view.hidden=YES;
//        [self.navigationController setViewControllers:@[]];
        [(LWIPadModalNavigationControllerViewController *)self.navigationController dismissAnimated:NO];
    }
}

-(void) termsOfUsePressed
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://wiki.lykkex.com/terms_of_use"]];
}


-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void) authManager:(LWAuthManager *) manager didGetCurrencyDeposit:(LWPacketCurrencyDeposit *) pack
{
    [self setLoading:NO];
    
    [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.sendemail")];
}

-(void) authManager:(LWAuthManager *)manager didSendWithdraw:(LWPacketCurrencyWithdraw *)withdraw
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setLoading:NO];
        
        LWResultPresenter *presenter=[[LWResultPresenter alloc] init];
        
        presenter.delegate=self;
        presenter.image=[UIImage imageNamed:@"WithdrawSuccessFlag.png"];
        presenter.titleString=Localize(@"wallets.currency.withdraw.success.title");
        presenter.textString=Localize(@"wallets.currency.withdraw.success.text");
        [self presentViewController:presenter animated:NO completion:nil];
        
    });
 
}

-(void) informationBrochurePressed
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.lykkex.com/Lykke_Corp_Placement_Memorandum.pdf"]];
}




@end
