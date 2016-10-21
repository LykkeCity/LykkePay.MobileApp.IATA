//
//  LWExchangeIPadContainerViewController.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeIPadContainerViewController.h"
#import "LWExchangePresenter.h"
#import "LWExchangeTabContainer.h"

@interface LWExchangeIPadContainerViewController () <LWExchangePresenterDelegate>
{
    LWExchangePresenter *exchangePresenter;
    LWExchangeTabContainer *tabContainer;
    NSDictionary *titleAttributes;
}

@property (weak,nonatomic) IBOutlet UIView *leftContainer;
@property (weak, nonatomic) IBOutlet UIView *rightContainer;
@property (weak, nonatomic) IBOutlet UILabel *leftTitle;
@property (weak, nonatomic) IBOutlet UILabel *rightTitle;

@end

@implementation LWExchangeIPadContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _leftContainer.clipsToBounds=YES;
    _rightContainer.clipsToBounds=YES;
    
    exchangePresenter=[LWExchangePresenter new];
    exchangePresenter.delegate=self;
    exchangePresenter.view.frame=_leftContainer.bounds;
    exchangePresenter.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_leftContainer insertSubview:exchangePresenter.view atIndex:0];
    [self addChildViewController:exchangePresenter];
    
    titleAttributes=@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]};
    _leftTitle.attributedText=[[NSAttributedString alloc] initWithString:@"EXCHANGE" attributes:titleAttributes];
    
    _rightTitle.attributedText=[[NSAttributedString alloc] initWithString:@"" attributes:titleAttributes];
    
    // Do any additional setup after loading the view from its nib.
}


-(void) exchangePresenterChosenPair:(LWAssetPairModel *)pair tabToShow:(TAB_TO_SHOW)tabToShow
{
    [tabContainer removeFromParentViewController];
    [tabContainer.view removeFromSuperview];
    
    tabContainer=[LWExchangeTabContainer new];
    tabContainer.assetPair=pair;
    tabContainer.tabToShow=tabToShow;
    tabContainer.view.frame=_rightContainer.bounds;
    [_rightContainer addSubview:tabContainer.view];
    [self addChildViewController:tabContainer];
    
    NSString *name=pair.name;
    if(pair.inverted)
    {
        NSArray *arr=[name componentsSeparatedByString:@"/"];
        if(arr.count==2)
            name=[NSString stringWithFormat:@"%@/%@", arr[1], arr[0]];
    }
    _rightTitle.attributedText=[[NSAttributedString alloc] initWithString:name attributes:titleAttributes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
//    [self setWantsFullScreenLayout:YES];
    
//    [self.navigationController.view setNeedsLayout];
    if(!tabContainer)
        self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height+64);
//    [self.view layoutIfNeeded];
//    [self.navigationController layoutSubviews];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.navigationController.view setNeedsLayout];

//    self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-44, self.view.bounds.size.width, self.view.bounds.size.height+44);
//    [self.view setNeedsLayout];
//    [self.navigationController setNavigationBarHidden:YES];
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
