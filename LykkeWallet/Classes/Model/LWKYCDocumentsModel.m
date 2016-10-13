//
//  LWKYCDocumentsModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWKYCDocumentsModel.h"
#import "LWSendImageManager.h"
#import "LWKeychainManager.h"

@interface LWKYCDocumentsModel() <LWSendImageManagerDelegate>
{
    NSMutableDictionary *docs;
}

@end

@implementation LWKYCDocumentsModel

-(id) initWithArray:(NSArray *) array
{
    self=[super init];
    
    docs=[[NSMutableDictionary alloc] init];
    for(NSDictionary *d in array)
    {
        KYCDocumentType type;
        if([d[@"Type"] isEqualToString:@"IdCard"])
            type=KYCDocumentTypeIdCard;
        else if([d[@"Type"] isEqualToString:@"ProofOfAddress"])
            type=KYCDocumentTypeProofOfAddress;
        else if([d[@"Type"] isEqualToString:@"Selfie"])
            type=KYCDocumentTypeSelfie;
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        dict[@"ID"]=d[@"DocumentId"];
        if([d[@"DocumentState"] isEqualToString:@"Uploaded"])
            dict[@"Status"]=@(KYCDocumentStatusUploaded);
        else if([d[@"DocumentState"] isEqualToString:@"Approved"])
            dict[@"Status"]=@(KYCDocumentStatusApproved);
        else if([d[@"DocumentState"] isEqualToString:@"Declined"])
            dict[@"Status"]=@(KYCDocumentStatusRejected);
        if(d[@"KycComment"])
            dict[@"Comment"]=d[@"KycComment"];
        
        docs[@(type)]=dict;
    }
    
    return self;
}

-(KYCDocumentStatus) statusForDocument:(KYCDocumentType)type
{
    if(docs[@(type)])
        return [docs[@(type)][@"Status"] intValue];
    
    return KYCDocumentStatusEmpty;
}

-(void) setDocumentStatus:(KYCDocumentStatus)status forDocument:(KYCDocumentType)type
{
    if(docs[@(type)])
        docs[@(type)][@"Status"]=@(status);
    else
    {
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        dict[@"Status"]=@(status);
        docs[@(type)]=dict;
    }
}

-(UIImage *) imageForType:(KYCDocumentType)type
{
    if(docs[@(type)][@"Image"])
        return docs[@(type)][@"Image"];
    else if(docs[@(type)][@"ID"])
    {
        NSString *baseurl = [NSString stringWithFormat:@"https://%@/api/KycDocumentsBin/%@?width=640", [LWKeychainManager instance].address, docs[@(type)][@"ID"]];
        

        return (UIImage *)baseurl;
    }
    return nil;
}

-(void) saveImage:(UIImage *)image forType:(KYCDocumentType)type
{
    if(docs[@(type)])
        docs[@(type)][@"Image"]=image;
    else
    {
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        dict[@"Image"]=image;
        docs[@(type)]=dict;
    }
    if(docs[@(type)][@"Uploader"])
    {
        LWSendImageManager *manager=docs[@(type)][@"Uploader"];
        [manager stopUploading];
    }
    LWSendImageManager *manager=[[LWSendImageManager alloc] init];
    manager.delegate=self;
    docs[@(type)][@"Uploader"]=manager;
    [manager sendImageWithData:UIImageJPEGRepresentation(image, 0.8) type:type];
    
}

-(NSString *) commentForType:(KYCDocumentType)type
{
    return docs[@(type)][@"Comment"];
}

-(void) sendImageManagerSentImage:(LWSendImageManager *)manager
{
    for(NSMutableDictionary *d in docs.allValues)
        if(d[@"Uploader"]==manager)
        {
            [d removeObjectForKey:@"Uploader"];
            break;
        }
}

-(void) sendImageManager:(LWSendImageManager *)manager didFailWithErrorMessage:(NSString *)message
{
    for(NSMutableDictionary *d in docs.allValues)
        if(d[@"Uploader"]==manager)
        {
            [d removeObjectForKey:@"Uploader"];
            break;
        }

}

-(void) sendImageManager:(LWSendImageManager *)manager changedProgress:(float)progress
{
    
}

@end
