//
//  LWLykkeBuyTransferContainer.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWLykkeBuyTransferContainer.h"
#import "LWWalletsTypeButton.h"
#import "LWBuyLykkeInContainerPresenter.h"
#import "LWMyLykkeDepositBTCPresenter.h"

@interface LWLykkeBuyTransferContainer ()
{
    LWBuyLykkeInContainerPresenter *buyPresenter;
    LWMyLykkeDepositBTCPresenter *transferPresenter;
}

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UILabel *buyButtonLabel;
@property (weak, nonatomic) IBOutlet UILabel *transferButtonLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectorLeftConstraint;

@property (weak, nonatomic) IBOutlet UIView *selectorView;


@end

@implementation LWLykkeBuyTransferContainer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.hideKeyboardOnTap=NO;
    
    [_selectorView layoutIfNeeded];
    _selectorView.layer.cornerRadius=_selectorView.bounds.size.height/2;
    
    UITapGestureRecognizer *gest=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchToTransfer)];
    [_transferButtonLabel addGestureRecognizer:gest];
    _transferButtonLabel.userInteractionEnabled=YES;
    
    gest=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchToBuy)];
    [_buyButtonLabel addGestureRecognizer:gest];
    _buyButtonLabel.userInteractionEnabled=YES;
    
    transferPresenter=[LWMyLykkeDepositBTCPresenter new];
    transferPresenter.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    transferPresenter.view.frame=_container.bounds;
    [_container addSubview:transferPresenter.view];
    [transferPresenter.view layoutSubviews];
    [_container layoutIfNeeded];
    [self addChildViewController:transferPresenter];

    
    buyPresenter=[LWBuyLykkeInContainerPresenter new];
    buyPresenter.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    buyPresenter.view.frame=_container.bounds;
    [_container addSubview:buyPresenter.view];
    [self addChildViewController:buyPresenter];
    [buyPresenter didMoveToParentViewController:self];

    _buyButtonLabel.tag=1;

    
    
    NSDictionary *dict=@{NSKernAttributeName:@(1.2), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14]};
    _buyButtonLabel.attributedText=[[NSAttributedString alloc] initWithString:@"BUY" attributes:dict];
    _transferButtonLabel.attributedText=[[NSAttributedString alloc] initWithString:@"TRANSFER" attributes:dict];

    _buyButtonLabel.textColor=[UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setBackButton];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setTitle:@"DEPOSIT LYKKE"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)buyOrTransferPressed:(LWWalletsTypeButton *)sender
{
    if(sender.selected)
        return;
//    _buyButton.selected=NO;
//    _transferButton.selected=NO;
    sender.selected=YES;
    
}

-(void) switchToBuy
{
    if(_buyButtonLabel.tag==1)
        return;
    
    _buyButtonLabel.tag=1;
    _transferButtonLabel.tag=0;
    
    
    buyPresenter.view.center=CGPointMake(self.view.bounds.size.width*-0.5, transferPresenter.view.center.y);
    
    self.view.userInteractionEnabled=NO;
    
    [self transitionFromViewController:transferPresenter toViewController:buyPresenter duration:0.5 options:0 animations:^{
        buyPresenter.view.frame=_container.bounds;
        transferPresenter.view.center=CGPointMake(self.view.bounds.size.width*1.5, transferPresenter.view.center.y);
    } completion:^(BOOL finished){
        [_container bringSubviewToFront:buyPresenter.view];
        transferPresenter.view.frame=_container.bounds;
        [buyPresenter didMoveToParentViewController:self];
        self.view.userInteractionEnabled=YES;
        
    }];
    
    _buyButtonLabel.alpha=0;
    _transferButtonLabel.alpha=0;
    
    _selectorLeftConstraint.constant=-20;
    
    [UIView animateWithDuration:0.3 animations:^{
        _buyButtonLabel.alpha=1;
        _transferButtonLabel.alpha=1;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished){
        _selectorLeftConstraint.constant=0;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        
    }];
    
    _transferButtonLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    _buyButtonLabel.textColor=[UIColor whiteColor];
    
}

-(void) switchToTransfer
{
    
    if(_transferButtonLabel.tag==1)
        return;
    _buyButtonLabel.tag=0;
    _transferButtonLabel.tag=1;
    
    
    transferPresenter.view.center=CGPointMake(self.view.bounds.size.width*1.5, transferPresenter.view.center.y);
    
    self.view.userInteractionEnabled=NO;
    
    [self transitionFromViewController:buyPresenter toViewController:transferPresenter duration:0.5 options:0 animations:^{
        transferPresenter.view.frame=_container.bounds;
        buyPresenter.view.center=CGPointMake(self.view.bounds.size.width*-0.5, buyPresenter.view.center.y);
    } completion:^(BOOL finished){
        [_container bringSubviewToFront:transferPresenter.view];
        buyPresenter.view.frame=_container.bounds;
        [transferPresenter didMoveToParentViewController:self];
        self.view.userInteractionEnabled=YES;
        
    }];
    
    _buyButtonLabel.alpha=0;
    _transferButtonLabel.alpha=0;
    
    _selectorLeftConstraint.constant=114+20;
    
    [UIView animateWithDuration:0.3 animations:^{
        _buyButtonLabel.alpha=1;
        _transferButtonLabel.alpha=1;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished){
        _selectorLeftConstraint.constant=114;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        
    }];
    
    _buyButtonLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    _transferButtonLabel.textColor=[UIColor whiteColor];

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
