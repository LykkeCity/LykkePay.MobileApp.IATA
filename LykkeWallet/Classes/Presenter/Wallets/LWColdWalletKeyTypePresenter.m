//
//  LWColdWalletKeyTypePresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 02/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWColdWalletKeyTypePresenter.h"

@interface LWColdWalletKeyTypePresenter ()
{
    BOOL flag256;
}

@property (weak, nonatomic) IBOutlet UIImageView *checkmark1;
@property (weak, nonatomic) IBOutlet UIImageView *checkmark2;

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;

@end

@implementation LWColdWalletKeyTypePresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    if(flag256)
        _checkmark2.hidden=NO;
    else
        _checkmark1.hidden=NO;
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPressed:)];
    [_view1 addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPressed:)];
    [_view2 addGestureRecognizer:gesture];
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
    self.title=@"PRIVATE KEY";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewPressed:(UITapGestureRecognizer *) gesture
{
    _checkmark1.hidden=YES;
    _checkmark2.hidden=YES;
    if(gesture.view==_view1)
        _checkmark1.hidden=NO;
    else
        _checkmark2.hidden=NO;
    flag256=_checkmark1.hidden;
}

-(void) setIs256Bit:(BOOL)is256Bit
{
    flag256=is256Bit;
}

-(BOOL) is256Bit
{
    return flag256;
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
