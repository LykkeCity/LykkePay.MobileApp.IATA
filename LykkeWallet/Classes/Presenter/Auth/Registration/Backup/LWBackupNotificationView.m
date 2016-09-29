//
//  LWBackupNotificationView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupNotificationView.h"
#import "LWPrivateKeyManager.h"
#import "LWMigrationInfoPresenter.h"
#import "LWBackupNavigationController.h"
#import "LWBackupGetStartedPresenter.h"
#import "LWIPadModalNavigationControllerViewController.h"
#import "LWAuthManager.h"

@interface LWBackupNotificationView()
{
    UIWindow *window;
    BackupRequestType currentType;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *moreOptionsContainer;
@property (weak, nonatomic) IBOutlet UIButton *moreOptionsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *textLaebl;
@property (weak, nonatomic) IBOutlet UIButton *laterButton;


@end

@implementation LWBackupNotificationView

-(void) awakeFromNib
{
    [super awakeFromNib];
    self.alpha=0;
    
    self.titleLabel.textColor=[UIColor colorWithRed:31.0/255 green:149.0/255 blue:1 alpha:1];
//    UIColor *textColor=[UIColor colorWithRed:140.0/255 green:148.0/255 blue:160.0/255 alpha:1];
//    self.textLabel.textColor=textColor;
    
    _moreOptionsContainer.clipsToBounds=YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    if([UIScreen mainScreen].bounds.size.width==320)
        _widthConstraint.constant=280;
    if([[LWPrivateKeyManager shared] privateKeyWords]==nil)
    {
        _moreOptionsContainer.hidden=YES;
        _textBottomConstraint.constant=37;
    }
    
    if(_text)
        _textLaebl.text=_text;

}

-(void) setText:(NSString *)text
{
    _text=text;
    _textLaebl.text=_text;
}

-(void) setType:(BackupRequestType)type
{
    currentType=type;
    if(currentType==BackupRequestTypeRequired)
    {
        _titleLabel.text=@"BACKUP REQUIRED!";
        [_laterButton setTitle:@"CANCEL" forState:UIControlStateNormal];
    }
    
}

-(BackupRequestType) type
{
    return currentType;
}


-(void) show
{
    CGRect frame;
//    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        frame=[UIScreen mainScreen].bounds;
//    else
//        frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    window = [[UIWindow alloc] initWithFrame:frame];
    window.backgroundColor = nil;
    window.windowLevel = UIWindowLevelNormal;
//    window.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [window addSubview:self];
    self.frame=window.bounds;
    self.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [window makeKeyAndVisible];
    
    self.backgroundColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.5];
    self.opaque=NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha=1;
    }];

}

-(IBAction)backupPressed:(id)sender
{
    [self removeFromSuperview];

    LWBackupNavigationController *navController=[LWBackupNavigationController new];
    navController.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    navController.view.frame=window.bounds;
//    [window addSubview:navController.view];
    [window setRootViewController:navController];
    
    if([[LWPrivateKeyManager shared] privateKeyWords]==nil)
    {
        LWMigrationInfoPresenter *ppp=[LWMigrationInfoPresenter new];
        [navController pushViewController:ppp animated:YES];
    }
    else
    {
        
        LWBackupGetStartedPresenter *presenter=[[LWBackupGetStartedPresenter alloc] init];
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
            [navController pushViewController:presenter animated:YES];
        
        else
        {
            LWIPadModalNavigationControllerViewController *navigationController=[[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
            navigationController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            navigationController.transitioningDelegate=navigationController;
            [navController presentViewController:navigationController animated:YES completion:nil];
        }
    }

}

-(IBAction)laterPressed:(id)sender
{
    [self hide];
}

-(IBAction)moreOptionsPressed:(id)sender
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.adjustsImageWhenHighlighted=NO;
    [button setTitle:@"I already made a backup" forState:UIControlStateNormal];
    button.frame=_moreOptionsContainer.bounds;
//    button.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [button setTitleColor:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1] forState:UIControlStateNormal];
    button.titleLabel.font=_moreOptionsButton.titleLabel.font;
    [button addTarget:self action:@selector(alreadyMadeBackupPressed) forControlEvents:UIControlEventTouchUpInside];
    button.center=CGPointMake(_moreOptionsContainer.bounds.size.width/2, _moreOptionsContainer.bounds.size.height*1.5);
    [_moreOptionsContainer addSubview:button];
    button.translatesAutoresizingMaskIntoConstraints=YES;
    
    [self layoutSubviews];
    self.moreOptionsButton.translatesAutoresizingMaskIntoConstraints=YES;
    _moreOptionsContainer.translatesAutoresizingMaskIntoConstraints=YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        _moreOptionsButton.center=CGPointMake(_moreOptionsContainer.bounds.size.width/2, -_moreOptionsContainer.bounds.size.height/2);
        button.center=CGPointMake(_moreOptionsContainer.bounds.size.width/2, _moreOptionsContainer.bounds.size.height/2);
    } completion:^(BOOL finished){
        _moreOptionsButton.hidden=YES;
//        self.translatesAutoresizingMaskIntoConstraints=YES;

    }];
}

-(void) alreadyMadeBackupPressed
{
    [[LWAuthManager instance] requestSaveBackupState];
    [self hide];
}

-(void) hide
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha=0;
    } completion:^(BOOL finished){
        
        [self removeFromSuperview];
        window=nil;
    }];
    
}

-(void) orientationChanged
{
    window.frame=[UIScreen mainScreen].bounds;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
