//
//  LWEmptyHistoryPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWEmptyHistoryPresenter.h"

#import "LWValidator.h"
#import "LWRefreshControlView.h"

@interface LWEmptyHistoryPresenter ()


@property (weak, nonatomic) IBOutlet UIImageView *bottomCurveView;


@end

@implementation LWEmptyHistoryPresenter

-(id) init
{
    self=[super init];
    self.flagColoredButton=NO;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if(self.flagColoredButton)
        [LWValidator setButton:self.button enabled:YES];
    else
        [LWValidator setButtonWithClearBackground:self.button enabled:YES];
    
    NSDictionary *attributesNotColored=@{NSKernAttributeName:@(1), NSForegroundColorAttributeName: [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Semibold" size:15]};
    
    NSDictionary *attributesColored=@{NSKernAttributeName:@(1), NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Semibold" size:15]};

    
    
    [self.button setAttributedTitle:[[NSAttributedString alloc] initWithString:self.buttonText attributes:self.flagColoredButton?attributesColored:attributesNotColored] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if(self.depositAction==nil)
        self.button.hidden=YES;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        self.bottomCurveView.hidden=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) viewDidLayoutSubviews
{
    self.button.layer.cornerRadius=self.button.bounds.size.height/2;
}

-(void)buttonPressed
{
    self.depositAction();
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
