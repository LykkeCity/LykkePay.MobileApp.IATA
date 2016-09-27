//
//  LWUtils.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWUtils.h"
#import "LWCache.h"
#import "LWMath.h"
#import "LWAssetModel.h"
#import "LWAssetPairModel.h"


@implementation LWUtils

+ (UIImage *)imageForIssuerId:(NSString *)issuerId {
    if (issuerId) {
        if ([issuerId isEqualToString:@"BTC"]) {
            return [UIImage imageNamed:@"WalletBitcoin"];
        }
#ifdef PROJECT_IATA
        else if ([issuerId isEqualToString:@"LKE"]) {
            return [UIImage imageNamed:@"IATAWallet"];
        }        
#else
        else if ([issuerId isEqualToString:@"LKE"]) {
            return [UIImage imageNamed:@"WalletLykke"];
        }
#endif
    }
    return nil;
}

+ (UIImage *)imageForIATAId:(NSString *)imageType {
#ifdef PROJECT_IATA
    if (imageType) {
        if ([imageType isEqualToString:@"EK"]) {
            return [UIImage imageNamed:@"EmiratesIcon"];
        }
        else if ([imageType isEqualToString:@"QR"]) {
            return [UIImage imageNamed:@"QatarIcon"];
        }
        else if ([imageType isEqualToString:@"BA"]) {
            return [UIImage imageNamed:@"BritishAirwaysIcon"];
        }
        else if ([imageType isEqualToString:@"DL"]) {
            return [UIImage imageNamed:@"DeltaAirLinesIcon"];
        }
        else if ([imageType isEqualToString:@"IT"]) {
            return [UIImage imageNamed:@"IATAIcon"];
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
#else
    return nil;
#endif
}

+(NSNumber *) accuracyForAssetId:(NSString *) assetID
{
        NSArray *assets=[LWCache instance].allAssets;

        NSNumber *accuracy=@(0);
        for(LWAssetModel *m in assets)
        {
            if([m.identity isEqualToString:assetID])
            {
                accuracy=m.accuracy;
                break;
            }
        }
        
        return accuracy;

}

+(NSString *) stringFromDouble:(double) number
{
    if(number==(int)number)
    {
        return [NSString stringWithFormat:@"%d", (int)number];
    }
    NSString *str=[NSString stringWithFormat:@"%.8lf", number];
    while (str.length>1 )
    {
        if([[str substringFromIndex:str.length-1] isEqualToString:@"0"])
        {
            str=[str substringToIndex:str.length-1];
        }
        else
            break;
    }
    
    return str;
}

+(NSString *) stringFromNumber:(NSNumber *) number
{
    NSString *string=number.stringValue;
    string=[string stringByReplacingOccurrencesOfString:@"," withString:@"."];
    if([string rangeOfString:@"."].location==NSNotFound)
        return string;
    NSArray *arr=[string componentsSeparatedByString:@"."];
    if([arr[1] length]>8)
    {
        string=[NSString stringWithFormat:@"%@.%@", arr[0], [arr[1] substringToIndex:8]];
    }
    
    while(string.length>1)
    {
        if([[string substringFromIndex:string.length-1] isEqualToString:@"0"] || [[string substringFromIndex:string.length-1] isEqualToString:@"."])
        {
            string=[string substringToIndex:string.length-1];
        }
        else
            break;

    }
    return string;
}

+(double) fairVolume:(double) volume accuracy:(int) accuracy roundToHigher:(BOOL) flagRoundHigher
{
    NSString *formatString=[NSString stringWithFormat:@"%d",accuracy];
    formatString=[[@"%." stringByAppendingString:formatString] stringByAppendingString:@"lf"];
    NSString *tmpStr=[NSString stringWithFormat:formatString,volume];
    
    
    double append=1;
    int acc=accuracy+2;
    while(acc>0)
    {
        append=append/10;
        acc--;
    }
    
    if((tmpStr.doubleValue>volume-append && flagRoundHigher) || tmpStr.doubleValue==volume || (tmpStr.doubleValue<volume+append && flagRoundHigher==NO))
        return tmpStr.doubleValue;
    
    
    append=1;
    acc=accuracy;
    while(acc>0)
    {
        append=append/10;
        acc--;
    }
    if(flagRoundHigher)
        volume=tmpStr.doubleValue+append;
    else
        volume=tmpStr.doubleValue-append;
    return volume;
    
}

+(NSString *) formatFairVolume:(double) volume accuracy:(int) accuracy roundToHigher:(BOOL) flagRoundHigher
{
 
    double fairVolume=[LWUtils fairVolume:volume accuracy:accuracy roundToHigher:flagRoundHigher];
    NSString *formatString=[NSString stringWithFormat:@"%d",accuracy];
    formatString=[[@"%." stringByAppendingString:formatString] stringByAppendingString:@"lf"];
    NSString *tmpStr=[NSString stringWithFormat:formatString,fairVolume];
    
    return [LWUtils formatVolumeString:tmpStr currencySign:@"" accuracy:accuracy removeExtraZeroes:YES];
    
}

+(NSString *) formatVolumeNumber:(NSNumber *) volumee currencySign:(NSString *) currency accuracy:(int) accuracy removeExtraZeroes:(BOOL) flagRemoveZeroes
{
    NSString *formatString=[NSString stringWithFormat:@"%d",accuracy];
    formatString=[[@"%." stringByAppendingString:formatString] stringByAppendingString:@"lf"];
    NSString *volume=[NSString stringWithFormat:formatString,volumee.doubleValue];
    return [LWUtils formatVolumeString:volume currencySign:currency accuracy:accuracy removeExtraZeroes:flagRemoveZeroes];
}

+(NSString *) formatVolumeString:(NSString *) volumee currencySign:(NSString *) currency accuracy:(int) accuracy removeExtraZeroes:(BOOL) flagRemoveZeroes
{
    NSString *volume=[volumee stringByReplacingOccurrencesOfString:@" " withString:@""];
    double v=volume.doubleValue;
    long leftPart=labs((long)v);
    
    long rightPart=0;

    NSString *rightPartString;
    
    volume=[volume stringByReplacingOccurrencesOfString:@"," withString:@"."];

    NSArray *arr=[volume componentsSeparatedByString:@"."];
    if(arr.count==2)
    {
        rightPart=[arr[1] intValue];
        rightPartString=arr[1];
    }
    
    NSMutableArray *components=[[NSMutableArray alloc] init];
    
    while(leftPart>=1000)
    {
        long part=leftPart%1000;
        if(part<10)
            [components insertObject:[NSString stringWithFormat:@"00%ld",part] atIndex:0];
        else if(part<100)
            [components insertObject:[NSString stringWithFormat:@"0%ld",part] atIndex:0];
        else
            [components insertObject:[NSString stringWithFormat:@"%ld",part] atIndex:0];
        leftPart=leftPart/1000;
    }
    
    [components insertObject:[NSString stringWithFormat:@"%ld",leftPart] atIndex:0];
    NSMutableString *finalString=[@"" mutableCopy];
    
    if(v<0)
        [finalString appendString:@"-"];
    [finalString appendString:currency];
    for(int i=0;i<components.count;i++)
    {
        if(i!=0)
            [finalString appendString:@" "];
        [finalString appendString:components[i]];
    }
    if(rightPart>0 && accuracy!=0 && flagRemoveZeroes==YES)
    {
        
        NSString *toAdd=[NSString stringWithFormat:@".%@", arr[1]];
        if(accuracy>0)
        {
            if(toAdd.length>accuracy+1)
                toAdd=[toAdd substringToIndex:accuracy+1];
            
            while (toAdd.length>1 )
            {
                if([[toAdd substringFromIndex:toAdd.length-1] isEqualToString:@"0"])
                {
                    toAdd=[toAdd substringToIndex:toAdd.length-1];
                }
                else
                    break;
            }
        }
        if(toAdd.length>1)
            [finalString appendString:toAdd];
    }
    else if(rightPartString && flagRemoveZeroes==NO)
    {
        [finalString appendFormat:@".%@", rightPartString];
    }
    
    return finalString;
}

+ (NSString *)baseAssetTitle:(LWAssetPairModel *)assetPair {
    
    return [LWAssetModel assetByIdentity:assetPair.baseAssetId fromList:[LWCache instance].allAssets]; //Andrey

    
    NSString *baseAssetId = [LWCache instance].baseAssetId;
    NSString *assetTitleId = assetPair.baseAssetId;
    if ([baseAssetId isEqualToString:assetPair.baseAssetId]) {
        assetTitleId = assetPair.quotingAssetId;
    }
    NSString *assetTitle = [LWAssetModel
                            assetByIdentity:assetTitleId
                            fromList:[LWCache instance].allAssets];
    return assetTitle;
}

+ (NSString *)quotedAssetTitle:(LWAssetPairModel *)assetPair {
    
    return [LWAssetModel assetByIdentity:assetPair.quotingAssetId fromList:[LWCache instance].allAssets]; //Andrey

    
    
    NSString *baseAssetId = [LWCache instance].baseAssetId;
    NSString *assetTitleId = assetPair.quotingAssetId;
    if (![baseAssetId isEqualToString:assetPair.quotingAssetId]) {
        assetTitleId = assetPair.baseAssetId;
    }
    
    NSString *assetTitle = [LWAssetModel
                            assetByIdentity:assetTitleId
                            fromList:[LWCache instance].allAssets];
    return assetTitle;
}

+ (NSString *)priceForAsset:(LWAssetPairModel *)assetPair forValue:(NSNumber *)value {
    //Andrey
    
//    NSString *result=[LWUtils formatVolumeString:[NSString stringWithFormat:@"%f", value.floatValue] currencySign:assetPair. accuracy:<#(int)#>]
    
    NSString *result;
    if(assetPair.inverted==NO)
    {
        result=[LWUtils formatVolumeNumber:value currencySign:@"" accuracy:assetPair.accuracy.intValue removeExtraZeroes:YES];
    }
    else
    {
        result=[LWUtils formatVolumeNumber:value currencySign:@"" accuracy:assetPair.invertedAccuracy.intValue removeExtraZeroes:YES];
    }
    
    
//    NSString *result = [LWMath priceString:value
//                                 precision:assetPair.accuracy
//                                withPrefix:@""];
    return result;
}

+ (NSString *)priceForAsset:(LWAssetPairModel *)assetPair forValue:(NSNumber *)value withFormat:(NSString *)format {
    
    NSString *rateString = [LWUtils priceForAsset:assetPair forValue:value];
    NSString *result = [NSString stringWithFormat:format,
                        [LWUtils baseAssetTitle:assetPair],
                        [LWUtils quotedAssetTitle:assetPair], rateString];
    
    return result;
}


+(NSString *) hexStringFromData:(NSData *) data
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

+(NSData *) dataFromHexString:(NSString *) command
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

+(void) appendToLogFile:(NSString *)string
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *logPath = [[NSString alloc] initWithFormat:@"%@",[documentsDir stringByAppendingPathComponent:@"log.txt"]];
    if([[NSFileManager defaultManager] fileExistsAtPath:logPath]==NO)
    {
        [[NSFileManager defaultManager] createFileAtPath:logPath contents:[NSData data] attributes:nil];
    }
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:logPath];
    [fileHandler seekToEndOfFile];
    
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    

    NSString *toAppend=[NSString stringWithFormat:@"%@  %@\n",[formatter stringFromDate:[NSDate date]], string];
    
    
    [fileHandler writeData:[toAppend dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}




@end
