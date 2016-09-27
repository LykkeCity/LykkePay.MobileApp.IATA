//
//  LWNewsDetailPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 31/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWNewsDetailPresenter.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"

@interface LWNewsDetailPresenter () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LWNewsDetailPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate=self;
    self.webView.backgroundColor=[UIColor colorWithRed:244.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    self.webView.scalesPageToFit=YES;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setLoading:YES];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    [self setBackButton];

}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self setLoading:NO];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"NEWS";
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
