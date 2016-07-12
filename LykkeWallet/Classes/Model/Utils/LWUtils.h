//
//  LWUtils.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class LWAssetPairModel;


@interface LWUtils : NSObject {
    
}

+ (UIImage *)imageForIssuerId:(NSString *)issuerId;
+ (UIImage *)imageForIATAId:(NSString *)imageType;
+ (NSString *)baseAssetTitle:(LWAssetPairModel *)assetPair;
+ (NSString *)quotedAssetTitle:(LWAssetPairModel *)assetPair;
+ (NSString *)priceForAsset:(LWAssetPairModel *)assetPair forValue:(NSNumber *)value;
+ (NSString *)priceForAsset:(LWAssetPairModel *)assetPair forValue:(NSNumber *)value withFormat:(NSString *)format;

+(NSString *) formatFairVolume:(double) volume accuracy:(int) accuracy roundToHigher:(BOOL) flagRoundHigher;
+(NSString *) formatVolumeString:(NSString *) volume currencySign:(NSString *) currency accuracy:(int) accuracy removeExtraZeroes:(BOOL) flagRemoveZeroes;
+(NSString *) formatVolumeNumber:(NSNumber *) volumee currencySign:(NSString *) currency accuracy:(int) accuracy removeExtraZeroes:(BOOL) flagRemoveZeroes;

+(NSString *) stringFromDouble:(double) number;
+(NSString *) stringFromNumber:(NSNumber *) number;
+(NSNumber *) accuracyForAssetId:(NSString *) assetID;

@end
