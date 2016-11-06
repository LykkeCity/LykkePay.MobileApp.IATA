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

@end
