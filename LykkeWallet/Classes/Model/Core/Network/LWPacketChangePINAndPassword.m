//
//  LWPacketChangePINAndPassword.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketChangePINAndPassword.h"
#import "LWRecoveryPasswordModel.h"
#import "LWPrivateKeyManager.h"

@implementation LWPacketChangePINAndPassword

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    self.recModel.securityMessage2=result[@"NewOwnershipMsgToSign"];
    
}

- (NSString *)urlRelative {
    return @"ChangePinAndPassword";
}

-(NSDictionary *) params
{
    NSDictionary *params=@{@"Email":self.recModel.email, @"SignedOwnershipMsg":self.recModel.signature2, @"SmsCode":self.recModel.smsCode, @"NewPin":self.recModel.pin, @"NewPassword":self.recModel.password, @"NewHint":self.recModel.hint, @"EncodedPrivateKey":[[LWPrivateKeyManager shared] encryptKey:[LWPrivateKeyManager shared].wifPrivateKeyLykke password:self.recModel.password]};
    NSLog(@"%@", params);
    return params;
}


@end
