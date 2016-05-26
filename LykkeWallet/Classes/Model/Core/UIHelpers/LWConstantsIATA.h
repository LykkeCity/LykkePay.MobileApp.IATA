//
//  LWConstants.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 24.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 List of Gotham Fonts
 GothamPro-Medium
 GothamPro
 GothamPro-Light
 GothamPro-Bold
 */


#pragma mark - Server Constants

#define kProductionServer  @"api.lykkex.com"

#define kStagingTestServer @"lykke-api-test.azurewebsites.net"
#define kDevelopTestServer @"lykke-api-dev.azurewebsites.net"
#define kDemoTestServer    @"lykke-api-staging.azurewebsites.net"


#pragma mark - General Constants

#define kFontBold @"GothamPro-Bold"
#define kFontLight @"GothamPro-Light"
#define kFontRegular @"GothamPro"
#define kFontSemibold @"GothamPro-Medium"

#define kMainElementsColor @"00B6E0"
#define kMainWhiteElementsColor @"FFFFFF"
#define kMainDarkElementsColor @"00B6E0"
#define kMainGrayElementsColor @"EAEDEF"

#define kAssetEnabledItemColor  @"FFFFFF"
#define kAssetDisabledItemColor @"FFFFFF"

#define kErrorTextColor         @"FF2E2E"

#define kMaxImageServerSize 1980
#define kMaxImageServerBytes 3145728


#pragma mark - ABPadView

static NSString *const kABPadBorderColor   = @"D3D6DB";
static NSString *const kABPadSelectedColor = @"00B6E0";


#pragma mark - Label Constants

static NSString *const kLabelFontColor = @"3F4D60";


#pragma mark - Button Constants

static float     const kButtonFontSize  = 15.0;
static NSString *const kButtonFontName  = kFontSemibold;
static NSString *const kDisabledButtonFontColor = @"FFFFFF";
static NSString *const kEnabledButtonFontColor = @"FFFFFF";
static NSString *const kSellAssetButtonColor = @"FF3E2E";


#pragma mark - Text Field Constants

#define kDefaultLeftTextFieldOffset  10
#define kDefaultRigthTextFieldOffset 30
#define kDefaultTextFieldPlaceholder @"3F4D60"
static float     const kTextFieldFontSize  = 17.0;
static NSString *const kTextFieldFontColor = @"3F4D60";
static NSString *const kTextFieldFontName  = kFontRegular;


#pragma mark - Tab Bar Constants

static NSString *const kTabBarBackgroundColor   = @"134475";
static NSString *const kTabBarTintColor         = @"2E7597";
static NSString *const kTabBarSelectedTintColor = @"FFFFFF";


#pragma mark - Navigation Bar Constants

static NSString *const kNavigationTintColor     = @"134475";
static NSString *const kNavigationBarTintColor  = @"FFFFFF";
static NSString *const kNavigationBarGrayColor  = kMainGrayElementsColor;
static NSString *const kNavigationBarWhiteColor = kMainWhiteElementsColor;

static float     const kNavigationBarFontSize   = 21.0;
static NSString *const kNavigationBarFontColor  = @"FFFFFF";
static NSString *const kNavigationBarFontName   = kFontSemibold;

static float     const kModalNavBarFontSize     = 15.0;
static NSString *const kModalNavBarFontName     = kFontRegular;

static float     const kTableCellTransferFontSize = 15.0;

#pragma mark - Page Control Constants

static NSString *const kPageControlDotColor       = @"D3D6DB";
static NSString *const kPageControlActiveDotColor = @"134475";


#pragma mark - Asset Colors

static float     const kAssetDetailsFontSize      = 17.0;
static NSString *const kAssetChangePlusColor      = @"2DB700";
static NSString *const kAssetChangeMinusColor     = @"FF434D";


#pragma mark - Table Cells

static float     const kTableCellDetailFontSize   = 22.0;
static NSString *const kTableCellLightFontName    = kFontLight;
static NSString *const kTableCellRegularFontName  = kFontRegular;

