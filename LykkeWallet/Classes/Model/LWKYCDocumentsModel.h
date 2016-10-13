//
//  LWKYCDocumentsModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWDocumentsStatus.h"

//typedef enum {KYCDocumentTypeSelfie, KYCDocumentTypePassport, KYCDocumentTypeAddress} KYCDocumentType;
typedef enum {KYCDocumentStatusEmpty, KYCDocumentStatusUploaded, KYCDocumentStatusApproved, KYCDocumentStatusRejected} KYCDocumentStatus;


@interface LWKYCDocumentsModel : NSObject

-(id) initWithArray:(NSArray *) array;

-(KYCDocumentStatus) statusForDocument:(KYCDocumentType) type;
-(void) setDocumentStatus:(KYCDocumentStatus) status forDocument:(KYCDocumentType) type;

-(void) saveImage:(UIImage *)image forType:(KYCDocumentType) type;

-(UIImage *) imageForType:(KYCDocumentType) type;

-(NSString *) commentForType:(KYCDocumentType) type;

@end
