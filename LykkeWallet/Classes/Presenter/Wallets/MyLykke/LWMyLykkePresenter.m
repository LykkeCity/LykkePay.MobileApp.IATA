//
//  LWMyLykkePresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 26/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkePresenter.h"
#import "LWCommonButton.h"
#import "LWAuthComplexPresenter.h"
#import "LWMyLykkeBuyPresenter.h"
#import "LWPacketMyLykkeInfo.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "LWUtils.h"
#import "LWKeychainManager.h"
#import "LWMyLykkeInfoPresenter.h"
#import "LWMyLykkeNewsListPresenter.h"
#import "LWTabController.h"

@interface LWMyLykkePresenter ()
{
    BOOL infoLoaded;
    NSTimer *timer;
    
}
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *equityView;
@property (weak, nonatomic) IBOutlet UIView *newsView;
@property (weak, nonatomic) IBOutlet UILabel *equityLabel;
@property (weak, nonatomic) IBOutlet UILabel *newsLabel;
@property (weak, nonatomic) IBOutlet LWCommonButton *buyButton;

@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UILabel *marketValue;
@property (weak, nonatomic) IBOutlet UILabel *equity;
@property (weak, nonatomic) IBOutlet UILabel *numberOfShares;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fieldsWidth;

@end

@implementation LWMyLykkePresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[LWAuthManager instance] requestLykkeNews];//Testing
    
    _equityView.clipsToBounds=YES;
    _equityView.layer.cornerRadius=_equityView.bounds.size.height/2;
    
    NSDictionary *attr=@{NSKernAttributeName:@(1.2), NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14]};
    _equityLabel.attributedText=[[NSAttributedString alloc] initWithString:@"EQUITY" attributes:attr];    
    _equityLabel.textColor=[UIColor whiteColor];
    
    _buyButton.type=BUTTON_TYPE_GREEN;
    _buyButton.enabled=YES;
    infoLoaded=NO;
    
    self.nameLabel.text=[LWKeychainManager instance].fullName;
    [self.infoButton addTarget:self action:@selector(infoPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if([UIScreen mainScreen].bounds.size.width==320)
    {
        self.fieldsWidth.constant=270;
    }
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newsPressed)];
    [self.newsLabel addGestureRecognizer:gesture];
    _newsLabel.userInteractionEnabled=YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)buyLykkePressed:(id)sender
{
    LWMyLykkeBuyPresenter *presenter=[[LWMyLykkeBuyPresenter alloc] init];
    [self.navigationController pushViewController:presenter animated:YES];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(infoLoaded==NO)
        [self setLoading:YES];
    infoLoaded=YES;
    timer=[NSTimer timerWithTimeInterval:5 target:self selector:@selector(loadMyLykkeInfo) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [self loadMyLykkeInfo];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:246.0/255 green:247.0/255 blue:248.0/255 alpha:1]];
    self.title=@"MY LYKKE";
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
}


-(void) loadMyLykkeInfo
{
    [[LWAuthManager instance] requestMyLykkeInfo];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.currentTimeLabel.text=[[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@" local time"];
    

}

-(void) authManager:(LWAuthManager *)manager didGetMyLykkeInfo:(LWPacketMyLykkeInfo *)packet
{
    [self setLoading:NO];
    self.balance.text=[LWUtils formatVolumeNumber:packet.lkkBalance currencySign:@"" accuracy:0 removeExtraZeroes:NO];
    self.balance.text=[self.balance.text stringByReplacingOccurrencesOfString:@" " withString:@","];
    
    
    if(packet.myEquityPercent.doubleValue<0.001)
    {
        self.equity.text=@"<0.001%";
    }
    else
    {
        self.equity.text=[[LWUtils formatVolumeNumber:packet.myEquityPercent currencySign:@"" accuracy:3 removeExtraZeroes:YES] stringByAppendingString:@"%"];
    }
    
    self.numberOfShares.text=[LWUtils formatVolumeNumber:packet.numberOfShares currencySign:@"" accuracy:2 removeExtraZeroes:YES];
    self.numberOfShares.text=[self.numberOfShares.text stringByReplacingOccurrencesOfString:@" " withString:@","];

    self.marketValue.text=[LWUtils formatVolumeNumber:packet.marketValue currencySign:@"$" accuracy:0 removeExtraZeroes:YES];
    self.marketValue.text=[self.marketValue.text stringByReplacingOccurrencesOfString:@" " withString:@","];
    
    
}

-(void) infoPressed
{
    LWMyLykkeInfoPresenter *presenter=[LWMyLykkeInfoPresenter new];
    [self.navigationController pushViewController:presenter animated:YES];
}

-(void) newsPressed
{

    LWMyLykkeNewsListPresenter *presenter=[[LWMyLykkeNewsListPresenter alloc] init];
    presenter.tabBarItem=self.tabBarItem;

//    [self.navigationController pushViewController:presenter animated:YES];
    NSArray *arr=self.navigationController.viewControllers;
//    if([arr[0] isKindOfClass:[LWTabController class]])
//    {
        LWTabController *tabController=arr[0];
        NSMutableArray *newTabcontrollers=[[NSMutableArray alloc] init];
        for(UIViewController *v in tabController.viewControllers)
        {
            if([v isKindOfClass:[LWMyLykkePresenter class]])
            {
                [newTabcontrollers addObject:presenter];
            }
            else
                [newTabcontrollers addObject:v];
        }
        [tabController setViewControllers:newTabcontrollers];
//    }
 //   [self.navigationController setViewControllers:@[presenter] animated:NO];
}

-(void) dealloc
{
    [timer invalidate];
}

-(NSString *) nibName
{
    if([UIScreen mainScreen].bounds.size.width==320)
        return @"LWMyLykkePresenter_Iphone5";
    else
        return @"LWMyLykkePresenter";
    
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
