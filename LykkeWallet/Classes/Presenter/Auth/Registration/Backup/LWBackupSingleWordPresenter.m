//
//  LWBackupSingleWordPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupSingleWordPresenter.h"
#import "UIViewController+Navigation.h"
#import "LWBackupCheckWordsPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWCache.h"

@interface LWBackupSingleWordPresenter ()
{
    double lastNextTapTime;
}

@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation LWBackupSingleWordPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    lastNextTapTime=0;
    
    UISwipeGestureRecognizer *gesture=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextTapped)];
    gesture.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:gesture];
    
    gesture=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousTapped)];
    gesture.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:gesture];
    
    self.numberLabel.textColor=[UIColor colorWithRed:178.0/255 green:184.0/255 blue:191.0/255 alpha:1];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:244.0/255 green:246.0/255 blue:247.0/255 alpha:1];

    
    
//    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
//        [self.navigationItem setHidesBackButton:self.currentWordNum==0 animated:NO];
//    else
//    {
        if(self.currentWordNum==0)
            [self setCrossCloseButton];
//    }
    
    NSDictionary *attributes=@{NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14], NSKernAttributeName:@(1.2), NSForegroundColorAttributeName:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1]};

    if(self.currentWordNum>0)
    {
        
        [self setBackButton];
//        UILabel *back=[[UILabel alloc] init];
//        back.attributedText=[[NSAttributedString alloc] initWithString:@"PREVIOUS" attributes:attributes];
//        
//        [back sizeToFit];
//        
//        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:back];
//        
//        UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previousTapped)];
//        [back addGestureRecognizer:gesture];
//        back.userInteractionEnabled=YES;

    }


    

    self.wordLabel.text=self.wordsList[self.currentWordNum];
    self.numberLabel.text=[NSString stringWithFormat:@"%d of %d", self.currentWordNum+1, (int)self.wordsList.count];
    
    UILabel *label=[[UILabel alloc] init];
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextTapped)];
    [label addGestureRecognizer:gesture];
    label.userInteractionEnabled=YES;
    
    label.attributedText=[[NSAttributedString alloc] initWithString:@"NEXT" attributes:attributes];
    
    [label sizeToFit];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:label];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"BACK UP";

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

}

-(void) crossCloseButtonPressed
{
    if([super shouldDismissIpadModalViewController]==NO)
        return;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        UIViewController *firstController=[self.navigationController.viewControllers firstObject];
        if([firstController isKindOfClass:[UITabBarController class]])
            [self.navigationController popToRootViewControllerAnimated:YES];
        else
            [((LWAuthNavigationController *)self.navigationController) setRootMainTabScreen];
        
    }
    else
    {
        [super crossCloseButtonPressed];
    }
    
    
}


-(void) nextTapped
{
    if(CACurrentMediaTime()-lastNextTapTime<0.5)
        return;
    
    [UIView setAnimationsEnabled:YES];
    
    lastNextTapTime=CACurrentMediaTime();
//    if(self.currentWordNum==self.wordsList.count-2)
//        [LWCache instance].userWatchedAllBackupWords=YES;

    
    if(self.currentWordNum==self.wordsList.count-1)
    {
        
        LWBackupCheckWordsPresenter *presenter=[[LWBackupCheckWordsPresenter alloc] init];
        presenter.backupMode=_backupMode;
        presenter.wordsList=self.wordsList;
        [self.navigationController pushViewController:presenter animated:YES];
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.wordLabel.center=CGPointMake(-self.wordLabel.bounds.size.width/2, self.wordLabel.center.y);
        
    } completion:^(BOOL finished){
        if(self.currentWordNum==0)
        {
            
            [self setBackButton];
        }
        

        self.wordLabel.center=CGPointMake(self.view.bounds.size.width+self.wordLabel.bounds.size.width/2, self.wordLabel.center.y);
        self.currentWordNum++;
        self.wordLabel.text=self.wordsList[self.currentWordNum];
        self.numberLabel.text=[NSString stringWithFormat:@"%d of %d", self.currentWordNum+1, (int)self.wordsList.count];

        [UIView animateWithDuration:0.25 animations:^{
            self.wordLabel.center=CGPointMake(self.view.bounds.size.width/2, self.wordLabel.center.y);
        }];
    }];
    
//    if(self.currentWordNum==self.wordsList.count-1)
//    {
//        LWBackupCheckWordsPresenter *presenter=[[LWBackupCheckWordsPresenter alloc] init];
//        presenter.wordsList=self.wordsList;
//        [self.navigationController pushViewController:presenter animated:YES];
//    }
//    else
//    {
//        LWBackupSingleWordPresenter *presenter=[[LWBackupSingleWordPresenter alloc] init];
//        presenter.wordsList=self.wordsList;
//        presenter.currentWordNum=self.currentWordNum+1;
//        [self.navigationController pushViewController:presenter animated:YES];
//
//    }

}

-(void) previousTapped
{
    if(self.currentWordNum==0)
        return;
    
    if(CACurrentMediaTime()-lastNextTapTime<0.5)
        return;
    
    [UIView setAnimationsEnabled:YES];

    lastNextTapTime=CACurrentMediaTime();

    [UIView animateWithDuration:0.25 animations:^{
        self.wordLabel.center=CGPointMake(self.view.bounds.size.width+self.wordLabel.bounds.size.width/2, self.wordLabel.center.y);
   
    } completion:^(BOOL finished){
        if(self.currentWordNum==1)
        {
            self.navigationItem.leftBarButtonItem=nil;
//            if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
                [self setCrossCloseButton];
        }
        self.wordLabel.center=CGPointMake(-self.wordLabel.bounds.size.width/2, self.wordLabel.center.y);

        self.currentWordNum--;
        self.wordLabel.text=self.wordsList[self.currentWordNum];
        self.numberLabel.text=[NSString stringWithFormat:@"%d of %d", self.currentWordNum+1, (int)self.wordsList.count];
        [UIView animateWithDuration:0.25 animations:^{
            self.wordLabel.center=CGPointMake(self.view.bounds.size.width/2, self.wordLabel.center.y);
        }];
    }];

    
//    if(self.currentWordNum!=0)
//        [self.navigationController popViewControllerAnimated:YES];
}


- (void)setBackButton {
    
            UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(previousTapped)];
            self.navigationItem.leftBarButtonItem = button;
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
