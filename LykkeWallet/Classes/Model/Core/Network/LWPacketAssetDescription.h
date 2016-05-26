//
//  LWPacketAssetDescription.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWAssetDescriptionModel;


@interface LWPacketAssetDescription : LWAuthorizePacket {
    
}
// in
@property (copy, nonatomic) NSString *identity;
// out
@property (copy, nonatomic) LWAssetDescriptionModel *assetDescription;

@end
