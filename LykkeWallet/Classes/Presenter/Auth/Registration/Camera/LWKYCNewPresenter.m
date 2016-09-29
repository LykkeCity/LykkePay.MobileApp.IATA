//
//  LWKYCPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWKYCNewPresenter.h"
#import "LWKYCCameraTopBarView.h"
#import "LWCommonButton.h"
#import "LWKYCPhotoContainerView.h"

@interface LWKYCNewPresenter ()

@property (weak, nonatomic) IBOutlet LWKYCCameraTopBarView *topBarView;
@property (weak, nonatomic) IBOutlet LWKYCPhotoContainerView *photoContainerView;
@property (weak, nonatomic) IBOutlet LWCommonButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LWKYCNewPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
