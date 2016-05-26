//
//  LWWalletFormPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWWalletFormPresenter.h"
#import "LWWalletPagePresenter.h"
#import "LWWalletConfirmPresenter.h"
#import "LWAuthManager.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "LWStringUtils.h"
#import "LWConstants.h"
#import "LWBankCardsAdd.h"
#import "LWBankCardsData.h"
#import "LWKeyboardToolbar.h"
#import "UIColor+Generic.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"


@interface LWWalletFormPresenter ()<LWAuthManagerDelegate, LWTextFieldDelegate, LWKeyboardToolbarDelegate, UIPageViewControllerDataSource> {
    UIColor *navigationTintColor;
    LWTextField *cardNumberTextField;
    LWTextField *cardExpireTextField;
    LWTextField *cardOwnerTextField;
    LWTextField *cardCodeTextField;
    
    LWTextField       *activeField;
    LWKeyboardToolbar *keyboardToolbar;
    
    UIPageViewController *pageController;
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIView       *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *bankCardsView;
@property (weak, nonatomic) IBOutlet TKContainer *cardNumberContainer;
@property (weak, nonatomic) IBOutlet TKContainer *cardExpireContainer;
@property (weak, nonatomic) IBOutlet TKContainer *cardOwnerContainer;
@property (weak, nonatomic) IBOutlet TKContainer *cardCodeContainer;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bankCardHeightConstraint;


#pragma mark - Utils

- (void)updateInsetsWithHeight:(CGFloat)height;
- (void)createWallets;
- (void)createTextFields;
- (BOOL)isCardsExists;
- (BOOL)canProceed;
- (NSInteger)bankCardsCount;

@end


@implementation LWWalletFormPresenter


#pragma mark - Constants

static CGFloat const kBanksHeight   = 190.0;
static CGFloat const kContentFullscreenHeight = 560.0;
static CGFloat const kContentKeyboardHeight = 500.0;

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createWallets];
    [self createTextFields];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setBackButton];
    
    self.bankCardHeightConstraint.constant = [self isCardsExists] ? kBanksHeight : 0.0;
    
    // check button state
    [LWValidator setButton:self.submitButton enabled:self.canProceed];

    self.observeKeyboardEvents = YES;
    [LWAuthManager instance].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateInsetsWithHeight:0.0];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.barTintColor = navigationTintColor;

    [super viewWillDisappear:animated];
}


#pragma mark - Setup

- (void)localize {
    self.title = Localize(@"wallets.cardform.title");
    
    self.submitButton.titleLabel.text = Localize(@"wallets.cardform.card.submitButton");
    self.descriptionLabel.text = Localize(@"wallets.cardform.card.description");
}

- (void)colorize {
    // detect color depends on bank cards list
    navigationTintColor = self.navigationController.navigationBar.barTintColor;

#ifdef PROJECT_IATA
#else
    UIColor *color = ([self isCardsExists]
                      ? [UIColor colorWithHexString:kMainGrayElementsColor]
                      : [UIColor colorWithHexString:kMainWhiteElementsColor]);
    [self.navigationController.navigationBar setBarTintColor:color];
    self.bankCardsView.backgroundColor = color;
#endif
    
    self.warningLabel.textColor = [UIColor redColor];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidCardAdd:(LWAuthManager *)manager {
    [self setLoading:NO];
    
    LWWalletConfirmPresenter *form = [LWWalletConfirmPresenter new];
    [self.navigationController pushViewController:form animated:YES];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}


#pragma mark - LWTextFieldDelegate

- (void)textFieldDidChangeValue:(LWTextField *)textFieldInput {
    if (!self.isVisible) { // prevent from being processed if controller is not presented
        return;
    }

    if (textFieldInput == cardNumberTextField) {
        textFieldInput.valid = [LWValidator validateCardNumber:textFieldInput.text];
    }
    else if (textFieldInput == cardExpireTextField) {
        textFieldInput.valid = [LWValidator validateCardExpiration:textFieldInput.text];
    }
    else if (textFieldInput == cardOwnerTextField) {
        textFieldInput.valid = [LWValidator validateCardOwner:textFieldInput.text];
    }
    else if (textFieldInput == cardCodeTextField) {
        textFieldInput.valid = [LWValidator validateCardCode:textFieldInput.text];
    }

    // check button state
    [LWValidator setButton:self.submitButton enabled:self.canProceed];
}

- (BOOL)textField:(LWTextField *)textField shouldChangeCharsInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string isEqualToString:@""]) {
        if (textField == cardExpireTextField) {
            textField.willRemoveText = YES;
        }
        return YES;
    }
    if (textField == cardNumberTextField) {
        if (textField.text.length > 18) {
            return NO;
        }
    } else if (textField == cardExpireTextField) {
        textField.willRemoveText = NO;
        if (textField.text.length > 4) {
            return NO;
        }
    } else if (textField == cardCodeTextField) {
        if (textField.text.length > 2) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Actions

- (IBAction)submitClicked:(id)sender {
    [self.view endEditing:YES];

    [self setLoading:YES];
    
    LWBankCardsAdd *data = [LWBankCardsAdd new];
    data.bankNumber = cardNumberTextField.text;
    data.name = cardOwnerTextField.text;
    data.type = @"Visa";
    data.monthTo = [LWStringUtils monthFromExpiration:cardExpireTextField.text];
    data.yearTo = [LWStringUtils yearFromExpiration:cardExpireTextField.text];
    data.cvc = cardCodeTextField.text;
    
    [[LWAuthManager instance] requestAddBankCard:data];
}


#pragma mark - Utils

- (void)updateInsetsWithHeight:(CGFloat)height {
    if (height > 0) {
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, kContentKeyboardHeight);
    }
    else {
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, kContentFullscreenHeight);
    }
}

- (void)createWallets {
    if ([self bankCardsCount] <= 0) {
        return;
    }
    
    // create wallet pages
    pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    pageController.dataSource = self;

    [[pageController view] setFrame:CGRectMake(0, 0,
                                               self.bankCardsView.bounds.size.width,
                                               self.bankCardsView.bounds.size.height)];
    
    LWWalletPagePresenter *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [pageController setViewControllers:viewControllers
                             direction:UIPageViewControllerNavigationDirectionForward
                              animated:NO completion:nil];
    
    [self addChildViewController:pageController];
    [self.bankCardsView addSubview:[pageController view]];
    [pageController didMoveToParentViewController:self];
}

- (void)createTextFields {
    int const kDefaultRightOffset = 10;
    
    // card number
    cardNumberTextField = [LWTextField
                           createTextFieldForContainer:self.cardNumberContainer withPlaceholder:Localize(@"wallets.cardform.card.number.placeholder")];
    cardNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    cardNumberTextField.delegate = self;
    cardNumberTextField.rightOffset = kDefaultRightOffset;
    [cardNumberTextField addSelector:@selector(creditCardNumberFormatter:) targer:self];
    
    // card expiration date
    cardExpireTextField = [LWTextField
                           createTextFieldForContainer:self.cardExpireContainer withPlaceholder:Localize(@"wallets.cardform.card.expire.placeholder")];
    cardExpireTextField.keyboardType = UIKeyboardTypeNumberPad;
    cardExpireTextField.viewMode = UITextFieldViewModeNever;
    cardExpireTextField.delegate = self;
    cardExpireTextField.rightOffset = kDefaultRightOffset;
    [cardExpireTextField addSelector:@selector(creditCardExpiryFormatter:) targer:self];
    
    // card owner name
    cardOwnerTextField = [LWTextField
                          createTextFieldForContainer:self.cardOwnerContainer withPlaceholder:Localize(@"wallets.cardform.card.owner.placeholder")];
    cardOwnerTextField.keyboardType = UIKeyboardTypeASCIICapable;
    cardOwnerTextField.rightOffset = kDefaultRightOffset;
    cardOwnerTextField.delegate = self;
    
    // cvc card code
    cardCodeTextField = [LWTextField
                         createTextFieldForContainer:self.cardCodeContainer withPlaceholder:Localize(@"wallets.cardform.card.code.placeholder")];
    cardCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    cardCodeTextField.viewMode = UITextFieldViewModeNever;
    cardCodeTextField.secure = YES;
    cardCodeTextField.maxLength = 3;
    cardCodeTextField.rightOffset = kDefaultRightOffset;
    cardCodeTextField.delegate = self;
    
    keyboardToolbar = [LWKeyboardToolbar toolbarWithDelegate:self];
}

- (BOOL)isCardsExists {
    BOOL const isCardsExists = (self.bankCards && self.bankCards.count > 0);
    return isCardsExists;
}

- (BOOL)canProceed {
    return cardNumberTextField.valid && cardExpireTextField.valid && cardOwnerTextField.valid && cardCodeTextField.valid;
}

- (NSInteger)bankCardsCount {
    NSInteger const count = (self.bankCards ? self.bankCards.count : 0);
    return count;
}


#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(LWWalletPagePresenter *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(LWWalletPagePresenter *)viewController index];
    
    index++;
    if (index == [self bankCardsCount]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (LWWalletPagePresenter *)viewControllerAtIndex:(NSUInteger)index {
    
    LWWalletPagePresenter *childViewController = [[LWWalletPagePresenter alloc] initWithNibName:@"LWWalletPagePresenter" bundle:nil];
    childViewController.index = index;
    childViewController.cardData = [self.bankCards objectAtIndex:index];
    
    return childViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    NSInteger const size = [self bankCardsCount];
    return size;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}


#pragma mark - Keyboard

- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat const offset = 35.0;
    CGFloat const height = rect.size.height + keyboardToolbar.frame.size.height + offset;
    [self updateInsetsWithHeight:height];
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
    [self updateInsetsWithHeight:0.0];
}

- (void)textFieldDidBeginEditing:(LWTextField *)textField
{
    activeField = textField;
    [textField setupAccessoryView:keyboardToolbar];
}


#pragma mark - LWKeyboardToolbarDelegate

- (void)prevClicked {
    if (activeField == cardNumberTextField) {
        [cardCodeTextField showKeyboard];
    }
    else if (activeField == cardExpireTextField) {
        [cardNumberTextField showKeyboard];
    }
    else if (activeField == cardOwnerTextField) {
        [cardExpireTextField showKeyboard];
    }
    else if (activeField == cardCodeTextField) {
        [cardOwnerTextField showKeyboard];
    }
}

- (void)nextClicked {
    if (activeField == cardNumberTextField) {
        [cardExpireTextField showKeyboard];
    }
    else if (activeField == cardExpireTextField) {
        [cardOwnerTextField showKeyboard];
    }
    else if (activeField == cardOwnerTextField) {
        [cardCodeTextField showKeyboard];
    }
    else if (activeField == cardCodeTextField) {
        [cardNumberTextField showKeyboard];
    }
}


#pragma mark - Text Field

- (void)creditCardNumberFormatter:(id)sender {
    NSString *formattedText = [LWStringUtils formatCreditCard:cardNumberTextField.text];
    if (![formattedText isEqualToString:cardNumberTextField.text]) {
        cardNumberTextField.text = formattedText;
    }
    if (cardNumberTextField.text.length == 19) {
        [cardNumberTextField resignFirstResponder];
        [cardNumberTextField becomeFirstResponder];
    }
}

- (void)creditCardExpiryFormatter:(id)sender {
    NSString *formattedText = [LWStringUtils formatCreditCardExpiry:cardExpireTextField.rawText shouldRemoveText:cardExpireTextField.willRemoveText];
    if (![formattedText isEqualToString:cardExpireTextField.text]) {
        cardExpireTextField.text = formattedText;
    }
}

@end
