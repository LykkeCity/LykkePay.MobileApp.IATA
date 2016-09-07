//
//  LWKYCInvalidDocumentsPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWResultPresenter.h"
#import "LWRegisterCameraPresenter.h"
#import "LWRegistrationData.h"
#import "LWPersonalDataModel.h"
#import "LWKeychainManager.h"
#import "UIViewController+Loading.h"
#import "TKButton.h"
#import "LWConstants.h"
#import "LWValidator.h"
#import "LWKYCManager.h"
#import "LWCommonButton.h"


@interface LWResultPresenter () {
    
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel  *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel  *textLabel;
@property (weak, nonatomic) IBOutlet LWCommonButton *okButton;


#pragma mark - Actions

- (IBAction)okButtonClick:(id)sender;

@end


@implementation LWResultPresenter


#pragma mark - LWAuthStepPresenter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

    self.okButton.type=BUTTON_TYPE_COLORED;
    
    if(!_buttonTitle)
    [self.okButton setTitle:@"RETURN TO WALLET"
                   forState:UIControlStateNormal];
    else
        [self.okButton setTitle:_buttonTitle
                       forState:UIControlStateNormal];
    self.okButton.enabled=YES;
    
    _headerLabel.text=_titleString;
    _textLabel.text=_textString;
    _imageView.image=_image;
}



-(void) setTitleString:(NSString *)titleString
{
    _titleString=titleString;
    _headerLabel.text=titleString;
}

-(void) setTextString:(NSString *)textString
{
    _textString=textString;
    _textLabel.text=textString;
}

-(void) setImage:(UIImage *)image
{
    _image=image;
    _imageView.image=image;
}

-(void) setButtonTitle:(NSString *)buttonTitle
{
    _buttonTitle=buttonTitle;
    [self.okButton setTitle:buttonTitle forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)okButtonClick:(id)sender {
    if([self.delegate respondsToSelector:@selector(resultPresenterWillDismiss)])
        [self.delegate resultPresenterWillDismiss];

    [self dismissViewControllerAnimated:YES completion:^{     //Testing
        if([self.delegate respondsToSelector:@selector(resultPresenterDismissed)])
            [self.delegate resultPresenterDismissed];
        
    }];
    
}



@end
