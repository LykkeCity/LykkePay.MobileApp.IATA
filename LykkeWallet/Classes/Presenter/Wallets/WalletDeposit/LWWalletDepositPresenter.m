//
//  LWWalletDepositPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.02.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWalletDepositPresenter.h"
#import "LWAssetModel.h"
#import "LWCache.h"
#import "UIViewController+Navigation.h"


@interface LWWalletDepositPresenter () <UIWebViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UIWebView               *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;


#pragma mark - Root

- (void)loadNews;

@end


@implementation LWWalletDepositPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *assetName = [LWAssetModel
                           assetByIdentity:self.assetId
                           fromList:[LWCache instance].baseAssets];
    
    NSString *title = [NSString stringWithFormat:Localize(@"wallets.funds.title"), assetName];
    self.title = title;
    
    [self setBackButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.webView.delegate = self;
    [self loadNews];
}


#pragma mark - Root

- (void)loadNews {
    //NSLog(@"Url: %@", self.url);
    NSURL* nsUrl = [NSURL URLWithString:self.url];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    [self.webView loadRequest:request];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.indicatorView startAnimating];
    self.indicatorView.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicatorView stopAnimating];
    self.indicatorView.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    [self.indicatorView stopAnimating];
    self.indicatorView.hidden = YES;
}

@end
