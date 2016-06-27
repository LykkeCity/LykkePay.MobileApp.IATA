//
//  LWPrivateKeyManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateKeyManager.h"
#import "LWKeychainManager.h"
#import "NewDecodeBase64.h"
#import <CommonCrypto/CommonCryptor.h>
#import "base58.h"
#import "ecdsa.h"
#import "secp256k1.h"
#import "curves.h"
#import "LWConstantsLykke.h"


@import Security;

@implementation LWPrivateKeyManager

-(id) init
{
    self=[super init];
    _privateKeyWif=@"";
    return self;
}

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
    
    while ([ddd length]<64)
    {
        [ddd appendBytes:"" length:1];
    }
    
    NSString *key=[password stringByAppendingString:pin];
    if(key.length>16)
    {
        key=[key substringToIndex:16];
    }
    else if(key.length<16)
    {
        while(key.length<16)
            key=[key stringByAppendingString:@" "];
    }
    
    NSData *data=[self AES256Encrypt:ddd WithKey:key];
    
    
    return [self hexStringFromData:data];
    
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

-(void) decryptPrivateKey:(NSString *)encryptedPrivateKeyData
{
    
    NSString *key=[[LWKeychainManager instance].password stringByAppendingString:[LWKeychainManager instance].pin];
    if(key.length>16)
    {
        key=[key substringToIndex:16];
    }
    else if(key.length<16)
    {
        while(key.length<16)
            key=[key stringByAppendingString:@" "];
    }
    
    
    NSData *prKeyData=[self AES256DecryptData:[self dataFromHexString:encryptedPrivateKeyData] WithKey:key];
    
    NSString *privateWifString=[[NSString alloc] initWithData:prKeyData encoding:NSUTF8StringEncoding];
    [privateWifString stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    
    uint8_t *string=(uint8_t *)[privateWifString cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t data[100];
    base58_decode_check(string, data, 100);
    NSData *privateKeyData=[[NSData alloc] initWithBytes:data+1 length:32];
    _privateKey=[self hexStringFromData:privateKeyData];
    
    

    [self generatePublicKeyFromPrivateKey];
    
//    NSString *str1=[self encryptKey:_privateKeyWif password:[LWKeychainManager instance].password pin:[LWKeychainManager instance].pin];

//    NSLog(@"%@", str1);

}

-(void) decryptKeyIfPossible
{
    NSString *pin=[LWKeychainManager instance].pin;
    NSString *password=[LWKeychainManager instance].password;
    NSString *key=[LWKeychainManager instance].encodedPrivateKey;
    
    if([LWKeychainManager instance].pin && [LWKeychainManager instance].password && [LWKeychainManager instance].encodedPrivateKey)
    {
        _encryptedKey=[LWKeychainManager instance].encodedPrivateKey;
        
//        uint8_t data[100];
//        
//        base58_decode_check([_encryptedKey cStringUsingEncoding:NSUTF8StringEncoding], data, 100);
//        NSData *prKeyData=[[NSData alloc] initWithBytes:data length:32];
//        
        
        
        [self decryptPrivateKey:_encryptedKey];
    }
}


-(void) generatePrivateKey
{
    
    uint8_t randKeyBytes[32];
    
    SecRandomCopyBytes (kSecRandomDefault, 32, randKeyBytes);

    
    NSData *privateKeyData=[[NSData alloc] initWithBytes:randKeyBytes length:32];

    NSString *privateKey=[self hexStringFromData:privateKeyData];
    
    
//    privateKey=@"f19c523315891e6e15ae0608a35eec2e00ebd6d1984cf167f46336dabd9b2de4";//Testing from example
//    privateKeyData=[self dataFromHexString:privateKey];//Testing
    
    
    _privateKey=[privateKey copy];
    [self generatePublicKeyFromPrivateKey];

    
    NSString *str1=[self encryptKey:_privateKeyWif password:[LWKeychainManager instance].password pin:[LWKeychainManager instance].pin];
//    NSString *str1=[self encryptKey:_privateKeyWif password:@"123456" pin:@"0000"];
    _encryptedKey=str1;
    NSLog(@"%@", str1);
    
    
    NSLog(@"Key: %@     Encrypted: %@", privateKey, _encryptedKey);
    
    
//    [self decryptPrivateKey:[_encryptedKey copy]];
//    
//    NSLog(@"Key: %@     Encrypted: %@", privateKey, _encryptedKey);

    
}


-(void) generatePublicKeyFromPrivateKey
{
    NSData *privateKeyData=[self dataFromHexString:_privateKey];

    BOOL flagProd=[[LWKeychainManager instance].address isEqualToString:kProductionServer] || [[LWKeychainManager instance].address isEqualToString:kStagingTestServer];
    
    uint8_t data[100];
    memcpy(data+1, privateKeyData.bytes, privateKeyData.length);
    if(flagProd)
        data[0]=0x80;
    else
        data[0]=0xef;
    
    data[33]=0x01;
    
    char tmpstr[200];
    
    base58_encode_check(data, (uint8_t)privateKeyData.length+2, tmpstr, 200);
    
    _privateKeyWif=[[NSString alloc] initWithCString:tmpstr encoding:NSUTF8StringEncoding];
    
    
    uint8_t pub_key[100];
    for(int i=0;i<100;i++)
        pub_key[i]=0x0;
    
    
    ecdsa_get_public_key33(&secp256k1, privateKeyData.bytes, pub_key);
    
    NSData *publicKeyData=[[NSData alloc] initWithBytes:pub_key length:33];
    
    NSString *publicKeyString=[self hexStringFromData:publicKeyData];
    
    
    char pubkey_hash[21];
    
    ecdsa_get_pubkeyhash(pub_key, (uint8_t *)pubkey_hash+1);
    pubkey_hash[0]=0x0;
    
    NSData *pubKeyHash=[[NSData alloc] initWithBytes:pubkey_hash length:21];
    
    
    
    //    base58_encode_check(pubKeyHash.bytes, pubKeyHash.length, tmpstr, 200);
    
    char address[200];
    ecdsa_get_address(pub_key, 0, address, 200);
    
    NSString *bitcoinAddress=[[NSString alloc] initWithCString:address encoding:NSUTF8StringEncoding];
    
    
    _publicKey=publicKeyString;
    _bitcoinAddress=bitcoinAddress;
    

}


-(NSString *) hexStringFromData:(NSData *) data
{
    NSUInteger capacity = data.length * 2;
    NSMutableString *string = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *buf = data.bytes;
    NSInteger i;
    for (i=0; i<data.length; ++i) {
        [string appendFormat:@"%02x", (NSUInteger)buf[i]];
    }
    return string;
}

-(NSData *) dataFromHexString:(NSString *) command
{
    
    command = [command stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [command length]/2; i++) {
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    
    return commandToSend;
}

//-(NSString *) base58Encode
//{
//    NSArray  *alphabet = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",
//        @"G",@"H",@"J",@"K",@"L",@"M",@"N",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"a",@"b",@"c",
//        @"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z"];
//    int base_count = 58; NSMutableString *encoded; int div; int mod;
//    while (num >= base_count)
//    {
//        div = num / base_count;   mod = (num - (base_count * div));
//        encoded = alphabet[ mod.ConvertToLong() ] + encoded;   num = div;
//    }
//    encoded = vers + alphabet[ num.ConvertToLong() ] + encoded;
//    return encoded;
// 
//}



@end
