//
//  LWRefundAddressView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/06/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRefundAddressView.h"
#import "LWValidator.h"
#import "Macro.h"
#import "LWCache.h"
#import "UIView+Toast.h"
#import "LWChoosePrivateWalletView.h"
#import "LWPrivateWalletModel.h"
#import "LWPrivateWalletsManager.h"

@interface LWRefundAddressView() <UITextFieldDelegate>
{
    UITextField *textField;
    UIButton *clearPasteButton;
    UIButton *scanQRCodeButton;
    UIButton *selectWalletButton;
    UIButton *applyButton;
    UILabel *addressLabel;
    UIButton *textFieldButton;
    
    BOOL flagIsOpened;
}

@end

@implementation LWRefundAddressView

-(id) init
{
    self=[super init];
    flagIsOpened=NO;
    [self createTextField];
    clearPasteButton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    scanQRCodeButton=[self createQRCodeButton];
    selectWalletButton=[self createSelectWalletButton];
    applyButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [applyButton addTarget:self action:@selector(applyPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:applyButton];
    NSDictionary *attributes = @{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]};
    [applyButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"APPLY" attributes:attributes] forState:UIControlStateNormal];
    applyButton.frame=CGRectMake(0, 0, 100, 45);
    [LWValidator setButtonWithClearBackground:applyButton enabled:YES];
    
    addressLabel=[[UILabel alloc] init];
    addressLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    addressLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    addressLabel.backgroundColor=nil;
    addressLabel.opaque=NO;
    addressLabel.text=[LWCache instance].refundAddress;
    [self addSubview:addressLabel];
    
    return self;
}

-(void) setAddress:(NSString *)address
{
    _address=address;
    addressLabel.text=_address;
    textField.text=_address;
    
    if(textField.text.length)
    {
        [textFieldButton setTitle:@"Clear" forState:UIControlStateNormal];
    }
    else
    {
        flagIsOpened=YES;
        [textFieldButton setTitle:@"Paste" forState:UIControlStateNormal];
    }

}



-(UIButton *) createQRCodeButton
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(qrCodeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    UILabel *label=[[UILabel alloc] init];
    label.text=Localize(@"withdraw.funds.scan");
    label.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    label.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    [label sizeToFit];
    [button addSubview:label];
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    imageView.image=[UIImage imageNamed:@"QrCodeIcon"];
    [button addSubview:imageView];
    
    button.frame=CGRectMake(0, 0, label.bounds.size.width+7+imageView.bounds.size.width, 22);
    label.center=CGPointMake(button.bounds.size.width-label.bounds.size.width/2, button.bounds.size.height/2);
    
    imageView.center=CGPointMake(imageView.bounds.size.width/2, button.bounds.size.height/2);
    
    
    return button;
}

-(UIButton *) createSelectWalletButton
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(selectWalletButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    UILabel *label=[[UILabel alloc] init];
    label.text=@"Select wallet";
    label.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    label.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    [label sizeToFit];
    [button addSubview:label];
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    imageView.image=[UIImage imageNamed:@"SelectWallet"];
    [button addSubview:imageView];
    
    button.frame=CGRectMake(0, 0, label.bounds.size.width+7+imageView.bounds.size.width, 22);
    label.center=CGPointMake(button.bounds.size.width-label.bounds.size.width/2, button.bounds.size.height/2);
    
    imageView.center=CGPointMake(imageView.bounds.size.width/2, button.bounds.size.height/2);
    
    
    return button;

}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    addressLabel.frame=CGRectMake(30, 0, frame.size.width-60, 50);
    textField.frame=CGRectMake(30, 25, frame.size.width-60, 45);
    
    CGFloat bW=scanQRCodeButton.bounds.size.width+selectWalletButton.bounds.size.width+20;
    
    scanQRCodeButton.center=CGPointMake(frame.size.width/2-bW/2+scanQRCodeButton.bounds.size.width/2, 87+scanQRCodeButton.bounds.size.height/2);
    selectWalletButton.center=CGPointMake(frame.size.width/2+bW/2-selectWalletButton.bounds.size.width/2, 87+selectWalletButton.bounds.size.height/2);

    applyButton.frame=CGRectMake(30, 123, frame.size.width-60, 45);
    if(flagIsOpened==NO)
    {
        addressLabel.hidden=NO;
        textField.hidden=YES;
    }
    else
    {
        addressLabel.hidden=YES;
        textField.hidden=NO;
    }
}

-(void) qrCodeButtonPressed
{
    [self.delegate addressViewScanQRCode:self];
}

-(void) selectWalletButtonPressed
{
    [self endEditing:YES];
            [LWChoosePrivateWalletView showWithCurrentWallet:nil completion:^(LWPrivateWalletModel *wallet){
                textField.text=wallet.address;
                [textFieldButton setTitle:@"Clear" forState:UIControlStateNormal];
            }];
}

-(void) createTextField
{
    textField=[[UITextField alloc] init];
    textField.placeholder=@"New address";
    textField.backgroundColor=[UIColor colorWithRed:232.0/255 green:233.0/255 blue:234.0/255 alpha:1];
    textField.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    textField.delegate=self;
    textField.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    textField.leftView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    
    textFieldButton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    [textFieldButton addTarget:self action:@selector(textfieldButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [textFieldButton setTitle:@"Paste" forState:UIControlStateNormal];
    textFieldButton.titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    [textFieldButton setTitleColor:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.5] forState:UIControlStateNormal];
    [textFieldButton sizeToFit];
    textField.rightView=textFieldButton;
    textField.leftViewMode=UITextFieldViewModeAlways;
    textField.rightViewMode=UITextFieldViewModeAlways;
    
    textFieldButton.frame=CGRectMake(0, 0, textFieldButton.bounds.size.width+20, 30);
    
    [self addSubview:textField];
    
}

-(BOOL) textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str=[textField.text stringByReplacingCharactersInRange:range withString:string];
    if(str.length)
    {
        [textFieldButton setTitle:@"Clear" forState:UIControlStateNormal];
    }
    else
        [textFieldButton setTitle:@"Paste" forState:UIControlStateNormal];
    
    
    
    return YES;
}

-(void) setIsOpened:(BOOL)isOpened
{
    flagIsOpened=isOpened;
    self.frame=self.frame;
    
}

-(BOOL) isOpened
{
    return flagIsOpened;
}

-(void) textfieldButtonPressed
{
    
    if(textField.text.length)
    {
        textField.text=@"";
        [textFieldButton setTitle:@"Paste" forState:UIControlStateNormal];
    }
    else
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSString *string = pasteboard.string;
        if (string) {
            textField.text=string;
            [textFieldButton setTitle:@"Paste" forState:UIControlStateNormal];
        }
    }

}



-(void) applyPressed
{
    if([self canApply:textField.text])
    {
        self.isOpened=NO;
        addressLabel.text=textField.text;
        _address=textField.text;
        [LWCache instance].refundAddress=_address;
        [self.delegate addressViewPressedApply:self];
    }
    else
    {
        [self makeToast:@"Invalid Bitcoin Address"];
    }
}


- (BOOL)canApply:(NSString *) string
{
    if(string.length<26 || string.length>35)
        return NO;
    NSString *sss=[[string componentsSeparatedByCharactersInSet:[NSCharacterSet alphanumericCharacterSet]] componentsJoinedByString:@""];
    if(sss.length)
        return NO;
//    NSString *firstSymbol=[string substringToIndex:1];
//    NSArray *possibleFirstSymbols=@[@"1", @"3", @"2", @"m", @"n"];
//    BOOL flag=false;
//    for(NSString *s in possibleFirstSymbols)
//    {
//        if([s isEqualToString:firstSymbol])
//        {
//            flag=true;
//            break;
//        }
//    }
//    
//    return flag;
    
    return YES;
}



@end
