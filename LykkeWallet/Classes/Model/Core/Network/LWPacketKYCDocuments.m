//
//  LWPacketKYCDocuments.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketKYCDocuments.h"

@implementation LWPacketKYCDocuments


- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _documentsStatuses=[[LWKYCDocumentsModel alloc] initWithArray:result[@"Docs"]];
    
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return @"KycDocuments";
}


@end
