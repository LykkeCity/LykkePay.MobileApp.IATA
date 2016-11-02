//
//  LWSuccessPresenterViewController.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 02/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWCommonButton.h"

@interface LWSuccessPresenterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet LWCommonButton *button;

@end
