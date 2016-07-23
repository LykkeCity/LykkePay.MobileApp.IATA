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
#import "BTCAddress.h"

#import "ecdsa.h"
//#import "secp256k1.h"
//#import "curves.h"
#import "LWConstantsLykke.h"
//#import "sha2.h"


@import Security;

@interface LWPrivateKeyManager()
{
    BTCKey *privateKeyForLykke;
}

@end

@implementation LWPrivateKeyManager

-(id) init
{
    self=[super init];
    
//    privateKeyForLykke=[[BTCKey alloc] initWithWIF:@"cU6bPP5KN9kvM7zek2bRURr9ABeF92kRFuqX7o8B2ojCMGyCxgsv"];
//    
//    NSString *pubkey=[self publicKeyLykke];
//    int iii=pubkey.length;
//    NSLog(@"%@", pubkey);
//    
    
    
    
//    [self generatePrivateKey];
//    NSString *sss=[self publicKeyLykke];
    
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

+(NSString *) addressFromPrivateKeyWIF:(NSString *)wif
{
    BTCKey *key=[[BTCKey alloc] initWithWIF:wif];
    if([[LWPrivateKeyManager shared] isDevServer])
        return key.addressTestnet.string;
    else
        return key.address.string;
}

-(NSString *) wifPrivateKeyLykke
{
    if(!privateKeyForLykke)
        return nil;
    NSString *wif;
    if([self isDevServer])
        wif=privateKeyForLykke.WIFTestnet;
    else
        wif=privateKeyForLykke.WIF;
    return wif;
}

-(BTCKey *) privateKeyLykke
{
    if(privateKeyForLykke)
        return privateKeyForLykke;
    if([LWKeychainManager instance].privateKeyLykke)
    {
        privateKeyForLykke=[[BTCKey alloc] initWithWIF:[LWKeychainManager instance].privateKeyLykke];
    }
    return privateKeyForLykke;
}

-(NSString *) publicKeyLykke
{
    if(!self.privateKeyLykke)
        return nil;
    NSData *publicKey=privateKeyForLykke.compressedPublicKey;
    return [self hexStringFromData:privateKeyForLykke.publicKey];
    return [self hexStringFromData:publicKey];
}

-(void) decryptLykkePrivateKeyAndSave:(NSString *)encodedPrivateKey
{
    NSString *privateKeyWif=[self decryptPrivateKey:encodedPrivateKey];
    if(privateKeyWif)
    {
        privateKeyForLykke=[[BTCKey alloc] initWithWIF:privateKeyWif];
        
        [[LWKeychainManager instance] saveLykkePrivateKey:privateKeyWif];
    }
    
    
}


-(BOOL) isDevServer
{
    if([[LWKeychainManager instance].address isEqualToString:kProductionServer] || [[LWKeychainManager instance].address isEqualToString:kStagingTestServer])
        return NO;
    return YES;
}

-(NSString *) encryptedKeyLykke
{
    if(!self.privateKeyLykke)
        return nil;
    NSString *wif;
    if([self isDevServer])
        wif=privateKeyForLykke.WIFTestnet;
    else
        wif=privateKeyForLykke.WIF;
    
    
    return [self encryptKey:wif password:[LWKeychainManager instance].password];
}


-(NSString *) encryptKey:(NSString *) privateKey password:(NSString *) password
{
    NSString *string=privateKey;
    NSMutableData *ddd=[[string dataUsingEncoding:NSASCIIStringEncoding] mutableCopy];
    
    while ([ddd length]<64)
    {
        [ddd appendBytes:"" length:1];
    }
    
    NSString *key=password;
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

-(NSString *) decryptPrivateKey:(NSString *)encryptedPrivateKeyData
{
    
    NSString *key=[LWKeychainManager instance].password;
//    key=[key stringByAppendingString:@"1111"];
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
    
    char *pointer=(char *)prKeyData.bytes;
    NSString *privateWifString=[[NSString alloc] initWithData:prKeyData encoding:NSUTF8StringEncoding];
    if(privateWifString.length && pointer[prKeyData.length-1]==(char)0x0)
        privateWifString=[[NSString alloc] initWithCString:pointer encoding:NSASCIIStringEncoding];
    
    
    return [privateWifString copy];
    
//    uint8_t *string=(uint8_t *)[privateWifString cStringUsingEncoding:NSUTF8StringEncoding];
//    
//    uint8_t data[100];
//    base58_decode_check(string, data, 100);
//    NSData *privateKeyData=[[NSData alloc] initWithBytes:data+1 length:32];
//    _privateKey=[self hexStringFromData:privateKeyData];
    
    

//    [self generatePublicKeyFromPrivateKey];
    
//    NSString *str1=[self encryptKey:_privateKeyWif password:[LWKeychainManager instance].password pin:[LWKeychainManager instance].pin];

//    NSLog(@"%@", str1);

}

//-(void) decryptKeyIfPossible
//{
//    
//    NSString *password=[LWKeychainManager instance].password;
//    NSString *key=[LWKeychainManager instance].encodedPrivateKey;
//    
//    if([LWKeychainManager instance].password && [LWKeychainManager instance].encodedPrivateKey)
//    {
//        _encryptedKey=[LWKeychainManager instance].encodedPrivateKey;
//        
////        uint8_t data[100];
////        
////        base58_decode_check([_encryptedKey cStringUsingEncoding:NSUTF8StringEncoding], data, 100);
////        NSData *prKeyData=[[NSData alloc] initWithBytes:data length:32];
////        
//        
//        
//        [self decryptPrivateKey:_encryptedKey];
//    }
//}


-(void) generatePrivateKey
{
    
    uint8_t randKeyBytes[32];
    
    SecRandomCopyBytes (kSecRandomDefault, 32, randKeyBytes);
    
    NSData *privateKeyData=[[NSData alloc] initWithBytes:randKeyBytes length:32];
    privateKeyForLykke=[[BTCKey alloc] initWithPrivateKey:privateKeyData];
    privateKeyForLykke.publicKeyCompressed=YES;
    NSString *wif;
    if([self isDevServer])
        wif=privateKeyForLykke.WIFTestnet;
    else
        wif=privateKeyForLykke.WIF;
//    [[LWKeychainManager instance] saveLykkePrivateKey:wif];
    
    
//
//    NSString *privateKey=[self hexStringFromData:privateKeyData];
//    
//    
////    privateKey=@"f19c523315891e6e15ae0608a35eec2e00ebd6d1984cf167f46336dabd9b2de4";//Testing from example
////    privateKeyData=[self dataFromHexString:privateKey];//Testing
//    
//    
//    _privateKey=[privateKey copy];
//    [self generatePublicKeyFromPrivateKey];
//
//    
//    NSString *str1=[self encryptKey:_privateKeyWif password:[LWKeychainManager instance].password pin:[LWKeychainManager instance].pin];
////    NSString *str1=[self encryptKey:_privateKeyWif password:@"123456" pin:@"0000"];
//    _encryptedKey=str1;
//    NSLog(@"%@", str1);
//    
//    
//    NSLog(@"Key: %@     Encrypted: %@", privateKey, _encryptedKey);
    
    
//    [self decryptPrivateKey:[_encryptedKey copy]];
//    
//    NSLog(@"Key: %@     Encrypted: %@", privateKey, _encryptedKey);

    
}


//-(void) generatePublicKeyFromPrivateKey
//{
//    NSData *privateKeyData=[self dataFromHexString:_privateKey];
//
//    BOOL flagProd=[[LWKeychainManager instance].address isEqualToString:kProductionServer] || [[LWKeychainManager instance].address isEqualToString:kStagingTestServer];
//    
//    uint8_t data[100];
//    memcpy(data+1, privateKeyData.bytes, privateKeyData.length);
//    if(flagProd)
//        data[0]=0x80;
//    else
//        data[0]=0xef;
//    
//    data[33]=0x01;
//    
//    char tmpstr[200];
//    
//    base58_encode_check(data, (uint8_t)privateKeyData.length+2, tmpstr, 200);
//    
//    _privateKeyWif=[[NSString alloc] initWithCString:tmpstr encoding:NSUTF8StringEncoding];
//    
//    
//    uint8_t pub_key[33];
//    for(int i=0;i<33;i++)
//        pub_key[i]=0x0;
//    
//    
//    ecdsa_get_public_key33(&secp256k1, privateKeyData.bytes, pub_key);
//
//    NSData *publicKeyData=[[NSData alloc] initWithBytes:pub_key length:33];
//    
//    NSString *publicKeyString=[self hexStringFromData:publicKeyData];
//    
//    
//    char pubkey_hash[21];
//    
//    ecdsa_get_pubkeyhash(pub_key, (uint8_t *)pubkey_hash+1);
//    if(flagProd)
//        pubkey_hash[0]=0x0;
//    else
//        pubkey_hash[0]=0x6f; //testnet pubkey hash prefix
//    
//    NSData *pubKeyHash=[[NSData alloc] initWithBytes:pubkey_hash length:21];
//    
//    
//    
//    //    base58_encode_check(pubKeyHash.bytes, pubKeyHash.length, tmpstr, 200);
//    
//    char address[200];
//    uint8_t version;
//    if(flagProd)
//        version=0;
//    else
//        version=0x6f;
//    ecdsa_get_address(pub_key, version, address, 200);
//    
//    NSString *bitcoinAddress=[[NSString alloc] initWithCString:address encoding:NSUTF8StringEncoding];
//    
//    
//    _publicKey=publicKeyString;
//    _bitcoinAddress=bitcoinAddress;
//    
//
//}


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



@end
