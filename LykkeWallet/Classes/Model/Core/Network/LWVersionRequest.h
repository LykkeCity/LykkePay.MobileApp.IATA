//
//  LWVersionRequest.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWVersionRequest : NSObject

+(void) requestIsClientVersionSupported:(void(^)(BOOL isSupported, NSString *message)) completion;

@end
