//
//  LWCountrySelectorPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthenticatedTablePresenter.h"


@protocol LWCountrySelectorPresenterDelegate <NSObject>
@required
- (void)countrySelected:(NSString *)name code:(NSString *)code prefix:(NSString *)prefix;
@end


@interface LWCountrySelectorPresenter : LWAuthenticatedTablePresenter {
    
}

@property (nonatomic, weak) id<LWCountrySelectorPresenterDelegate> delegate;

@end
