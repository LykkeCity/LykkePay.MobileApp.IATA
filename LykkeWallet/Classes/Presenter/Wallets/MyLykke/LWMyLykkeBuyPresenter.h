//
//  LWMyLykkeBuyPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@interface LWMyLykkeBuyPresenter : LWAuthComplexPresenter

@property id delegate;

@end


@protocol LWMyLykkeBuyPresenterDelegate

-(void) buyPresenterChosenAsset:(NSString *) assetId;
-(void) buyPresenterSelectedTransfer;

@end
