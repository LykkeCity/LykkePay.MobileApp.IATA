//
//  LWAuthManager.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWNetAccessor.h"
#import "LWRegistrationData.h"
#import "LWAuthenticationData.h"
#import "LWPacketKYCSendDocument.h"
#import "LWAuthSteps.h"

@class LWAuthManager;
@class LWLykkeWalletsData;
@class LWBankCardsAdd;
@class LWAssetModel;
@class LWPersonalData;
@class LWAssetPairModel;
@class LWAssetPairRateModel;
@class LWAppSettingsModel;
@class LWAssetDescriptionModel;
@class LWAssetDealModel;
@class LWAssetBlockchainModel;
@class LWTransactionsModel;
@class LWPersonalDataModel;
@class LWTransactionMarketOrderModel;
@class LWExchangeInfoModel;
@class LWGraphPeriodRatesModel;


@protocol LWAuthManagerDelegate<NSObject>
@optional
- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context;
- (void)authManager:(LWAuthManager *)manager didCheckRegistration:(BOOL)isRegistered email:(NSString *)email;
- (void)authManagerDidRegister:(LWAuthManager *)manager;
- (void)authManagerDidRegisterGet:(LWAuthManager *)manager KYCStatus:(NSString *)status isPinEntered:(BOOL)isPinEntered personalData:(LWPersonalData *)personalData;
- (void)authManagerDidAuthenticate:(LWAuthManager *)manager KYCStatus:(NSString *)status isPinEntered:(BOOL)isPinEntered;
- (void)authManager:(LWAuthManager *)manager didCheckDocumentsStatus:(LWDocumentsStatus *)status;
- (void)authManagerDidSendDocument:(LWAuthManager *)manager ofType:(KYCDocumentType)docType;
- (void)authManager:(LWAuthManager *)manager didGetKYCStatus:(NSString *)status personalData:(LWPersonalData *)personalData;
- (void)authManagerDidSetKYCStatus:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didValidatePin:(BOOL)isValid;
- (void)authManagerDidSetPin:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didReceiveRestrictedCountries:(NSArray *)countries;
- (void)authManager:(LWAuthManager *)manager didReceivePersonalData:(LWPersonalDataModel *)data;
- (void)authManager:(LWAuthManager *)manager didReceiveLykkeData:(LWLykkeWalletsData *)data;
- (void)authManagerDidNotAuthorized:(LWAuthManager *)manager;
- (void)authManagerDidCardAdd:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didGetBaseAssets:(NSArray *)assets;
- (void)authManager:(LWAuthManager *)manager didGetBaseAsset:(LWAssetModel *)asset;
- (void)authManagerDidSetAsset:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didGetAssetPair:(LWAssetPairModel *)assetPair;
- (void)authManager:(LWAuthManager *)manager didGetAssetPairs:(NSArray *)assetPairs;
- (void)authManager:(LWAuthManager *)manager didGetAssetPairRate:(LWAssetPairRateModel *)assetPairRate;
- (void)authManager:(LWAuthManager *)manager didGetAssetPairRates:(NSArray *)assetPairRates;
- (void)authManager:(LWAuthManager *)manager didGetAssetDescription:(LWAssetDescriptionModel *)assetDescription;
- (void)authManager:(LWAuthManager *)manager didGetAppSettings:(LWAppSettingsModel *)appSettings;
- (void)authManager:(LWAuthManager *)manager didReceiveDealResponse:(LWAssetDealModel *)purchase;
- (void)authManagerDidSetSignOrders:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didGetBlockchainTransaction:(LWAssetBlockchainModel *)blockchain;
- (void)authManager:(LWAuthManager *)manager didGetBlockchainCashTransaction:(LWAssetBlockchainModel *)blockchain;
- (void)authManager:(LWAuthManager *)manager didGetBlockchainExchangeTransaction:(LWAssetBlockchainModel *)blockchain;
- (void)authManager:(LWAuthManager *)manager didGetBlockchainTransferTransaction:(LWAssetBlockchainModel *)blockchain;
- (void)authManager:(LWAuthManager *)manager didReceiveTransactions:(LWTransactionsModel *)transactions;
- (void)authManager:(LWAuthManager *)manager didReceiveMarketOrder:(LWAssetDealModel *)marketOrder;
- (void)authManagerDidSendBlockchainEmail:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didReceiveExchangeInfo:(LWExchangeInfoModel *)exchangeInfo;
- (void)authManager:(LWAuthManager *)manager didReceiveAssetDicts:(NSArray *)assetDicts;
- (void)authManagerDidCashOut:(LWAuthManager *)manager;
- (void)authManagerDidTransfer:(LWAuthManager *)manager;
- (void)authManagerDidSendValidationEmail:(LWAuthManager *)manager;
- (void)authManagerDidCheckValidationEmail:(LWAuthManager *)manager passed:(BOOL)passed;
- (void)authManagerDidSendValidationPhone:(LWAuthManager *)manager;
- (void)authManagerDidCheckValidationPhone:(LWAuthManager *)manager passed:(BOOL)passed;
- (void)authManagerDidSetFullName:(LWAuthManager *)manager;
- (void)authManager:(LWAuthManager *)manager didGetCountryCodes:(NSArray *)countryCodes;
- (void)authManager:(LWAuthManager *)manager didGetGraphPeriods:(NSArray *)graphPeriods;
- (void)authManager:(LWAuthManager *)manager didGetGraphPeriodRates:(LWGraphPeriodRatesModel *)periodRates;

@end


@interface LWAuthManager : LWNetAccessor {
    
}

SINGLETON_DECLARE

@property (weak, nonatomic) id<LWAuthManagerDelegate> delegate;

@property (readonly, nonatomic) BOOL               isAuthorized;
@property (readonly, nonatomic) LWRegistrationData *registrationData;
@property (readonly, nonatomic) LWDocumentsStatus  *documentsStatus;


#pragma mark - Common

- (void)requestEmailValidation:(NSString *)email;
- (void)requestAuthentication:(LWAuthenticationData *)data;
- (void)requestRegistration:(LWRegistrationData *)data;
- (void)requestRegistrationGet;
- (void)requestDocumentsToUpload;
- (void)requestSendDocument:(KYCDocumentType)docType image:(UIImage *)image;
- (void)requestSendDocumentBin:(KYCDocumentType)docType image:(UIImage *)image;
- (void)requestKYCStatusGet;
- (void)requestKYCStatusSet;
- (void)requestPinSecurityGet:(NSString *)pin;
- (void)requestPinSecuritySet:(NSString *)pin;
- (void)requestRestrictedCountries;
- (void)requestPersonalData;
- (void)requestLykkeWallets;
- (void)requestSendLog:(NSString *)log;
- (void)requestAddBankCard:(LWBankCardsAdd *)card;
- (void)requestBaseAssets;
- (void)requestBaseAssetGet;
- (void)requestBaseAssetSet:(NSString *)assetId;
- (void)requestAssetPair:(NSString *)pairId;
- (void)requestAssetPairs;
- (void)requestAssetPairRate:(NSString *)pairId;
- (void)requestAssetPairRates;
- (void)requestAssetDescription:(NSString *)assetId;
- (void)requestAppSettings;
- (void)requestPurchaseAsset:(NSString *)asset assetPair:(NSString *)assetPair volume:(NSNumber *)volume rate:(NSNumber *)rate;
- (void)requestSellAsset:(NSString *)asset assetPair:(NSString *)assetPair volume:(NSNumber *)volume rate:(NSNumber *)rate;
- (void)requestSignOrders:(BOOL)shouldSignOrders;
- (void)requestBlockchainOrderTransaction:(NSString *)orderId;
- (void)requestBlockchainCashTransaction:(NSString *)cashOperationId;
- (void)requestBlockchainExchangeTransaction:(NSString *)exchnageOperationId;
- (void)requestBlockchainTransferTrnasaction:(NSString *)transferOperationId;
- (void)requestTransactions:(NSString *)assetId;
- (void)requestMarketOrder:(NSString *)orderId;
- (void)requestEmailBlockchain:(NSString *) assetId;
- (void)requestExchangeInfo:(NSString *)exchangeId;
- (void)requestDictionaries;
- (void)requestCashOut:(NSNumber *)amount assetId:(NSString *)assetId multiSig:(NSString *)multiSig;
- (void)requestTransfer:(NSString *)assetId amount:(NSNumber *)amount recipient:(NSString *)recepientId;
- (void)requestVerificationEmail:(NSString *)email;
- (void)requestVerificationEmail:(NSString *)email forCode:(NSString *)code;
- (void)requestVerificationPhone:(NSString *)phone;
- (void)requestVerificationPhone:(NSString *)phone forCode:(NSString *)code;
- (void)requestSetFullName:(NSString *)fullName;
- (void)requestCountyCodes;
- (void)requestGraphPeriods;
- (void)requestGraphPeriodRates:(NSString *)period assetId:(NSString *)assetId points:(NSNumber *)points;

#pragma mark - Static methods

+ (BOOL)isAuthneticationFailed:(NSURLResponse *)response;
+ (BOOL)isNotOk:(NSURLResponse *)response;
+ (BOOL)isInternalServerError:(NSURLResponse *)response;

@end
