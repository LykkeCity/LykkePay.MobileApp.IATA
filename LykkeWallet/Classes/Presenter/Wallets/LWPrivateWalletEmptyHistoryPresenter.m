//
//  LWPrivateWalletEmptyHistoryPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 25/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletEmptyHistoryPresenter.h"
#import "LWCommonButton.h"
#import "LWRefreshControlView.h"

@interface LWPrivateWalletEmptyHistoryPresenter ()
{
    
}

@property (weak, nonatomic) IBOutlet LWCommonButton *button;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidthConsraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeightConstraint;

@end

@implementation LWPrivateWalletEmptyHistoryPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.button setTitle:@"DEPOSIT" forState:UIControlStateNormal];
    self.button.type=BUTTON_TYPE_COLORED;
    [self.button addTarget:self.delegate action:@selector(depositPressed) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
    
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
    [_scrollView insertSubview:refreshView atIndex:0];
    
    _refreshControl = [[LWRefreshControlView alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:_refreshControl];
    
    _scrollView.alwaysBounceVertical=YES;
    
    
    if([UIScreen mainScreen].bounds.size.width==320)
        _buttonWidthConsraint.constant=280;
    _lineViewHeightConstraint.constant=0.5;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) refresh
{
    [self.delegate reloadHistory];
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
