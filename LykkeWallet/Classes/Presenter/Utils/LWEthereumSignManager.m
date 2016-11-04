//
//  LWEthereumSignManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWEthereumSignManager.h"

@import UIKit;

@interface LWEthereumSignManager() <UIWebViewDelegate>
{
    NSString *key;
    NSString *hash;
    UIWebView *webView;
    
    void(^completion)(NSString *);
}

@end

@implementation LWEthereumSignManager

-(id) initWithEthPrivateKey:(NSString *) _key
{
    self=[super init];
    webView=[[UIWebView alloc] init];
    webView.delegate=self;

    
    key=_key;
    return self;
}

-(void) signHash:(NSString *) _hash withCompletion:(void(^)(NSString *)) _completion
{
    hash=_hash;
    completion=_completion;

    NSString *path;
    NSBundle *thisBundle = [NSBundle mainBundle];
    path = [thisBundle pathForResource:@"lykke-ethereum" ofType:@"html"];
    NSURL *instructionsURL = [NSURL fileURLWithPath:path];
    [webView loadRequest:[NSURLRequest requestWithURL:instructionsURL]];
    
    
}


-(void) createAddress
{
    NSString *path;
    NSBundle *thisBundle = [NSBundle mainBundle];
    path = [thisBundle pathForResource:@"lykke-ethereum" ofType:@"html"];
    NSURL *instructionsURL = [NSURL fileURLWithPath:path];
    [webView loadRequest:[NSURLRequest requestWithURL:instructionsURL]];

    
//    NSString *sss=[webView stringByEvaluatingJavaScriptFromString:@"window.ethereumjs.createAddress()"];
//    NSLog(@"%@", sss);

}

-(void) webViewDidFinishLoad:(UIWebView *)we
{
    NSString *sss=[webView stringByEvaluatingJavaScriptFromString:@"window.ethereumjs.createAddress(\'0x00000000000000000000000000000000c0e8d32ef6744d801987bc3ecb6a0953\')"];

//    NSString *sss=[webView stringByEvaluatingJavaScriptFromString:@"window.ethereumjs.createAddress(\'0xba1488fd638adc2e9f62fc70d41ff0ffc0e8d32ef6744d801987bc3ecb6a0953\')"];

    NSString *pub=[webView stringByEvaluatingJavaScriptFromString:@"window.ethereumjs.privateKeyExport(\'0x4085dde01ea641a0f4fd6586ca11fc1f5df38e1bdcbef501da970cad9335b389\',1)"];
    NSLog(@"%@", sss);
    
    
    
//    NSString *request=[NSString stringWithFormat:@"window.ethereumjs.signHash(\'%@\', \'%@\')", hash, key];
//    
//    NSString *sss=[webView stringByEvaluatingJavaScriptFromString:request];
//    completion(sss);
}


@end
