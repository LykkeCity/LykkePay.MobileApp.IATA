//
//  LWMyLykkeMainContainerPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeMainContainerPresenter.h"
#import "LWMyLykkePresenter.h"
#import "LWMyLykkeNewsListPresenter.h"
#import "LWKeychainManager.h"

@interface LWMyLykkeMainContainerPresenter () <LWMyLykkeNewsListDelegate>
{
    LWMyLykkePresenter *myLykkePresenter;
    LWMyLykkeNewsListPresenter *myLykkeNewsPresenter;
    
    CGFloat topViewHeightOrigin;
    
    CGFloat avatarHeightOrigin;
    
    CGFloat topViewMinHeight;
}

@property (weak, nonatomic) IBOutlet UIView *bottomContainer;
@property (weak, nonatomic) IBOutlet UIView *newsButtonView;
@property (weak, nonatomic) IBOutlet UIView *equityButtonView;
@property (weak, nonatomic) IBOutlet UIView *equityNewsHighlightView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) IBOutlet UIImageView *newsButtonIcon;
@property (weak, nonatomic) IBOutlet UIImageView *equityButtonIcon;
@property (weak, nonatomic) IBOutlet UILabel *newsButtonLabel;
@property (weak, nonatomic) IBOutlet UILabel *equityButtonLabel;

@property (weak, nonatomic) IBOutlet UIView *nameAndEmailContainer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topGrayViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *equityNewsHighlightViewLeftConstraint;


@end

@implementation LWMyLykkeMainContainerPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nameLabel.text=[[LWKeychainManager instance] fullName];
    _emailLabel.text=[[LWKeychainManager instance] login];
    // Do any additional setup after loading the view from its nib.
    
    myLykkeNewsPresenter=[LWMyLykkeNewsListPresenter new];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        myLykkeNewsPresenter.delegate=self;
    myLykkeNewsPresenter.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.bottomContainer addSubview:myLykkeNewsPresenter.view];
    myLykkeNewsPresenter.view.frame=_bottomContainer.bounds;
    [self addChildViewController:myLykkeNewsPresenter];
    
    myLykkePresenter=[LWMyLykkePresenter new];
    myLykkePresenter.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    myLykkePresenter.view.frame=_bottomContainer.bounds;
    [self.bottomContainer addSubview:myLykkePresenter.view];
    [self addChildViewController:myLykkePresenter];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newsButtonPressed)];
    [_newsButtonView addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(equityButtonPressed)];
    [_equityButtonView addGestureRecognizer:gesture];
    
    
    _equityButtonLabel.textColor=[UIColor whiteColor];
    _newsButtonLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];

    topViewHeightOrigin=self.topViewHeightConstraint.constant;
    
    avatarHeightOrigin=_avatarContainerHeightConstraint.constant;
    
    topViewMinHeight=50;
    _equityButtonView.tag=1;
    
    [_equityNewsHighlightView layoutIfNeeded];
    _equityNewsHighlightView.layer.cornerRadius=_equityNewsHighlightView.bounds.size.height/2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
            [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:246.0/255 green:247.0/255 blue:248.0/255 alpha:1]];
        else
            [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    self.title=@"MY LYKKE";

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:246.0/255 green:247.0/255 blue:248.0/255 alpha:1]];
    else
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];


}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
}


-(void)newsButtonPressed
{
    if(_newsButtonView.tag==1)
        return;
    _newsButtonView.tag=1;
    _equityButtonView.tag=0;
//    [self addChildViewController:myLykkeNewsPresenter];

    myLykkeNewsPresenter.view.center=CGPointMake(self.view.bounds.size.width*1.5, myLykkeNewsPresenter.view.center.y);

    self.view.userInteractionEnabled=NO;

    [self transitionFromViewController:myLykkePresenter toViewController:myLykkeNewsPresenter duration:0.5 options:0 animations:^{
        myLykkeNewsPresenter.view.frame=_bottomContainer.bounds;
        myLykkePresenter.view.center=CGPointMake(self.view.bounds.size.width*-0.5, myLykkePresenter.view.center.y);
        
        

    } completion:^(BOOL finished){
//        [myLykkePresenter willMoveToParentViewController:nil];
//        [myLykkePresenter removeFromParentViewController];

        [_bottomContainer bringSubviewToFront:myLykkeNewsPresenter.view];
        myLykkePresenter.view.frame=_bottomContainer.bounds;
//        [myLykkePresenter removeFromParentViewController];
        [myLykkeNewsPresenter didMoveToParentViewController:self];

        self.view.userInteractionEnabled=YES;

    }];
    
    _equityButtonView.alpha=0;
    _newsButtonView.alpha=0;

    _equityNewsHighlightViewLeftConstraint.constant=_newsButtonView.frame.origin.x+20;

    [UIView animateWithDuration:0.3 animations:^{
        _equityButtonView.alpha=1;
        _newsButtonView.alpha=1;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished){
        _equityNewsHighlightViewLeftConstraint.constant=_newsButtonView.frame.origin.x;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];

    }];
    

    _equityButtonIcon.image=[UIImage imageNamed:@"EquityIconBlack"];
    _newsButtonIcon.image=[UIImage imageNamed:@"NewsIconWhite"];
    _equityButtonLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    _newsButtonLabel.textColor=[UIColor whiteColor];

}

-(void) equityButtonPressed
{
    if(_equityButtonView.tag==1)
        return;
    _newsButtonView.tag=0;
    _equityButtonView.tag=1;

    [myLykkeNewsPresenter.tableView setContentOffset:myLykkeNewsPresenter.tableView.contentOffset animated:NO];
    
    
//    [self addChildViewController:myLykkePresenter];
    
    myLykkePresenter.view.center=CGPointMake(self.view.bounds.size.width*-0.5, myLykkePresenter.view.center.y);

    _equityButtonView.alpha=0;
    _newsButtonView.alpha=0;
    _equityNewsHighlightViewLeftConstraint.constant=_equityButtonView.frame.origin.x-20;
    _topViewHeightConstraint.constant=topViewHeightOrigin;
    
    [self adjustTopViewSubviews];

    self.view.userInteractionEnabled=NO;
    [self transitionFromViewController:myLykkeNewsPresenter toViewController:myLykkePresenter duration:0.5 options:0 animations:^{
        myLykkeNewsPresenter.view.center=CGPointMake(self.view.bounds.size.width*1.5, myLykkeNewsPresenter.view.center.y);
//        myLykkePresenter.view.center=CGPointMake(self.view.bounds.size.width/2, myLykkePresenter.view.center.y);
        myLykkePresenter.view.frame=_bottomContainer.bounds;
        
    } completion:^(BOOL finished){
        
//        [myLykkeNewsPresenter willMoveToParentViewController:nil];
//        [myLykkeNewsPresenter removeFromParentViewController];

        [_bottomContainer bringSubviewToFront:myLykkePresenter.view];
        myLykkeNewsPresenter.view.frame=_bottomContainer.bounds;
//        [myLykkeNewsPresenter removeFromParentViewController];
        [myLykkePresenter didMoveToParentViewController:self];
        [self.view layoutSubviews];
        
        self.view.userInteractionEnabled=YES;

    }];

    
    [UIView animateWithDuration:0.3 animations:^{

        _equityButtonView.alpha=1;
        _newsButtonView.alpha=1;
        [self.view layoutIfNeeded];

    } completion:^(BOOL finished){
        _equityNewsHighlightViewLeftConstraint.constant=_equityButtonView.frame.origin.x;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished){
            [myLykkeNewsPresenter.view layoutSubviews];
            myLykkeNewsPresenter.tableView.contentOffset=CGPointMake(0, 0);
        }];
    }];

    
    _equityButtonIcon.image=[UIImage imageNamed:@"EquityIcon"];
    _newsButtonIcon.image=[UIImage imageNamed:@"NewsIcon"];
    _equityButtonLabel.textColor=[UIColor whiteColor];
    _newsButtonLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];

    
}


-(void) listScrolled:(UIScrollView *) scrollView
{
    if(_topViewHeightConstraint.constant>topViewMinHeight && scrollView.contentOffset.y>0)
    {
        _topViewHeightConstraint.constant=_topViewHeightConstraint.constant-scrollView.contentOffset.y;
        if(_topViewHeightConstraint.constant<topViewMinHeight)
        {
            scrollView.contentOffset=CGPointMake(0, topViewMinHeight-_topViewHeightConstraint.constant);
            _topViewHeightConstraint.constant=topViewMinHeight;
            
        }
        else
            scrollView.contentOffset=CGPointMake(0, 0);
    }
    else if(_topViewHeightConstraint.constant<topViewHeightOrigin && scrollView.contentOffset.y<0)
    {
        _topViewHeightConstraint.constant=_topViewHeightConstraint.constant-scrollView.contentOffset.y;
        if(_topViewHeightConstraint.constant>topViewHeightOrigin)
        {
            _topViewHeightConstraint.constant=topViewHeightOrigin;
            
        }
        
        scrollView.contentOffset=CGPointMake(0, 0);

    }
    
    [self adjustTopViewSubviews];
    
    
//        _topViewHeightConstraint.constant=80;
}

-(void) adjustTopViewSubviews
{
    CGFloat coeff=(_topViewHeightConstraint.constant-topViewMinHeight)/(topViewHeightOrigin-topViewMinHeight);
    _avatarContainerHeightConstraint.constant=avatarHeightOrigin*coeff;
    
    _topGrayViewHeightConstraint.constant=_avatarContainerHeightConstraint.constant/2+0.5;
    _nameAndEmailContainer.alpha=coeff;
 
}

-(NSString *) nibName
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        return @"LWMyLykkeMainContainerPresenter_iPad";
    }
    else
    {
        if([UIScreen mainScreen].bounds.size.width==320)
            return @"LWMyLykkeMainContainerPresenter_Iphone5";
        else
            return @"LWMyLykkeMainContainerPresenter";
    }
}


@end
