//
//  LWCurrencyDepositPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCurrencyDepositPresenter.h"
#import "LWAuthManager.h"
#import "LWConstants.h"
#import "LWCache.h"
#import "TKButton.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "UIView+Toast.h"
#import "UIImage+Resize.h"
#import "LWKeychainManager.h"
#import "LWMathKeyboardView.h"
#import "LWUtils.h"
#import "LWCurrencyDepositElementView.h"
#import "LWCreditCardDepositPresenter.h"
#import "LWSwiftCredentialsModel.h"



#define BAR_GRAY_COLOR [UIColor colorWithRed:245.0/255 green:246.0/255 blue:248.0/255 alpha:1]

@interface LWCurrencyDepositPresenter () <UITextFieldDelegate, LWCurrencyDepositElementViewDelegate>
{
    UILabel *infoLabel;
    NSArray *lineTitles;
    NSArray *lineValues;
    UITextField *amountTextField;
    
    UIButton *termsOfUseButton;
    UIButton *prospectusButton;
    
    UIView *buttonsContainer;
    
    NSString *currencySymbol;
    
    UILabel *currencySymbolLabel;
    UIButton *swiftButton;
    UIButton *creditCardButton;
    
    NSMutableArray *elementViews;
    UIView *amountView;
}

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIView *container;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewHeight;

@end

@implementation LWCurrencyDepositPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBackButton];
    self.emailButton.hidden=YES;

    UIView *topBackView=[[UIView alloc] initWithFrame:CGRectMake(0, -300, 1024, 300)];
    topBackView.backgroundColor=BAR_GRAY_COLOR;
    [self.scrollView addSubview:topBackView];
    self.navigationController.navigationBar.barTintColor = BAR_GRAY_COLOR;
    self.navigationController.navigationBar.translucent = NO;


    self.infoView.backgroundColor=BAR_GRAY_COLOR;
    
    infoLabel=[[UILabel alloc] init];
    infoLabel.numberOfLines=0;
    infoLabel.textAlignment=NSTextAlignmentCenter;
    infoLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:16];
    infoLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    
    
    LWSwiftCredentialsModel *swiftCreds=[LWCache instance].swiftCredentialsDict[self.assetID];
    
    
//    NSDictionary *accounts=@{
//                             @"CHF":@"LI71 0880 1200 9711 0000 1",
//                             @"EUR":@"LI08 0880 1200 9711 0181 4",
//                             @"USD":@"LI60 0880 1200 9711 0233 3",
//                             @"GBP":@"LI06 0880 1200 9711 0340 2"
//                             };
    
    lineTitles=@[@"BIC (SWIFT)",
                 @"Account number",
                 @"Account name",
                 @"Purpose of payment"
                 
                  ];
    
//    NSString *acc=accounts[self.assetID];
//    if(!acc)
//        acc=@"";
    
    NSString *purposeTemp=[swiftCreds.purposeOfPayment stringByReplacingOccurrencesOfString:@"{0}" withString:@"%@"];
    purposeTemp=[purposeTemp stringByReplacingOccurrencesOfString:@"{1}" withString:@"%@"];
    NSString *email=[[LWKeychainManager instance].login stringByReplacingOccurrencesOfString:@"@" withString:@"."];
    lineValues=@[swiftCreds.bic,
                 swiftCreds.accountNumber,
                 swiftCreds.accountName,
                 [NSString stringWithFormat:purposeTemp,self.assetName, email]
                 ];
    
    [self.infoView addSubview:infoLabel];
    
    
    self.emailButton.layer.cornerRadius=self.emailButton.bounds.size.height/2;
    self.emailButton.clipsToBounds=YES;
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
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
    
    if([LWCache isBankCardDepositEnabledForAssetId:self.assetID])
    {
        self.infoViewHeight.constant+=50;
        
        
        swiftButton=[UIButton buttonWithType:UIButtonTypeCustom];
        swiftButton.frame=CGRectMake(0, 0, 134, 30);
        [swiftButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"SWIFT" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:13] , NSForegroundColorAttributeName:[UIColor whiteColor], NSKernAttributeName:@(1.1)}] forState:UIControlStateNormal];
        swiftButton.backgroundColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
        swiftButton.clipsToBounds=YES;
        swiftButton.layer.cornerRadius=15;
        [_infoView addSubview:swiftButton];
        
        creditCardButton=[UIButton buttonWithType:UIButtonTypeCustom];
        creditCardButton.frame=CGRectMake(0, 0, 134, 30);
        [creditCardButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"CREDIT CARD" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:13] , NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSKernAttributeName:@(1.1)}] forState:UIControlStateNormal];
        [creditCardButton addTarget:self action:@selector(creditCardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.infoView addSubview:creditCardButton];
        
    }
    
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, self.infoViewHeight.constant-1, 1024, 1)];
    lineView.backgroundColor=[UIColor colorWithRed:210.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [_infoView addSubview:lineView];

    
    currencySymbol=[[LWCache instance] currencySymbolForAssetId:self.assetID];
    
    elementViews=[[NSMutableArray alloc] init];
    
    for(int i=0;i<lineTitles.count;i++)
    {
        LWCurrencyDepositElementView *view=[[LWCurrencyDepositElementView alloc] initWithTitle:lineTitles[i] text:lineValues[i]];
        view.delegate=self;
        [elementViews addObject:view];
        [_scrollView addSubview:view];
        
        //        offset+=view.bounds.size.height;
        //        if(i<lineTitles.count-1)
        //        {
        //            UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(30, offset-1, _scrollView.bounds.size.width-60, 1)];
        //            lineView.backgroundColor=[UIColor colorWithRed:210.0/255 green:214.0/255 blue:219.0/255 alpha:1];
        //            [_scrollView addSubview:lineView];
        //        }
        
    }
    
    amountView=[self createAmountContainer];
    [_scrollView addSubview:amountView];
}

-(void) creditCardButtonPressed
{
    LWCreditCardDepositPresenter *presenter=[LWCreditCardDepositPresenter new];
    presenter.assetID=self.assetID;
    presenter.assetName=self.assetName;
    presenter.issuerId=self.issuerId;
    
    
    // Get a changeable copy of the stack
    NSMutableArray *controllerStack = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    // Replace the source controller with the destination controller, wherever the source may be
    [controllerStack replaceObjectAtIndex:[controllerStack indexOfObject:self] withObject:presenter];
    
    // Assign the updated stack with animation
    [self.navigationController setViewControllers:controllerStack animated:NO];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    infoLabel.text=[NSString stringWithFormat:@"To deposit %@ to your trading\nwallet, please use the following bank\n account details", self.assetName];
    [infoLabel sizeToFit];
    [self setBackButton];
    self.navigationController.navigationBar.barTintColor = BAR_GRAY_COLOR;

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.title = Localize(@"wallets.currency.deposit");
    
    

    

    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}





-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect rrr=self.infoView.bounds;
    
    [infoLabel sizeToFit];
    
    CGFloat offset=0;
    if([LWCache isBankCardDepositEnabledForAssetId:self.assetID])
        offset=30;
    
    swiftButton.center=CGPointMake(self.view.bounds.size.width/2-3-swiftButton.bounds.size.width/2, 25);
    creditCardButton.center=CGPointMake(self.view.bounds.size.width/2+3+creditCardButton.bounds.size.width/2, 25);
    
    infoLabel.center=CGPointMake(self.view.bounds.size.width/2, self.infoView.bounds.size.height/2-20+offset);
    buttonsContainer.center=CGPointMake(self.view.bounds.size.width/2, (infoLabel.frame.origin.y+infoLabel.bounds.size.height+self.infoView.bounds.size.height)/2-5);

    
    
    
    offset=self.infoView.bounds.size.height;
    
    for(LWCurrencyDepositElementView *v in elementViews)
    {
        [v setWidth:self.view.bounds.size.width-60];
        v.center=CGPointMake(self.view.bounds.size.width/2, offset+v.bounds.size.height/2);
        offset+=v.bounds.size.height;
    }
    
    
    amountView.center=CGPointMake(_scrollView.bounds.size.width/2, offset+amountView.bounds.size.height/2);
    
    amountView.frame=CGRectMake(-1, amountView.frame.origin.y, self.view.bounds.size.width+2, amountView.bounds.size.height);
    amountTextField.frame=CGRectMake(amountTextField.frame.origin.x, 0, amountView.bounds.size.width-amountTextField.frame.origin.x-30, amountView.bounds.size.height);
    
    
    offset+=amountView.bounds.size.height;
    
    offset+=50;
    
    //    self.emailButton.frame=CGRectMake(30, offset, _scrollView.bounds.size.width-60, 45);
    self.emailButton.hidden=NO;
    
    self.emailButton.center=CGPointMake(_scrollView.bounds.size.width/2,offset);

    
    offset+=(_emailButton.bounds.size.height+20);
    
    _scrollView.contentSize=CGSizeMake(_scrollView.bounds.size.width, offset);
    
    [self positionCurrencySymbol];
    
}


-(UIView *) createAmountContainer
{
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(-1, 0, self.scrollView.bounds.size.width+2, 50)];
    view.backgroundColor=BAR_GRAY_COLOR;
    view.layer.borderColor=[UIColor colorWithRed:210.0/255 green:214.0/255 blue:219.0/255 alpha:1].CGColor;
    view.layer.borderWidth=0.5;
    
    UILabel *amountLabel=[[UILabel alloc] init];
    amountLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    amountLabel.text=Localize(@"wallets.currency.amount");
    amountLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.6];
    [amountLabel sizeToFit];
    amountLabel.center=CGPointMake(30+amountLabel.bounds.size.width/2, view.bounds.size.height/2);
    [view addSubview:amountLabel];
    
    CGFloat x=amountLabel.frame.origin.x+amountLabel.bounds.size.width+20;
    
    amountTextField=[[UITextField alloc] initWithFrame:CGRectMake(x, 10, view.bounds.size.width-x-30, 30)];
    amountTextField.keyboardType=UIKeyboardTypeNumberPad;
    amountTextField.delegate=self;
    amountTextField.textAlignment=NSTextAlignmentRight;
    amountTextField.font=[UIFont fontWithName:@"ProximaNova-Light" size:22];
    amountTextField.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    amountTextField.text=@"0";
    
    currencySymbolLabel=[[UILabel alloc] init];
    currencySymbolLabel.text=currencySymbol;
    currencySymbolLabel.font=amountTextField.font;
    currencySymbolLabel.textColor=amountTextField.textColor;
    [currencySymbolLabel sizeToFit];
    [amountTextField addSubview:currencySymbolLabel];
    
    [self positionCurrencySymbol];

    [view addSubview:amountTextField];
    return view;
}

-(void) positionCurrencySymbol
{
    UILabel *label=[[UILabel alloc] init];
    label.font=amountTextField.font;
    label.text=amountTextField.text;
    [label sizeToFit];
    currencySymbolLabel.center=CGPointMake(amountTextField.bounds.size.width-label.bounds.size.width-currencySymbolLabel.bounds.size.width/2, amountTextField.bounds.size.height/2);
    
}

-(void) elementViewCopyPressed:(LWCurrencyDepositElementView *) view
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:lineValues[[elementViews indexOfObject:view]]];
    [self showCopied];
}

//-(void) keyboardWillShowNotification:(NSNotification *)notification
//{
//    NSDictionary *info = [notification userInfo];
//    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
//    
//    UIEdgeInsets contentInset = self.scrollView.contentInset;
//    contentInset.bottom = keyboardRect.size.height;
//    self.scrollView.contentInset = contentInset;
//
//    self.scrollView.contentOffset=CGPointMake(0, _scrollView.contentSize.height-(_scrollView.bounds.size.height-contentInset.bottom));
//}
//
//-(void) keyboardWillHideNotification:(NSNotification *)notification
//{
//    UIEdgeInsets contentInset = self.scrollView.contentInset;
//    contentInset.bottom = 0;
//    self.scrollView.contentInset = contentInset;
//}

-(IBAction)emailButtonPressed:(id)sender
{
    if([self checkAmountIsEmpty])
        return;
    [self hideCustomKeyboard];
    [self setLoading:YES];
    
    NSString *string=[amountTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[LWAuthManager instance] requestCurrencyDepositForAsset:self.assetID changeValue:@([string floatValue])];
}

-(BOOL) checkAmountIsEmpty
{
    if([amountTextField.text floatValue]==0)
    {
        [self.view makeToast:@"The amount should be greater than zero." duration:2 position:nil];
        return YES;
    }
    
    return NO;
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

#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.keyboardView.inputView==NO)
        [self showCustomKeyboard];
    self.keyboardView.targetTextField=textField;
    [self.keyboardView setText:[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    self.keyboardView.accuracy=@(2);
    return NO;
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str=[textField.text stringByReplacingCharactersInRange:range withString:string];

    if([textField.text isEqualToString:@"0"] && string.length)
    {
        textField.text=string;
    }
    else if(str.length==0)
    {
        textField.text=@"0";
    }
    else
    {
        textField.text=str;
    }
    
    [self positionCurrencySymbol];
    return NO;
    
}




-(void) mathKeyboardDonePressed:(LWMathKeyboardView *)keyboardView
{
    [self hideCustomKeyboard];
}



-(void) showCustomKeyboard
{
    [super showCustomKeyboard];
    
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.bottom = self.keyboardView.bounds.size.height-(self.view.bounds.size.height-self.scrollView.bounds.size.height);
    [UIView animateWithDuration:0.5 animations:^{
    self.scrollView.contentInset = contentInset;
    
        CGFloat offset=self.scrollView.contentSize.height-(self.scrollView.bounds.size.height-self.keyboardView.bounds.size.height);
        if(offset>0)
            self.scrollView.contentOffset=CGPointMake(0, offset);
        
    }];
}


-(void) hideCustomKeyboard
{
    [super hideCustomKeyboard];
    
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        contentInset.bottom = 0;
        self.scrollView.contentInset = contentInset;
    }];
    
    
    amountTextField.text=[LWUtils formatVolumeString:amountTextField.text currencySign:@"" accuracy:2 removeExtraZeroes:YES];
    [self positionCurrencySymbol];
}

- (void)mathKeyboardView:(LWMathKeyboardView *) view volumeStringChangedTo:(NSString *) string
{

    amountTextField.text=[LWUtils formatVolumeString:string currencySign:@"" accuracy:2 removeExtraZeroes:NO];
    [self positionCurrencySymbol];
    
}

-(void) informationBrochurePressed
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.lykkex.com/Lykke_Corp_Placement_Memorandum.pdf"]];
}


@end
