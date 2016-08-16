//
//  LWCache.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"

@class LWLykkeData;
@class LWPersonalDataModel;

typedef NS_ENUM(NSUInteger, PushNotificationsStatus) {
    PushNotificationsStatusUnknown=0,
    PushNotificationsStatusDisabled=1,
    PushNotificationsStatusEnabled=2
    
};

@interface LWCache : NSObject {
    
}

SINGLETON_DECLARE


#pragma mark - Properties

@property PushNotificationsStatus pushNotificationsStatus;

@property (copy, nonatomic) NSNumber *refreshTimer;
@property (copy, nonatomic) NSString *baseAssetId;
@property (copy, nonatomic) NSString *baseAssetSymbol;
@property (copy, nonatomic) NSArray  *baseAssets; // Array of LWAssetModel items

@property (strong, nonatomic) LWLykkeData *walletsData;

@property (strong, nonatomic) NSString *cashInVisaURL;
@property (strong, nonatomic) NSString *cashInVisaSuccessURL;
@property (strong, nonatomic) NSString *cashInVisaFailURL;

@property (strong, nonatomic) NSString *UrlsToFormatRegex;

@property (copy, nonatomic) NSArray *allAssets;

@property (copy, nonatomic) NSString *depositUrl;
@property (copy, nonatomic) NSString *multiSig;
@property (copy, nonatomic) NSString *coloredMultiSig;

@property (copy, nonatomic) NSString *refundAddress;
@property BOOL refundSendAutomatically;
@property int refundDaysValidAfter;

@property (copy, nonatomic) NSString *serverAPIVersion;

@property (strong, nonatomic) LWPersonalDataModel *lastCardPaymentData;

// Array of LWAssetsDictionaryItem items
@property (copy, nonatomic) NSArray  *assetsDict;
@property (assign, nonatomic) BOOL shouldSignOrder;
@property (assign, nonatomic) BOOL debugMode;

- (BOOL)isMultisigAvailable;

+(BOOL) shouldHideDepositForAssetId:(NSString *)assetID;
+(BOOL) shouldHideWithdrawForAssetId:(NSString *)assetID;

+(BOOL) isBankCardDepositEnabledForAssetId:(NSString *) assetID;
+(BOOL) isSwiftDepositEnabledForAssetId:(NSString *) assetID;


+(BOOL) isBaseAsset:(NSString *) assetId;

+(NSString *) currentAppVersion;

-(NSString *) currencySymbolForAssetId:(NSString *) assetId;
+(NSString *) nameForAsset:(NSString *) assetId;



@end
