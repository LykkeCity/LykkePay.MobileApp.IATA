//
//  LWExchangeConfirmationView.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeConfirmationView.h"
#import "LWDetailTableViewCell.h"
#import "LWPinKeyboardView.h"
#import "LWAssetPairModel.h"
#import "LWAssetPairRateModel.h"
#import "LWLoadingIndicatorView.h"
#import "LWAuthManager.h"
#import "LWConstants.h"
#import "LWValidator.h"
#import "LWCache.h"
#import "Macro.h"
#import "UIView+Navigation.h"
#import "LWKeychainManager.h"

@interface LWExchangeConfirmationView () <UITableViewDataSource, UITableViewDelegate, LWPinKeyboardViewDelegate> {
    LWPinKeyboardView *pinKeyboardView;
    BOOL               isRequested;
    
    UIView *shadowView;
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

@property (weak, nonatomic) IBOutlet UIView *touchCatchView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;


#pragma mark - Properties

@property (weak, nonatomic) id<LWExchangeConfirmationViewDelegate> delegate;


#pragma mark - Utils

- (void)requestOperation;
- (void)cancelOperation;
- (void)updateView;
- (void)registerCellWithIdentifier:(NSString *)identifier name:(NSString *)name;

@end


@implementation LWExchangeConfirmationView


static int const kDescriptionRows = 3;
static float const kPinProtectionHeight = 488;
static float const kNoPinProtectionHeight = 360;


#pragma mark - General

-(void) awakeFromNib
{
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelOperation)];
    [self.touchCatchView addGestureRecognizer:gesture];
    self.tableView.delegate=self;
    if([UIScreen mainScreen].bounds.size.width==320)
    {
        _topViewHeightConstraint.constant=520;
    }
}

+ (LWExchangeConfirmationView *)modalViewWithDelegate:(id<LWExchangeConfirmationViewDelegate>)delegate {

    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"LWExchangeConfirmationView"
                                                  owner:self options:nil] objectAtIndex:0];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [view sizeToFit];
    
    LWExchangeConfirmationView *result = (LWExchangeConfirmationView *)view;
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
    [self setLoading:YES withReason:Localize(@"exchange.assets.modal.waiting")];
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
    [self hide];
}

-(void) pinKeyboardViewPressedFingerPrint
{
    [self hide];
    if([self.delegate respondsToSelector:@selector(exchangeConfirmationViewPressedFingerPrint)])
        [self.delegate exchangeConfirmationViewPressedFingerPrint];
    
        
}

-(void) show
{
    shadowView=[[UIView alloc] initWithFrame:self.superview.bounds];
    shadowView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.5];
    shadowView.alpha=0;
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.superview insertSubview:shadowView belowSubview:self];

    [UIView animateWithDuration:0.5 animations:^{
        shadowView.alpha=1;
        self.iPadNavShadowView.alpha=1;
    }];
}

- (void)updateView {
//    [UIView setAnimationsEnabled:NO];
    
//    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    self.topView.backgroundColor = [UIColor whiteColor];
    self.topView.opaque = NO;
    self.backgroundColor=nil;
    
    BOOL const shouldSignOrder = [LWCache instance].shouldSignOrder;
    if (shouldSignOrder) {
        pinKeyboardView = [LWPinKeyboardView new];
        pinKeyboardView.delegate = self;
        pinKeyboardView.hidden = !shouldSignOrder;
        [pinKeyboardView updateView];
        [self.bottomView addSubview:pinKeyboardView];
        pinKeyboardView.frame=self.bottomView.bounds;
        pinKeyboardView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    else {
        if (pinKeyboardView) {
            [pinKeyboardView removeFromSuperview];
            pinKeyboardView = nil;
        }
    }
    
    if(shouldSignOrder==NO)
        self.topViewHeightConstraint.constant=kNoPinProtectionHeight;
//    self.topViewHeightConstraint.constant = (shouldSignOrder ? kPinProtectionHeight : kNoPinProtectionHeight);
    self.placeOrderButton.hidden = shouldSignOrder;
    
    self.waitingLabel.text = Localize(@"exchange.assets.modal.waiting");
    UILabel *label=[[UILabel alloc] init];
    label.attributedText=[[NSAttributedString alloc] initWithString:@"ORDER SUMMARY" attributes:@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]}];
    [label sizeToFit];
    [self.navigationItem setTitleView:label];
//    [self.navigationItem setTitle:Localize(@"exchange.assets.modal.title")];
    [self.placeOrderButton setTitle:Localize(@"exchange.assets.modal.button")
                           forState:UIControlStateNormal];
    
    NSString *cancelTitle = @" CANCEL";
    [self setCancelButtonWithTitle:cancelTitle
                        navigation:self.navigationItem
                            target:self
                          selector:@selector(cancelClicked:)];
    
    self.placeOrderButton.hidden = NO;
    [LWValidator setButton:self.placeOrderButton enabled:YES];
    
    [self registerCellWithIdentifier:kDetailTableViewCellIdentifier
                                name:kDetailTableViewCell];
    
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self setLoading:NO withReason:@""];
}

- (void)setLoading:(BOOL)loading withReason:(NSString *)reason {
    isRequested = loading;
    
    // update values
    [self setRateString:_rateString];
    [self setTotalString:_totalString];
    
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

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL flagReverse=self.assetPair.inverted;
    if((self.assetDealType==LWAssetDealTypeSell && flagReverse) || (self.assetDealType==LWAssetDealTypeBuy && !flagReverse))
        flagReverse=!flagReverse;
    
    NSString *const titles[kDescriptionRows] = {
        flagReverse?Localize(@"exchange.assets.buy.sum"):Localize(@"exchange.assets.buy.total"),
//        Localize(@"exchange.assets.buy.sum"),
        Localize(@"exchange.assets.buy.price"),
        flagReverse?Localize(@"exchange.assets.buy.total"):Localize(@"exchange.assets.buy.sum"),

//        Localize(@"exchange.assets.buy.total")
    };
    
    NSString *const values[kDescriptionRows] = {
        self.volumeString,
        self.rateString,
        self.totalString
    };
    
    LWDetailTableViewCell *cell = (LWDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kDetailTableViewCellIdentifier];
    if (indexPath.row == kDescriptionRows - 1) {
        [cell setRegularDetails];
    }
    else {
        [cell setLightDetails];
    }

    [cell setWhitePalette];
    cell.titleLabel.text = titles[indexPath.row];
    cell.detailLabel.text = values[indexPath.row];
    
    return cell;
}


#pragma mark - Setters

- (void)setRateString:(NSString *)rateString {
    _rateString = rateString;

    if (!isRequested) {
        LWDetailTableViewCell *cell = (LWDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell.detailLabel.text = rateString;
    }
}

- (void)setTotalString:(NSString *)totalString {
    _totalString = totalString;

    if (!isRequested) {
        LWDetailTableViewCell *cell = (LWDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        cell.detailLabel.text = totalString;
    }
}


#pragma mark - LWPinKeyboardViewDelegate

- (void)pinEntered:(NSString *)pin {
    if([[LWKeychainManager instance].pin isEqualToString:pin])
        [self requestOperation];
    else
        [self pinRejected];
    
    
//    [self.delegate checkPin:pin];
}

-(void) hide
{
    [UIView animateWithDuration:0.5 animations:^{
        shadowView.alpha=0;
        self.iPadNavShadowView.alpha=0;
        self.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height*1.5);
    } completion:^(BOOL finished){
        [self.iPadNavShadowView removeFromSuperview];
        [shadowView removeFromSuperview];
            [self removeFromSuperview];
        
    }];
}

- (void)pinCanceled {
    [self hide];
    [self.delegate cancelClicked];
}

- (void)pinAttemptEnds {
    [self hide];
    [self.delegate noAttemptsForPin];
}

@end
