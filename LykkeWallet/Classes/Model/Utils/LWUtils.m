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
        NSArray *assets=[LWCache instance].baseAssets;

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

+(NSString *) formatVolumeString:(NSString *) volumee currencySign:(NSString *) currency accuracy:(int) accuracy removeExtraZeroes:(BOOL) flagRemoveZeroes
{
    NSString *volume=[volumee stringByReplacingOccurrencesOfString:@" " withString:@""];
    float v=volume.floatValue;
    int leftPart=abs((int)v);
    
    int rightPart=0;

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
        int part=leftPart%1000;
        if(part<10)
            [components insertObject:[NSString stringWithFormat:@"00%d",part] atIndex:0];
        else if(part<100)
            [components insertObject:[NSString stringWithFormat:@"0%d",part] atIndex:0];
        else
            [components insertObject:[NSString stringWithFormat:@"%d",part] atIndex:0];
        leftPart=leftPart/1000;
    }
    
    [components insertObject:[NSString stringWithFormat:@"%d",leftPart] atIndex:0];
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
            
            while (toAdd.length>1)
            {
                if([[toAdd substringFromIndex:toAdd.length-1] isEqualToString:@"0"])
                {
                    toAdd=[toAdd substringToIndex:toAdd.length-1];
                }
                else
                    break;
            }
        }
        [finalString appendString:toAdd];
    }
    else if(rightPartString && flagRemoveZeroes==NO)
    {
        [finalString appendFormat:@".%@", rightPartString];
    }
    
    return finalString;
}

+ (NSString *)baseAssetTitle:(LWAssetPairModel *)assetPair {
    NSString *baseAssetId = [LWCache instance].baseAssetId;
    NSString *assetTitleId = assetPair.baseAssetId;
    if ([baseAssetId isEqualToString:assetPair.baseAssetId]) {
        assetTitleId = assetPair.quotingAssetId;
    }
    NSString *assetTitle = [LWAssetModel
                            assetByIdentity:assetTitleId
                            fromList:[LWCache instance].baseAssets];
    return assetTitle;
}

+ (NSString *)quotedAssetTitle:(LWAssetPairModel *)assetPair {
    NSString *baseAssetId = [LWCache instance].baseAssetId;
    NSString *assetTitleId = assetPair.quotingAssetId;
    if (![baseAssetId isEqualToString:assetPair.quotingAssetId]) {
        assetTitleId = assetPair.baseAssetId;
    }
    
    NSString *assetTitle = [LWAssetModel
                            assetByIdentity:assetTitleId
                            fromList:[LWCache instance].baseAssets];
    return assetTitle;
}

+ (NSString *)priceForAsset:(LWAssetPairModel *)assetPair forValue:(NSNumber *)value {
    //Andrey
    
//    NSString *result=[LWUtils formatVolumeString:[NSString stringWithFormat:@"%f", value.floatValue] currencySign:assetPair. accuracy:<#(int)#>]
    
    
    
    
    NSString *result = [LWMath priceString:value
                                 precision:assetPair.accuracy
                                withPrefix:@""];
    return result;
}

+ (NSString *)priceForAsset:(LWAssetPairModel *)assetPair forValue:(NSNumber *)value withFormat:(NSString *)format {
    
    NSString *rateString = [LWUtils priceForAsset:assetPair forValue:value];
    NSString *result = [NSString stringWithFormat:format,
                        [LWUtils baseAssetTitle:assetPair],
                        [LWUtils quotedAssetTitle:assetPair], rateString];
    
    return result;
}

@end
