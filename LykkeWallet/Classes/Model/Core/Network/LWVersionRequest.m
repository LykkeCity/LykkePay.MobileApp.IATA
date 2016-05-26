//
//  LWVersionRequest.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWVersionRequest.h"
#import "LWKeychainManager.h"

@implementation LWVersionRequest

+(void) requestIsClientVersionSupported:(void(^)(BOOL isSupported, NSString *message)) completion
{
    return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *version=[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        
//        version=@"222";
        
        NSString *addr=[NSString stringWithFormat:@"https://%@/api/ClientVersionSupported?clientVersion=%@", [LWKeychainManager instance].address, version];
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:addr]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        if(data)
        {
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", dict);
            if(dict && dict[@"Result"])
            {
                if([dict[@"Result"][@"IsSupported"] boolValue])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, nil);
                    });
                }
                else
                {
                    NSString *message=dict[@"Result"][@"Message"];
                    if([message isKindOfClass:[NSString class]]==NO)
                        message=nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(NO, message);
                    });

                }
            }
        }
    
    
    });
}

@end
