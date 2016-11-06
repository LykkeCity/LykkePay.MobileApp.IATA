//
//  LWTransferConfirmationView.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransferConfirmationView.h"
#import "LWDetailTableViewCell.h"
#import "LWPinKeyboardView.h"
#import "LWAssetPairModel.h"
#import "LWAssetPairRateModel.h"
#import "LWAssetModel.h"
#import "LWLoadingIndicatorView.h"
#import "LWAuthManager.h"
#import "LWConstants.h"
#import "LWValidator.h"
#import "LWColorizer.h"
#import "LWCache.h"
#import "Macro.h"
#import "UIView+Navigation.h"


@interface LWTransferConfirmationView ()<UITableViewDataSource, LWPinKeyboardViewDelegate> {
    LWPinKeyboardView *pinKeyboardView;
    BOOL               isRequested;
}

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIView           *topView;
@property (weak, nonatomic) IBOutlet UIView           *bottomView;
@property (weak, nonatomic) IBOutlet UITableView      *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar  *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UIButton         *placeOrderButton;
@property (weak, nonatomic) IBOutlet UILabel          *waitingLabel;
@property (weak, nonatomic) IBOutlet LWLoadingIndicatorView *waitingImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;


#pragma mark - Properties

@property (weak, nonatomic) id<LWTransferConfirmationViewDelegate> delegate;


#pragma mark - Utils

- (void)requestOperation;
- (void)cancelOperation;
- (void)updateView;
- (void)registerCellWithIdentifier:(NSString *)identifier name:(NSString *)name;

@end


@implementation LWTransferConfirmationView

static int const kDescriptionRows = 2;
static float const kPinProtectionHeight = 444;
static float const kNoPinProtectionHeight = 256;


#pragma mark - General

+ (LWTransferConfirmationView *)modalViewWithDelegate:(id<LWTransferConfirmationViewDelegate>)delegate {
    
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"LWTransferConfirmationView"
                                                  owner:self options:nil] objectAtIndex:0];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [view sizeToFit];
    
    LWTransferConfirmationView *result = (LWTransferConfirmationView *)view;
    [result setDelegate:delegate];
    [result updateView];
    return result;
}


#pragma mark - Actions

- (void)cancelClicked:(id)sender {
    [self cancelOperation];
}

- (IBAction)confirmClicked:(id)sender {
    [self requestOperation];
}


#pragma mark - Utils

- (void)requestOperation {
    [self setLoading:YES withReason:Localize(@"transfer.receiver.modal.waiting")];
    [self.delegate requestOperationWithHud:NO];
}

- (void)pinRejected {
    [self setLoading:NO withReason:@""];
    if (pinKeyboardView) {
        [pinKeyboardView pinRejected];
    }
}

- (void)cancelOperation {
    [self.delegate cancelClicked];
    [self removeFromSuperview];
}

- (void)updateView {
    [UIView setAnimationsEnabled:NO];
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    self.topView.backgroundColor = [UIColor whiteColor];
    self.topView.opaque = NO;
    
    BOOL const shouldSignOrder = [LWCache instance].shouldSignOrder;
    if (shouldSignOrder) {
        pinKeyboardView = [LWPinKeyboardView new];
        pinKeyboardView.delegate = self;
        pinKeyboardView.hidden = !shouldSignOrder;
        [pinKeyboardView updateView];
        [self.bottomView addSubview:pinKeyboardView];
    }
    else {
        if (pinKeyboardView) {
            [pinKeyboardView removeFromSuperview];
            pinKeyboardView = nil;
        }
    }
    
    self.topViewHeightConstraint.constant = (shouldSignOrder ? kPinProtectionHeight : kNoPinProtectionHeight);
    self.placeOrderButton.hidden = shouldSignOrder;
    
    self.waitingLabel.text = Localize(@"transfer.receiver.modal.waiting");
    [self.navigationItem setTitle:Localize(@"transfer.receiver.modal.title")];
    [self.placeOrderButton setTitle:Localize(@"transfer.receiver.modal.button")
                           forState:UIControlStateNormal];
    
    
    NSString *cancelTitle = Localize(@"transfer.receiver.modal.cancel");
    [self setCancelButtonWithTitle:cancelTitle
                        navigation:self.navigationItem
                            target:self
                          selector:@selector(cancelClicked:)];
    
    self.placeOrderButton.hidden = NO;

#ifdef PROJECT_IATA
    UIFont *fontBar = [UIFont fontWithName:kNavigationBarFontName size:kNavigationBarFontSize];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor colorWithHexString:kLabelFontColor], NSForegroundColorAttributeName,
                                fontBar, NSFontAttributeName,
                                nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:kNavigationTintColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHexString:kMainElementsColor]];
#else
#endif
    
    [self registerCellWithIdentifier:kDetailTableViewCellIdentifier
                                name:kDetailTableViewCell];
    
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self setLoading:NO withReason:@""];
}

- (void)setLoading:(BOOL)loading withReason:(NSString *)reason {
    isRequested = loading;
    
    // update values    
    self.navigationItem.leftBarButtonItem.enabled = !loading;
    self.placeOrderButton.hidden = loading;
    self.waitingLabel.hidden = !loading;
    self.waitingLabel.text = reason;
    
    if (pinKeyboardView) {
        pinKeyboardView.hidden = loading;
    }
    
    [self.waitingImageView setLoading:loading];
}

- (void)registerCellWithIdentifier:(NSString *)identifier name:(NSString *)name {
    UINib *nib = [UINib nibWithNibName:name bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kDescriptionRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *const titles[kDescriptionRows] = {
        Localize(@"transfer.receiver.modal.receiver"),
        Localize(@"transfer.receiver.modal.amount")
    };
    
    NSString *const values[kDescriptionRows] = {
        self.recepientName,
        [NSString stringWithFormat:@"%@ %@", self.recepientAmount, [LWAssetModel assetByIdentity:self.selectedAssetId fromList:[LWCache instance].baseAssets]]
    };
    
    LWDetailTableViewCell *cell = (LWDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kDetailTableViewCellIdentifier];
    [cell setLightDetails];
    
    [cell setWhitePalette];
    [cell setNormalDetails];
    cell.titleLabel.text = titles[indexPath.row];
    cell.detailLabel.text = values[indexPath.row];
    
    return cell;
}


#pragma mark - LWPinKeyboardViewDelegate

- (void)pinEntered:(NSString *)pin {
    [self.delegate checkPin:pin];
}

- (void)pinCanceled {
    [self removeFromSuperview];
    [self.delegate cancelClicked];
}

- (void)pinAttemptEnds {
    [self removeFromSuperview];
    [self.delegate noAttemptsForPin];
}

@end
