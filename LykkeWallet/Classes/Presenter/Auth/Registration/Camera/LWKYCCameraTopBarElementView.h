//
//  LWKYCCameraTopBarElementView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

typedef enum {KYCDocumentTypeSelfie, KYCDocumentTypePassport, KYCDocumentTypeAddress} KYCDocumentType;
typedef enum {KYCDocumentStatusEmpty, KYCDocumentStatusUploaded, KYCDocumentStatusApproved, KYCDocumentStatusRejected} KYCDocumentStatus;

#import <UIKit/UIKit.h>

@interface LWKYCCameraTopBarElementView : UIView


@property BOOL isActive;
@property KYCDocumentType type;

@property KYCDocumentStatus status;


@end
