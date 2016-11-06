//
//  LWAuthComplexPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 06.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthPresenter.h"


@interface LWAuthComplexPresenter : LWAuthPresenter {
    
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UITableView *tableView;


#pragma mark - Utils

- (void)registerCellWithIdentifier:(NSString *)identifier name:(NSString *)name;
- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void)setRefreshControl;
- (void)startRefreshControl;
- (void)stopRefreshControl;

@end
