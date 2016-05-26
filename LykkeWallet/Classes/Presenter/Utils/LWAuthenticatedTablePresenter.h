//
//  LWAuthenticatedTablePresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKTablePresenter.h"


@interface LWAuthenticatedTablePresenter : TKTablePresenter {
    
}


#pragma mark - Utils

- (void)registerCellWithIdentifier:(NSString *)identifier forName:(NSString *)name;

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath;

@end
