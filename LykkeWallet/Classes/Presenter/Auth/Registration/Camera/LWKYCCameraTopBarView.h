//
//  LWKYCCameraTopBarView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWKYCCameraTopBarElementView.h"
#import "LWKYCDocumentsModel.h"

@interface LWKYCCameraTopBarView : UIView

@property (strong, nonatomic) LWKYCDocumentsModel *documentsStatuses;

-(void) setActiveType:(KYCDocumentType) type;
-(void) adjustStatuses;

@property id delegate;

@end

@protocol LWKYCCameraTopBarViewDelegate

-(void) kycTopBarViewPressedDocumentType:(KYCDocumentType) type;

@end
