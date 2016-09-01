//
//  LWGenerateKeyPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWGenerateKeyPresenter.h"
#import "LWAnimatedView.h"
#import "LWBackupIntroPresenter.h"


@interface LWGenerateKeyPresenter ()
{
    LWAnimatedView *animationView;
    int shakeCount;
    
    BOOL isShakingNow;
}

@property (weak, nonatomic) IBOutlet UIView *animationContainer;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation LWGenerateKeyPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    isShakingNow=NO;
    [UIApplication sharedApplication].applicationSupportsShakeToEdit=YES;
    animationView=[[LWAnimatedView alloc] initWithFrame:self.animationContainer.bounds name:@"crypto_bar"];
    [self.animationContainer addSubview:animationView];
    shakeCount=0;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        self.textLabel.text=@"Shake your iPhone to generate a private key to your Lykke Wallet";
    else
        self.textLabel.text=@"Shake your iPad to generate a private key to your Lykke Wallet";

    
//    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(testing)]; //Testing
//    [self.view addGestureRecognizer:gesture];
}

//-(void) dismiss
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake )
    {
        isShakingNow=YES;
        // User was shaking the device.
        shakeCount++;
        if(shakeCount==1)
        {
            [self performSelectorInBackground:@selector(checkShakingState) withObject:nil];
        }
        [animationView animateUntilFrame:shakeCount*40];

    }

}

-(void) testing //Testing
{
    isShakingNow=YES;
    // User was shaking the device.
    shakeCount++;
    if(shakeCount==1)
    {
        [self performSelectorInBackground:@selector(checkShakingState) withObject:nil];
    }
    [animationView animateUntilFrame:shakeCount*40];

}

-(void) checkShakingState
{
    while (shakeCount<3) {
        [NSThread sleepForTimeInterval:0.66];
        if(isShakingNow)
        {
            shakeCount++;
            dispatch_async(dispatch_get_main_queue(), ^{
                [animationView animateUntilFrame:shakeCount*40];
            
            });
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LWBackupIntroPresenter *presenter=[[LWBackupIntroPresenter alloc] init];
        [self.navigationController pushViewController:presenter animated:YES];
    });
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake )
    {
        isShakingNow=NO;
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

@end
