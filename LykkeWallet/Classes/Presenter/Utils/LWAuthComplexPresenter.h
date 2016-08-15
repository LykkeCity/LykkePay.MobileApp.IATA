//
//  LWAuthComplexPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 06.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthPresenter.h"
#import "LWMathKeyboardView.h"


@interface LWAuthComplexPresenter : LWAuthPresenter {
    
}


@property (strong, nonatomic) LWMathKeyboardView *keyboardView;

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UITableView *tableView;


#pragma mark - Utils

-(void) showCustomKeyboard;
-(void) hideCustomKeyboard;

- (void)registerCellWithIdentifier:(NSString *)identifier name:(NSString *)name;
- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void)setRefreshControl;
- (void)startRefreshControl;
- (void)stopRefreshControl;

-(void) showCopied;

@end
