//
//  LWCreditCardDepositPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 26/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCreditCardDepositPresenter.h"
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

#define COUNTRIES_FILENAME @"countries.cache"


#define BAR_GRAY_COLOR [UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1]

@interface LWCreditCardDepositPresenter () <UITextFieldDelegate, UIWebViewDelegate, LWResultPresenterDelegate>
{
    NSString *okUrl;
    NSString *failUrl;
    NSArray *countries;
    
    UIWebView *webView;
    UIView *whiteView;
    NSString *regexExp;
}


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomOffsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *creditCardIconTopOffset;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *amount;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *country;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *zip;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *phone;

@property (weak, nonatomic) IBOutlet UIButton *swiftButton;
@property (weak, nonatomic) IBOutlet UIButton *creditCardButton;
@property (weak, nonatomic) IBOutlet UIButton *cachInButton;

@property (weak, nonatomic) IBOutlet UIView *swiftCardMenuContainer;






@end

@implementation LWCreditCardDepositPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *topBackView=[[UIView alloc] initWithFrame:CGRectMake(0, -300, 1024, 300)];
    topBackView.backgroundColor=BAR_GRAY_COLOR;
    [self.scrollView addSubview:topBackView];


    if([LWCache isSwiftDepositEnabledForAssetId:self.assetID]==NO)
    {
        self.topViewHeightConstraint.constant=self.topViewHeightConstraint.constant-60;
        self.creditCardIconTopOffset.constant=16;
        self.swiftCardMenuContainer.hidden=YES;
    }
    
    self.firstName.autocapitalizationType=UITextAutocapitalizationTypeWords;
    self.lastName.autocapitalizationType=UITextAutocapitalizationTypeWords;
    self.city.autocapitalizationType=UITextAutocapitalizationTypeWords;
    self.address.autocapitalizationType=UITextAutocapitalizationTypeWords;
    
    [self.cachInButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"WIRE TRANSFER" attributes:@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]}] forState:UIControlStateNormal];
    [self.swiftButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"SWIFT" attributes:@{NSKernAttributeName:@(1.1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:13], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]}] forState:UIControlStateNormal];
    self.creditCardButton.backgroundColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    self.creditCardButton.clipsToBounds=YES;
    self.creditCardButton.layer.cornerRadius=self.creditCardButton.bounds.size.height/2;

    [LWValidator setButton:self.cachInButton enabled:YES];
    
    
    self.amount.keyboardType=UIKeyboardTypeNumberPad;
    self.amount.text=@"$0";
    
    self.amount.delegate=self;
//    self.amount.font=[UIFont fontWithName:@"ProximaNova-Light" size:22];
    self.amount.font=self.amount.font;
    
    [self checkTextFieldsAlpha];
    
    self.country.delegate=self;
    
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, self.amount.frame.origin.y-0.5, 1024, 0.5)];
    line.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [_scrollView addSubview:line];
    
    line=[[UIView alloc] initWithFrame:CGRectMake(0, self.amount.frame.origin.y+self.amount.bounds.size.height-0.5, 1024, 0.5)];
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
    self.title=@"DEPOSIT WALLET";

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
    if(textField!=self.amount)
    {
        if(newText.length==0)
            textField.alpha=0.5;
        else
            textField.alpha=1;
        return YES;
    }
    
    NSString *testText=[newText substringFromIndex:1];
    if([testText stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].length>0)
        return NO;
    
    if(newText.length==1)
        newText=@"$0";
    else if([[newText substringFromIndex:1] isEqualToString:@"00"])
        newText=@"$0";
    else if(newText.length>2)
    {
        NSString *sub=[newText substringWithRange:NSMakeRange(1, 1)];
        if([sub isEqualToString:@"0"] && [[newText substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"."]==NO)
            newText=[NSString stringWithFormat:@"$%@", [newText substringFromIndex:2]];
    }
    
    
    textField.text=newText;
    return NO;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    
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

-(IBAction)swiftButtonPressed:(id)sender
{
    LWCurrencyDepositPresenter *presenter=[LWCurrencyDepositPresenter new];
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

    
    NSDictionary *params=@{@"Amount":[self.amount.text stringByReplacingOccurrencesOfString:@"$" withString:@""], @"FirstName":self.firstName.text, @"LastName":self.lastName.text, @"City":self.city.text, @"Zip":self.zip.text, @"Address":self.address.text, @"Country":code, @"Email":self.email.text, @"Phone":self.phone.text};
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
        
//        
//        
//        
//        
//        NSRange first=[html rangeOfString:@"{"];
//        if(first.location!=NSNotFound)
//        {
//            html=[html substringFromIndex:first.location];
//            NSRange second=[html rangeOfString:@"}"];
//            if(second.location!=NSNotFound)
//            {
//                html=[html substringToIndex:second.location];
//                html=[html stringByReplacingOccurrencesOfString:@" " withString:@""];
//                if([html rangeOfString:@"status\":440"].location!=NSNotFound)
//                {
//                    whiteView=[[UIView alloc] initWithFrame:webView.frame];
//                    whiteView.backgroundColor=[UIColor whiteColor];
//                    [self.view addSubview:whiteView];
//                    webView.delegate=nil;
//                    [webView removeFromSuperview];
//                    webView=nil;
//                    
//                    NSLog(@"TimeOUT!");
//                    [self cashInButtonPressed:nil];
//
//                }
//                
//            }
//
//            
//        }
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
//    if([url isEqualToString:okUrl])
//    {
//        
//        
//        
//        
//        
//        
////        NSLog(@"Found OK URL");
////        UIWindow *window=[UIApplication sharedApplication].windows[0];
////        LWSuccessPresenterView *successView=[[LWSuccessPresenterView alloc] initWithFrame:window.bounds title:@"SUCCESSFUL!" text:@"Your payment was successfully sent!\nReturn to wallet and proceed with the trade."];
////        successView.delegate=self;
////        [window addSubview:successView];
//
//    }
//    else if([url isEqualToString:failUrl])
//    {
//        NSLog(@"Found FAIL URL");
//        
//
//        
//    }
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
//    return NO;
    
//    UIWindow *window=[UIApplication sharedApplication].windows[0];
//    LWFailedPresenterView *failView=[[LWFailedPresenterView alloc] initWithFrame:window.bounds title:@"OOPS!" text:@"We're terribly sorry, but we failed to make a payment on your provided details. Please try again later."];
//    failView.delegate=self;
//    [window addSubview:failView];

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
                   if(v1.text.length==0 || (v1==self.amount && [self.amount.text substringFromIndex:1].floatValue==0))
                   {
                       NSString *placeholder=v1.placeholder;
                       if(v1==self.amount)
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
                if([v1 isKindOfClass:[UITextField class]] && v1!=self.amount && v1!=self.country)
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





@end
