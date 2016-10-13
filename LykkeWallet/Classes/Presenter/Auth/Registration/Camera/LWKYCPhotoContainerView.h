//
//  LWKYCPhotoContainerView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWKYCDocumentsModel.h"
//typedef enum {KYCPhotoContainerModeEmpty, KYCPhotoContainerModeBad, KYCPhotoContainerModePhoto} KYCPhotoContainerMode;

@interface LWKYCPhotoContainerView : UIView

@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSString *failedDescription;

@property KYCDocumentStatus status;
@property (strong, nonatomic) NSString *title;

@end
