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

#define BAR_GRAY_COLOR [UIColor colorWithRed:245.0/255 green:246.0/255 blue:248.0/255 alpha:1]

@interface LWCurrencyDepositPresenter () <UITextFieldDelegate>
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
}

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;

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

    
    CGRect rrr=self.view.frame;
    self.infoView.backgroundColor=BAR_GRAY_COLOR;
    self.infoView.layer.shadowColor=[UIColor blackColor].CGColor;
    self.infoView.layer.shadowOpacity=0.3;
    self.infoView.layer.shadowRadius=1;
    self.infoView.layer.shadowOffset=CGSizeMake(0, 1);
    
    infoLabel=[[UILabel alloc] init];
    infoLabel.numberOfLines=0;
    infoLabel.textAlignment=NSTextAlignmentCenter;
    infoLabel.font=[UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    infoLabel.textColor=[UIColor grayColor];
    
    NSDictionary *accounts=@{
                             @"CHF":@"LI71 0880 1200 9711 0000 1",
                             @"EUR":@"LI08 0880 1200 9711 0181 4",
                             @"USD":@"LI60 0880 1200 9711 0233 3",
                             @"GBP":@"LI06 0880 1200 9711 0340 2"
                             };
    
    lineTitles=@[@"BIC (SWIFT)",
                 @"Account number",
                 @"Account name",
                 @"Purpose of payment"
                 
                  ];
    
    NSString *acc=accounts[self.assetID];
    if(!acc)
        acc=@"";
    
    NSString *email=[[LWKeychainManager instance].login stringByReplacingOccurrencesOfString:@"@" withString:@"(at)"];
    lineValues=@[@"BALPLI22",
                 acc,
                 @"Lykke Corp.",
                 [NSString stringWithFormat:@"Lykke shares (coins) purchase %@ [ %@ ]",self.assetName, email]
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
    termsOfUseButton.titleLabel.font=[UIFont systemFontOfSize:12];
    [termsOfUseButton setTitleColor:[UIColor colorWithRed:180.0/255 green:105.0/255 blue:211.0/255 alpha:1] forState:UIControlStateNormal];
    [termsOfUseButton addTarget:self action:@selector(termsOfUsePressed) forControlEvents:UIControlEventTouchUpInside];
    
    [termsOfUseButton sizeToFit];
    
    prospectusButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [prospectusButton setTitle:@"Lykke Shares Prospectus" forState:UIControlStateNormal];
    prospectusButton.titleLabel.font=[UIFont systemFontOfSize:12];
    [prospectusButton setTitleColor:[UIColor colorWithRed:180.0/255 green:105.0/255 blue:211.0/255 alpha:1] forState:UIControlStateNormal];

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
    
    infoLabel.text=[NSString stringWithFormat:@"To deposit %@ to your trading\nwallet, please use the following bank\n account details", self.assetName];
    [infoLabel sizeToFit];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.title = Localize(@"wallets.currency.deposit");

    
    currencySymbol=[[LWCache instance] currencySymbolForAssetId:self.assetID];
    
    
    CGFloat offset=self.infoView.bounds.size.height;
    for(int i=0;i<lineTitles.count;i++)
    {
        UIView *view=[self viewForRowAtIndex:i];
        view.center=CGPointMake(_scrollView.bounds.size.width/2, offset+view.bounds.size.height/2);
        [_scrollView addSubview:view];
        
        offset+=view.bounds.size.height;
        if(i<lineTitles.count-1)
        {
            UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(30, offset-1, _scrollView.bounds.size.width-60, 1)];
            lineView.backgroundColor=[UIColor colorWithWhite:0.92 alpha:1];
            [_scrollView addSubview:lineView];
        }
        
    }
    
    UIView *amountView=[self createAmountContainer];
    [_scrollView addSubview:amountView];
    amountView.center=CGPointMake(_scrollView.bounds.size.width/2, offset+amountView.bounds.size.height/2);
    
    offset+=amountView.bounds.size.height;
    
    

    offset+=30;
    
//    self.emailButton.frame=CGRectMake(30, offset, _scrollView.bounds.size.width-60, 45);
    self.emailButton.hidden=NO;
    offset+=(_emailButton.bounds.size.height+20);
    
    _scrollView.contentSize=CGSizeMake(_scrollView.bounds.size.width, offset);
    self.scrollViewHeight.constant=offset;

    
}





-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect rrr=self.infoView.bounds;
    infoLabel.center=CGPointMake(self.view.bounds.size.width/2, self.infoView.bounds.size.height/2-20);
    buttonsContainer.center=CGPointMake(self.view.bounds.size.width/2, self.infoView.bounds.size.height/2+infoLabel.bounds.size.height/2+10);
//    self.emailButton.center=CGPointMake(self.view.bounds.size.width/2, self.emailButton.center.y);
}

-(UIView *) viewForRowAtIndex:(int) index
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(30, 0, self.scrollView.bounds.size.width-60, 0)];
    CGFloat height=0;
    
    CGFloat minHeight=50;
    CGFloat titleWidth=80;
    CGFloat copyIconWidth=25;
    
    UILabel *titleLabel=[[UILabel alloc] init];
    titleLabel.font=[UIFont systemFontOfSize:14];
    titleLabel.textColor=[UIColor grayColor];
    titleLabel.numberOfLines=0;
    titleLabel.text=lineTitles[index];
    CGSize size=[titleLabel sizeThatFits:CGSizeMake(titleWidth, 0)];
    if(size.height>height)
        height=size.height;
    [view addSubview:titleLabel];
    
    
    UILabel *textLabel;
    
    UIButton *copyButton;
    
    textLabel=[[UILabel alloc] init];
    textLabel.font=[UIFont systemFontOfSize:16];
    textLabel.textColor=[UIColor blackColor];
    textLabel.numberOfLines=0;
    textLabel.text=lineValues[index];
    size=[textLabel sizeThatFits:CGSizeMake(view.bounds.size.width-titleWidth-20-(copyIconWidth+10), 0)];
    if(size.height>height)
        height=size.height;
    
    [view addSubview:textLabel];
    
    copyButton=[UIButton buttonWithType:UIButtonTypeCustom];
    copyButton.frame=CGRectMake(0, 0, copyIconWidth, copyIconWidth);
    
    
    [copyButton setBackgroundImage:[UIImage imageNamed:@"CopyInDepositIcon"] forState:UIControlStateNormal];
    copyButton.tag=index;
    [copyButton addTarget:self action:@selector(copyPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:copyButton];
    
    height+=20;
    
    if(height<minHeight)
        height=minHeight;
    
    titleLabel.frame=CGRectMake(0, 0, titleWidth, height);
    textLabel.frame=CGRectMake(titleWidth+20, 0, view.bounds.size.width-titleWidth-20-(copyIconWidth+10), height);
    
    titleLabel.center=CGPointMake(titleLabel.center.x, height/2);
    textLabel.center=CGPointMake(textLabel.center.x, height/2);
    
    copyButton.center=CGPointMake(view.bounds.size.width-copyButton.bounds.size.width/2, height/2);
    
    
    view.frame=CGRectMake(view.frame.origin.x, 0, view.bounds.size.width, height);
    
    
    return view;

}

-(UIView *) createAmountContainer
{
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(-1, 0, self.scrollView.bounds.size.width+2, 50)];
    view.backgroundColor=BAR_GRAY_COLOR;
    view.layer.borderColor=[UIColor grayColor].CGColor;
    view.layer.borderWidth=0.5;
    
    UILabel *amountLabel=[[UILabel alloc] init];
    amountLabel.font=[UIFont systemFontOfSize:16];
    amountLabel.text=Localize(@"wallets.currency.amount");
    [amountLabel sizeToFit];
    amountLabel.center=CGPointMake(30+amountLabel.bounds.size.width/2, view.bounds.size.height/2);
    [view addSubview:amountLabel];
    
    CGFloat x=amountLabel.frame.origin.x+amountLabel.bounds.size.width+20;
    
    amountTextField=[[UITextField alloc] initWithFrame:CGRectMake(x, 10, view.bounds.size.width-x-30, 30)];
    amountTextField.keyboardType=UIKeyboardTypeNumberPad;
    amountTextField.delegate=self;
    amountTextField.textAlignment=NSTextAlignmentRight;
    amountTextField.font=[UIFont systemFontOfSize:18];
    amountTextField.text=@"0";
    
    currencySymbolLabel=[[UILabel alloc] init];
    currencySymbolLabel.text=currencySymbol;
    currencySymbolLabel.font=amountTextField.font;
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

-(void) copyPressed:(UIButton *) button
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:lineValues[button.tag]];
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
        [self.view makeToast:@"Amount should be greater then zero." duration:2 position:nil];
    }
    
    return YES;
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

-(void) showCopied
{
    UIWindow *window=[UIApplication sharedApplication].windows[0];
    UIView *shadowView=[[UIView alloc] initWithFrame:window.bounds];
    shadowView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.3];
    [window addSubview:shadowView];
    
    UIView *view=[[UIView alloc] init];
    view.backgroundColor=[UIColor whiteColor];
    view.clipsToBounds=YES;
    [window addSubview:view];
    
    UIView *labelView=[[UIView alloc] init];
    UILabel *label=[[UILabel alloc] init];
    label.font=[UIFont systemFontOfSize:18];
    label.textColor=[UIColor colorWithRed:36.0/255 green:182.0/255 blue:53.0/255 alpha:1];
    label.text=Localize(@"wallets.currency.copied");
    
    [label sizeToFit];
    
    UIImageView *signView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, label.bounds.size.height*1.2, label.bounds.size.height*1.2)];
    signView.image=[UIImage imageNamed:@"CopiedCheckMarkSign.png"];
    labelView.frame=CGRectMake(0, 0, label.bounds.size.width+10+signView.bounds.size.width, signView.bounds.size.width);
    [labelView addSubview:label];
    [labelView addSubview:signView];
    
    label.center=CGPointMake(labelView.bounds.size.width-label.bounds.size.width/2, labelView.bounds.size.height/2);
    
    
    view.frame=CGRectMake(0, 0, labelView.bounds.size.width+80, labelView.bounds.size.height+25);
    view.layer.cornerRadius=view.bounds.size.height/2;

    [view addSubview:labelView];
    
    labelView.center=CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
    
    view.center=CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);
    
    
    
    shadowView.alpha=0;
    view.alpha=0;
    
    [UIView animateWithDuration:0.3 animations:^{
    
        shadowView.alpha=1;
        view.alpha=1;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.3 animations:^{
            
            shadowView.alpha=0;
            view.alpha=0;
        } completion:^(BOOL finished){
            [shadowView removeFromSuperview];
            [view removeFromSuperview];
        
        }];

        
    });
    
    
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
    self.scrollView.contentOffset=CGPointMake(0, self.keyboardView.bounds.size.height-(self.view.bounds.size.height-self.scrollView.bounds.size.height));
//    self.scrollView.contentOffset=CGPointMake(0, _scrollView.contentSize.height-(_scrollView.bounds.size.height-contentInset.bottom));
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


@end
