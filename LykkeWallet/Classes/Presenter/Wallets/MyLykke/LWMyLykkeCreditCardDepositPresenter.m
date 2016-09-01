//
//  LWMyLykkeCreditCardDepositPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 30/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeCreditCardDepositPresenter.h"
#import "LWAuthManager.h"
#import "LWPacketGetPaymentUrl.h"
#import "LWPersonalDataModel.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "LWCurrencyDepositPresenter.h"
#import "LWValidator.h"
#import "LWSuccessPresenterView.h"
#import "LWFailedPresenterView.h"
#import "LWDropdownView.h"
#import "LWPacketCountryCodes.h"
#import "LWKeychainManager.h"
#import "LWResultPresenter.h"
#import "LWPacketPrevCardPayment.h"
#import "LWCache.h"
#import "LWIPadModalNavigationControllerViewController.h"
#import "LWUtils.h"
#import "LWNumbersKeyboardView.h"
#import "LWCommonButton.h"

#define COUNTRIES_FILENAME @"countries.cache"


#define BAR_GRAY_COLOR [UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1]

@interface LWMyLykkeCreditCardDepositPresenter () <UITextFieldDelegate, UIWebViewDelegate, LWResultPresenterDelegate>
{
    NSString *okUrl;
    NSString *failUrl;
    NSArray *countries;
    
    UIWebView *webView;
    UIView *whiteView;
    NSString *regexExp;
    
    LWNumbersKeyboardView *keyboard;
    BOOL keyboardIsVisible;
}


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;



@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *country;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *zip;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *phone;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomOffsetConstraint;




@property (weak, nonatomic) IBOutlet LWCommonButton *submitButton;








@end

@implementation LWMyLykkeCreditCardDepositPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *topBackView=[[UIView alloc] initWithFrame:CGRectMake(0, -300, 1024, 300)];
    topBackView.backgroundColor=BAR_GRAY_COLOR;
    [self.scrollView addSubview:topBackView];
    
    
    
    self.firstName.autocapitalizationType=UITextAutocapitalizationTypeWords;
    self.lastName.autocapitalizationType=UITextAutocapitalizationTypeWords;
    self.city.autocapitalizationType=UITextAutocapitalizationTypeWords;
    self.address.autocapitalizationType=UITextAutocapitalizationTypeWords;
    
    
    
    
    
    self.amountTextField.keyboardType=UIKeyboardTypeNumberPad;
    
    NSString *formatted=[LWUtils formatFairVolume:self.amount accuracy:[LWCache accuracyForAssetId:@"USD"] roundToHigher:NO];
    formatted=[formatted stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.amountTextField.text=[self formatVolume:formatted];
    
    self.amountTextField.delegate=self;
    //    self.amount.font=[UIFont fontWithName:@"ProximaNova-Light" size:22];
    self.amountTextField.font=self.amountTextField.font;
    
    [self checkTextFieldsAlpha];
    
    self.country.delegate=self;
    
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, self.amountTextField.frame.origin.y-0.5, 1024, 0.5)];
    line.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [_scrollView addSubview:line];
    
    line=[[UIView alloc] initWithFrame:CGRectMake(0, self.amountTextField.frame.origin.y+self.amountTextField.bounds.size.height-0.5, 1024, 0.5)];
    line.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [_scrollView addSubview:line];
    
    NSString *path=[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), COUNTRIES_FILENAME];
    BOOL countriesCached=[[NSFileManager defaultManager] fileExistsAtPath:path];
    //  countriesCached=NO;
    if(countriesCached)
    {
        NSDate *modifiedDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"CountryPhoneCodesLastModified"];
        NSDate *loadedDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"CountryPhoneCodesLastLoaded"];
        if(modifiedDate && loadedDate && [loadedDate timeIntervalSinceReferenceDate]>[modifiedDate timeIntervalSinceReferenceDate])
            countries=[NSArray arrayWithContentsOfFile:path];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foundSuccessUrl) name:@"CreditCardFoundSuccessURL" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foundFailUrl) name:@"CreditCardFoundFailURL" object:nil];
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = BAR_GRAY_COLOR;
    self.navigationController.navigationBar.translucent = NO;
    
    self.observeKeyboardEvents = YES;
    
    LWPersonalDataModel *data;
    if([LWCache instance].lastCardPaymentData)
        data=[LWCache instance].lastCardPaymentData;
    else
        data=[LWKeychainManager instance].personalData;
    
    self.firstName.text=data.firstName;
    self.lastName.text=data.lastName;
    self.city.text=data.city;
    self.zip.text=data.zip;
    self.address.text=data.address;
    if(countries)
    {
        for(NSDictionary *d in countries)
        {
            if([data.country isEqualToString:d[@"iso2"]] || [data.country isEqualToString:d[@"code"]])
                self.country.text=d[@"name"];
        }
    }
    self.email.text=data.email;
    self.phone.text=data.phone;
    [self checkTextFieldsAlpha];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        [self setBackButton];
    else
    {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        self.navigationItem.leftBarButtonItem = button;
    }
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"BUY LYKKE";
    
    if(countries==nil)
    {
        [self setLoading:YES];
        [[LWAuthManager instance] requestCountyCodes];
    }
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

-(void) backButtonPressed
{
    if(webView)
    {
        [webView removeFromSuperview];
        webView=nil;
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
            [self setBackButton];
        else
        {
            UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
            self.navigationItem.leftBarButtonItem = button;
        }
    }
    else
        [self.navigationController popViewControllerAnimated:NO];
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *newText=[textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textField!=self.amountTextField)
    {
        if(newText.length==0)
            textField.alpha=0.5;
        else
            textField.alpha=1;
        return YES;
    }
    
    

    
//    
//    
//    
//    NSString *testText=[newText substringFromIndex:1];
//    if([testText stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].length>0)
//        return NO;
//    
//    if(newText.length==1)
//        newText=@"$0";
//    else if([[newText substringFromIndex:1] isEqualToString:@"00"])
//        newText=@"$0";
//    else if(newText.length>2)
//    {
//        NSString *sub=[newText substringWithRange:NSMakeRange(1, 1)];
//        if([sub isEqualToString:@"0"] && [[newText substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"."]==NO)
//            newText=[NSString stringWithFormat:@"$%@", [newText substringFromIndex:2]];
//    }
//    
//    
//    textField.text=newText;
    return NO;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField==self.amountTextField)
    {
        if(keyboardIsVisible)
            return NO;
        [self.view endEditing:YES];
        keyboard=[[LWNumbersKeyboardView alloc] init];
        keyboard.showDoneButton=YES;
        keyboard.showDotButton=YES;
        keyboard.showPredefinedSums=YES;
        keyboard.delegate=self;
        keyboard.accuracy=[LWCache accuracyForAssetId:@"USD"];
        float coeff=0.776;
        if([UIScreen mainScreen].bounds.size.width==320)
            coeff=0.65;
        keyboard.frame=CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.width*coeff);
        [self.view addSubview:keyboard];
        //    [self.view layoutSubviews];
        
        keyboard.textField=textField;
        _scrollView.contentOffset=CGPointMake(0, 0);
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.buttonBottomConstraint.constant=self.scrollView.contentSize.height-(self.headerViewHeightConstraint.constant+(self.view.bounds.size.height-keyboard.bounds.size.height)/2+22.5);
            
            self.buttonBottomConstraint.constant=self.scrollView.contentSize.height-self.headerViewHeightConstraint.constant-45-30;
            
            [UIView animateWithDuration:0.3 animations:^{
                keyboard.center=CGPointMake(keyboard.center.x, keyboard.center.y-keyboard.bounds.size.height);
                [self.view layoutIfNeeded];
            }];
            
            keyboardIsVisible=YES;
            
            [self hideShowTextFields:YES];
            _scrollView.scrollEnabled=NO;
            
//            self.scrollView.hidden=YES;
            
        });
        return NO;
    }

    
    if(textField==self.country)
    {
        [self.view endEditing:YES];
        if(countries)
            [self showCountriesDropDown];
        return NO;
    }
    else
        return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) observeKeyboardWillShowNotification:(NSNotification *)notification
{
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    CGPoint point=[window convertPoint:CGPointMake(0, window.bounds.size.height-frame.size.height) toView:self.view];
    
    [self.bottomOffsetConstraint setConstant:self.view.bounds.size.height-point.y];
    
}

-(void) observeKeyboardWillHideNotification:(NSNotification *)notification
{
    [self.bottomOffsetConstraint setConstant:0];
}


-(IBAction)cashInButtonPressed:(id)sender
{
    [self.view endEditing:YES];
    if([self checkTextFieldsNotEmpty]==NO)
        return;
    [self setLoading:YES];
    
    NSString *code=@"";
    for(NSDictionary *d in countries)
    {
        if([self.country.text isEqualToString:d[@"name"]])
            code=d[@"iso2"];
    }
    
    
    NSDictionary *params=@{@"Amount":[self.amountTextField.text stringByReplacingOccurrencesOfString:@"$" withString:@""], @"FirstName":self.firstName.text, @"LastName":self.lastName.text, @"City":self.city.text, @"Zip":self.zip.text, @"Address":self.address.text, @"Country":code, @"Email":self.email.text, @"Phone":self.phone.text};
    [[LWAuthManager instance] requestGetPaymentUrlWithParameters:params];
}



-(void) authManager:(LWAuthManager *)manager didGetPaymentUrl:(LWPacketGetPaymentUrl *)packet
{
    [self setLoading:NO];
    if(packet.urlString)
    {
        okUrl=packet.successUrl;
        failUrl=packet.failUrl;
        regexExp=packet.reloadRegex;
        webView=[[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.delegate=self;
        [self.view addSubview:webView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setLoading:YES];
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:packet.urlString]]];
            [[LWAuthManager instance] requestPrevCardPayment];
        });
        
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CloseCross"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        self.navigationItem.leftBarButtonItem = button;
        
        
        
    }
    
}

-(void) authManager:(LWAuthManager *)manager didGetCountryCodes:(LWPacketCountryCodes *)countryCodess
{
    [self setLoading:NO];
    
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    for(LWCountryModel *m in countryCodess.countries)
    {
        [arr addObject:@{@"name": m.name, @"code":m.identity, @"iso2":m.iso2}];
    }
    countries=arr;
    NSString *path=[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), COUNTRIES_FILENAME];
    [countries writeToFile:path atomically:YES];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"CountryPhoneCodesLastLoaded"];
    
    LWPersonalDataModel *data;
    if([LWCache instance].lastCardPaymentData)
        data=[LWCache instance].lastCardPaymentData;
    else
        data=[LWKeychainManager instance].personalData;
    
    for(NSDictionary *d in countries)
    {
        if([data.country isEqualToString:d[@"iso2"]] || [data.country isEqualToString:d[@"code"]])
            self.country.text=d[@"name"];
    }
}


-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    [self setLoading:NO];
    [self showReject:reject response:context.task.response];
}

-(void) showCountriesDropDown
{
    NSMutableArray *names=[[NSMutableArray alloc] init];
    int active=-1;
    for(NSDictionary *d in countries)
    {
        [names addObject:d[@"name"]];
        if([self.country.text isEqualToString:d[@"name"]])
            active=(int)names.count-1;
    }
    [LWDropdownView showWithElements:names title:@"COUNTRY" showDone:NO showCancel:NO activeIndex:active completion:^(NSInteger index){
        if(index>=0)
        {
            self.country.text=countries[index][@"name"];
        }
    }];
}

-(void) webViewDidFinishLoad:(UIWebView *)_webView
{
    [self setLoading:NO];
    
    NSString *html=[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    if(html.length>10)
    {
        
        
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:regexExp
                                      options:NSRegularExpressionCaseInsensitive
                                      error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:html
                                                        options:0
                                                          range:NSMakeRange(0, [html length])];
        if (match) {
            NSRange range = [match range];
            if (range.location != NSNotFound) {
                whiteView=[[UIView alloc] initWithFrame:webView.frame];
                whiteView.backgroundColor=[UIColor whiteColor];
                [self.view addSubview:whiteView];
                webView.delegate=nil;
                [webView removeFromSuperview];
                webView=nil;
                
                NSLog(@"TimeOUT!");
                [self cashInButtonPressed:nil];
                
            }
        }
     }
}



-(BOOL) webView:(UIWebView *)_webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(whiteView)
    {
        [whiteView removeFromSuperview];
        whiteView=nil;
    }
    NSString *url=request.URL.absoluteString;
    NSLog(@"Loaded URL: %@", url);
    return YES;
}

-(void) foundSuccessUrl
{
    webView.delegate=nil;
    [webView stopLoading];
    LWResultPresenter *presenter=[[LWResultPresenter alloc] init];
    presenter.image=[UIImage imageNamed:@"WithdrawSuccessFlag.png"];
    presenter.titleString=@"SUCCESSFUL!";
    presenter.textString=@"Your payment was successfully sent!\nReturn to wallet and proceed with the trade.";
    
    presenter.delegate=self;
    [self.navigationController presentViewController:presenter animated:YES completion:nil];
    
}

-(void) foundFailUrl
{
    [webView stopLoading];
    webView.delegate=nil;
    [webView removeFromSuperview];
    webView=nil;
    
}


-(void) resultPresenterDismissed
{
    //    [self.navigationController popViewControllerAnimated:NO];
}

-(void) resultPresenterWillDismiss
{
    [webView removeFromSuperview];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        NSMutableArray *arr=[NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [arr removeLastObject];
        [self.navigationController setViewControllers:arr];
    }
    else
    {
        self.navigationController.view.hidden=YES;
        [(LWIPadModalNavigationControllerViewController *) self.navigationController dismissAnimated:NO];
    }
}


-(IBAction)termsOfUsePressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://wiki.lykkex.com/terms_of_use"]];
}


-(BOOL) checkTextFieldsNotEmpty
{
    for(UIView *v in _scrollView.subviews)
    {
        if([v isKindOfClass:[UIView class]])
        {
            for(UITextField *v1 in v.subviews)
            {
                if([v1 isKindOfClass:[UITextField class]])
                {
                    if(v1.text.length==0 || (v1==self.amountTextField && [self.amountTextField.text substringFromIndex:1].floatValue==0))
                    {
                        NSString *placeholder=v1.placeholder;
                        if(v1==self.amountTextField)
                            placeholder=@"Amount";
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"LYKKE" message:[NSString stringWithFormat:@"Please fill %@ field.", placeholder] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                        return NO;
                    }
                }
            }
        }
    }
    return YES;
}

-(void) checkTextFieldsAlpha
{
    for(UIView *v in _scrollView.subviews)
    {
        if([v isKindOfClass:[UIView class]])
        {
            for(UITextField *v1 in v.subviews)
            {
                if([v1 isKindOfClass:[UITextField class]] && v1!=self.amountTextField && v1!=self.country)
                {
                    [v1 setDelegate:self];
                    if(v1.text.length==0)
                        v1.alpha=0.5;
                    else
                        v1.alpha=1;
                    v1.superview.layer.cornerRadius=2.5;
                    
                }
            }
        }
    }
    
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void) numbersKeyboardChangedText:(LWNumbersKeyboardView *) keyboard
{
    
    
    if([[self removePrefix:self.amountTextField.text] doubleValue]>0)
        _submitButton.enabled=YES;
    else
        _submitButton.enabled=NO;
    
    self.amountTextField.text=[self formatVolume:[self removePrefix:_amountTextField.text]];
}


-(NSString *) formatVolume:(NSString *) vol
{
    NSString *volume=[vol copy];
    NSString *leftPart;
    NSString *rightPart;
    NSArray *arr=[volume componentsSeparatedByString:@"."];
    if(arr.count!=2)
        leftPart=volume;
    else
    {
        leftPart=arr[0];
        rightPart=arr[1];
    }
    NSString *string=[LWUtils formatVolumeString:leftPart currencySign:@"" accuracy:0 removeExtraZeroes:NO];
    leftPart=[string stringByReplacingOccurrencesOfString:@" " withString:@","];
    if(rightPart)
        volume=[NSString stringWithFormat:@"%@.%@", leftPart, rightPart];
    else
        volume=leftPart;
    
    volume=[@"$ " stringByAppendingString:volume];
    
    return volume;
}

-(NSString *) removePrefix:(NSString *) string
{
    string=[string stringByReplacingOccurrencesOfString:@"$ " withString:@""];
    string=[string stringByReplacingOccurrencesOfString:@"," withString:@""];
    string=[string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}


-(void) numbersKeyboardViewPressedDone
{
    [self hideCustomKeyboard];
}

-(void) hideCustomKeyboard
{
    self.buttonBottomConstraint.constant=30;
    
    [UIView animateWithDuration:0.3 animations:^{
        keyboard.center=CGPointMake(keyboard.center.x, keyboard.center.y+keyboard.bounds.size.height);
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished){
        [keyboard removeFromSuperview];
        keyboard=nil;
        
    }];
    keyboardIsVisible=NO;
//    self.scrollView.hidden=NO;
    [self hideShowTextFields:NO];
    self.scrollView.scrollEnabled=YES;
    
}


-(void) hideShowTextFields:(BOOL) hidden
{
    _firstName.superview.hidden=hidden;
    _lastName.superview.hidden=hidden;
    _country.superview.hidden=hidden;
    _city.superview.hidden=hidden;
    _zip.superview.hidden=hidden;
    
    _address.superview.hidden=hidden;
    _email.superview.hidden=hidden;
    _phone.superview.hidden=hidden;

}




@end
