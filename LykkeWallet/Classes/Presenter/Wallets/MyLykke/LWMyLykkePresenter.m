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
#import "LWCache.h"
#import "LWKeychainManager.h"
#import "LWMyLykkeInfoPresenter.h"
#import "LWMyLykkeNewsListPresenter.h"
#import "LWTabController.h"
#import "LWAssetDescriptionModel.h"
#import "LWMyLykkeIpadController.h"

@interface LWMyLykkePresenter ()
{
    BOOL infoLoaded;
    NSTimer *timer;
    
    BOOL descriptionLoaded;
    
}

@property (weak, nonatomic) IBOutlet UIView *iPadLandscapeView;
@property (weak, nonatomic) IBOutlet UIView *iPadPortraitView;



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

@property (weak, nonatomic) IBOutlet UILabel *assetClassLabel;
@property (weak, nonatomic) IBOutlet UILabel *assetDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *issuerNameLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fieldsWidth;




@property (weak, nonatomic) IBOutlet UILabel *nameLabel2;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel2;

@property (weak, nonatomic) IBOutlet UIView *equityView2;
@property (weak, nonatomic) IBOutlet UIView *newsView2;
@property (weak, nonatomic) IBOutlet UILabel *equityLabel2;
@property (weak, nonatomic) IBOutlet UILabel *newsLabel2;
@property (weak, nonatomic) IBOutlet LWCommonButton *buyButton2;

@property (weak, nonatomic) IBOutlet UILabel *balance2;
@property (weak, nonatomic) IBOutlet UILabel *marketValue2;
@property (weak, nonatomic) IBOutlet UILabel *equity2;
@property (weak, nonatomic) IBOutlet UILabel *numberOfShares2;

@property (weak, nonatomic) IBOutlet UILabel *assetClassLabel2;
@property (weak, nonatomic) IBOutlet UILabel *assetDescriptionLabel2;
@property (weak, nonatomic) IBOutlet UILabel *issuerNameLabel2;





@end

@implementation LWMyLykkePresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[LWAuthManager instance] requestLykkeNews];//Testing
    
    [self adjustThinLines];
    
    _equityView.clipsToBounds=YES;
    _equityView.layer.cornerRadius=_equityView.bounds.size.height/2;
    _equityView2.clipsToBounds=YES;
    _equityView2.layer.cornerRadius=_equityView.bounds.size.height/2;

    
    
    NSDictionary *attr=@{NSKernAttributeName:@(1.2), NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14]};
    _equityLabel.attributedText=[[NSAttributedString alloc] initWithString:@"EQUITY" attributes:attr];    
    _equityLabel.textColor=[UIColor whiteColor];
    _equityLabel2.attributedText=[[NSAttributedString alloc] initWithString:@"EQUITY" attributes:attr];
    _equityLabel2.textColor=[UIColor whiteColor];
    
    _buyButton.type=BUTTON_TYPE_GREEN;
    _buyButton.enabled=YES;
    _buyButton2.type=BUTTON_TYPE_GREEN;
    _buyButton2.enabled=YES;

    infoLoaded=NO;
    descriptionLoaded=NO;
    
    self.nameLabel.text=[LWKeychainManager instance].fullName;
    self.nameLabel2.text=[LWKeychainManager instance].fullName;
    [self.infoButton addTarget:self action:@selector(infoPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if([UIScreen mainScreen].bounds.size.width==320)
    {
        self.fieldsWidth.constant=270;
    }
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newsPressed)];
    [self.newsLabel addGestureRecognizer:gesture];
    _newsLabel.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *gesture2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newsPressed)];
    [self.newsLabel2 addGestureRecognizer:gesture2];
    _newsLabel2.userInteractionEnabled=YES;

    
    self.currentTimeLabel.text=[LWKeychainManager instance].login;
    self.currentTimeLabel2.text=[LWKeychainManager instance].login;

    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
//        [self.view addSubview:self.iPadPortraitView];
//        [self.view addSubview:self.iPadLandscapeView];
////        self.view.translatesAutoresizingMaskIntoConstraints=NO;
//        
//        NSLayoutConstraint *width1=[NSLayoutConstraint constraintWithItem:self.iPadPortraitView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
//
//        NSLayoutConstraint *height1=[NSLayoutConstraint constraintWithItem:self.iPadPortraitView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
//
//        NSLayoutConstraint *width2=[NSLayoutConstraint constraintWithItem:self.iPadLandscapeView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
//        
//        NSLayoutConstraint *height2=[NSLayoutConstraint constraintWithItem:self.iPadLandscapeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
//        
//        NSLayoutConstraint *centerY=[NSLayoutConstraint constraintWithItem:self.iPadPortraitView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
//        
//        
//        NSLayoutConstraint *centerX=[NSLayoutConstraint constraintWithItem:self.iPadPortraitView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
//
//        
//        
//
//        [self.view addConstraints:@[width1, width2, height1, height2, centerX, centerY]];
//        
//        self.iPadPortraitView.frame=self.view.bounds;
//        self.iPadLandscapeView.frame=self.view.bounds;
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        {
            self.iPadPortraitView.hidden=NO;
            self.iPadLandscapeView.hidden=YES;
            
        }
        else
        {
            self.iPadPortraitView.hidden=YES;
            self.iPadLandscapeView.hidden=NO;
            

        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)buyLykkePressed:(id)sender
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
    LWMyLykkeBuyPresenter *presenter=[[LWMyLykkeBuyPresenter alloc] init];
    [self.navigationController pushViewController:presenter animated:YES];
    }
    else
    {
        LWMyLykkeIpadController *presenter=[LWMyLykkeIpadController new];
        [self.navigationController pushViewController:presenter animated:YES];
                                            
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRect frame=self.iPadPortraitView.frame;

    if(infoLoaded==NO)
        [self setLoading:YES];
    infoLoaded=YES;
    timer=[NSTimer timerWithTimeInterval:5 target:self selector:@selector(loadMyLykkeInfo) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [self loadMyLykkeInfo];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:246.0/255 green:247.0/255 blue:248.0/255 alpha:1]];
    else
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];

    self.title=@"MY LYKKE";
    
    if(descriptionLoaded==NO)
        [[LWAuthManager instance] requestAssetDescription:@"LKK"];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [timer invalidate];
}


-(void) loadMyLykkeInfo
{
    [[LWAuthManager instance] requestMyLykkeInfo];

//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"hh:mm a"];
//    self.currentTimeLabel.text=[[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@" local time"];

}

-(void) authManager:(LWAuthManager *)manager didGetMyLykkeInfo:(LWPacketMyLykkeInfo *)packet
{
    [self setLoading:NO];
    self.balance.text=[LWUtils formatVolumeNumber:packet.lkkBalance currencySign:@"" accuracy:0 removeExtraZeroes:NO];
    self.balance.text=[self.balance.text stringByReplacingOccurrencesOfString:@" " withString:@","];
    self.balance2.text=self.balance.text;
    
    
    if(packet.myEquityPercent.doubleValue<0.001)
    {
        self.equity.text=@"<0.001%";
    }
    else
    {
        self.equity.text=[[LWUtils formatVolumeNumber:packet.myEquityPercent currencySign:@"" accuracy:3 removeExtraZeroes:YES] stringByAppendingString:@"%"];
    }
    self.equity2.text=self.equity.text;
    
    self.numberOfShares.text=[LWUtils formatVolumeNumber:packet.numberOfShares currencySign:@"" accuracy:2 removeExtraZeroes:YES];
    self.numberOfShares.text=[self.numberOfShares.text stringByReplacingOccurrencesOfString:@" " withString:@","];
    
    self.numberOfShares2.text=self.numberOfShares.text;

    self.marketValue.text=[LWUtils formatVolumeNumber:packet.marketValue currencySign:@"$" accuracy:[LWCache accuracyForAssetId:@"USD"] removeExtraZeroes:YES];
    self.marketValue.text=[self.marketValue.text stringByReplacingOccurrencesOfString:@" " withString:@","];
    
    self.marketValue2.text=self.marketValue.text;
    
}


-(void) authManager:(LWAuthManager *)manager didGetAssetDescription:(LWAssetDescriptionModel *)assetDescription
{
    [self setLoading:NO];
    self.assetClassLabel.text=assetDescription.assetClass;
    self.assetDescriptionLabel.text=assetDescription.details;
    self.issuerNameLabel.text=assetDescription.issuerName;

    self.assetClassLabel2.text=assetDescription.assetClass;
    self.assetDescriptionLabel2.text=assetDescription.details;
    self.issuerNameLabel2.text=assetDescription.issuerName;

    descriptionLoaded=YES;
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
   
}

-(NSString *) nibName
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        return @"LWMyLykkePresenter_iPad";
    }
    else
    {
    if([UIScreen mainScreen].bounds.size.width==320)
        return @"LWMyLykkePresenter_Iphone5";
    else
        return @"LWMyLykkePresenter";
    }
}

-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if(UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        self.iPadPortraitView.hidden=NO;
        self.iPadLandscapeView.hidden=YES;
    }
    else
    {
        self.iPadPortraitView.hidden=YES;
        self.iPadLandscapeView.hidden=NO;

    }
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
