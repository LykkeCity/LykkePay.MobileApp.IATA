//
//  LWPrivateKeyManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateKeyManager.h"
#import "NewDecodeBase64.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation LWPrivateKeyManager

+ (instancetype)shared
{
    static LWPrivateKeyManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LWPrivateKeyManager alloc] init];
    });
    return shared;
}


-(NSString *) encryptKey:(NSString *) privateKey password:(NSString *) password pin:(NSString *) pin
{
    NSString *string=privateKey;
    NSMutableData *ddd=[[string dataUsingEncoding:NSASCIIStringEncoding] mutableCopy];
    
    while ([ddd length]<48)
    {
        [ddd appendBytes:"" length:1];
    }
    
    NSString *key=@"1234560000000000";
//    while(key.length)
//    {
//        <#statements#>
//    }
    
    NSData *data=[self AES256Encrypt:ddd WithKey:key];
    
    NSString *base64String=[NewDecodeBase64 encodeBase64WithData:data];
    NSLog(@"%@", base64String);
    
    NSData *data1=[self AES256DecryptData:data WithKey:key];
    
    return base64String;
    
}




- (NSData *)AES256Encrypt:(NSData *) data WithKey:(NSString *)key {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData*)AES256DecryptData:(NSData *) data WithKey:(NSString*)key {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}


-(void) generatePrivateKey
{
    NSString * str = @"68656C6C6F";
    NSMutableString * newString = [[NSMutableString alloc] init];
    int i = 0;
    while (i < [str length])
    {
        NSString * hexChar = [str substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
        i+=2;
    }
    
    
    
    NSString *str1=[self encryptKey:@"1KKKK6N21XKo48zWKuQKXdvSsCf95ibHFa" password:@"123456" pin:@"0000"];
    NSLog(@"%@", str1);
    
}


@end
