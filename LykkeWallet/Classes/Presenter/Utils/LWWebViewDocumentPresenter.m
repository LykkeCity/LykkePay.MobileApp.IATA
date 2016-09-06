//
//  LWWebViewDocumentPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 05/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWebViewDocumentPresenter.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "LWMyLykkeIPadNavigationController.h"

@interface LWWebViewDocumentPresenter () <UIWebViewDelegate>
{
    BOOL loaded;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation LWWebViewDocumentPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate=self;
    loaded=NO;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!loaded)
        [self setLoading:YES];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad && [self.navigationController isKindOfClass:[LWMyLykkeIPadNavigationController class]])
    {
        [self.navigationController setNavigationBarHidden:YES];
    }
    else
        [self setBackButton];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad && [self.navigationController isKindOfClass:[LWMyLykkeIPadNavigationController class]])
    {
        self.navigationController.title=self.documentTitle;
    }
    else
        self.title=self.documentTitle;
    
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    loaded=YES;
    [self setLoading:NO];
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    loaded=YES;
    [self setLoading:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
