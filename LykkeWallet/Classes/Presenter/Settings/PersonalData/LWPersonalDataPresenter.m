//
//  LWPersonalDataPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 21.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPersonalDataPresenter.h"
#import "LWPersonalItemTableViewCell.h"
#import "LWPersonalDataModel.h"
#import "TKButton.h"
#import "LWConstants.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"


@interface LWPersonalDataPresenter () {
    LWPersonalDataModel *personalData;
}


#pragma mark - Utils

- (NSString *)stringFromData:(NSString *)data;
- (CGFloat)calculateRowHeightForText:(NSString *)text;
- (NSString *)dataByCellRow:(NSInteger)row;

@end


@implementation LWPersonalDataPresenter


static NSInteger const kDescriptionRows = 7;

static NSString *const DescriptionIdentifiers[kDescriptionRows] = {
    kPersonalItemTableViewCellIdentifier,
    kPersonalItemTableViewCellIdentifier,
    kPersonalItemTableViewCellIdentifier,
    kPersonalItemTableViewCellIdentifier,
    kPersonalItemTableViewCellIdentifier,
    kPersonalItemTableViewCellIdentifier,
    kPersonalItemTableViewCellIdentifier
};


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localize(@"personal.data.title");

    [self setBackButton];
    
    [self registerCellWithIdentifier:kPersonalItemTableViewCellIdentifier
                                name:kPersonalItemTableViewCell];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // request blockchain data
    [self setLoading:YES];

    [[LWAuthManager instance] requestPersonalData];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didReceivePersonalData:(LWPersonalDataModel *)data {
    personalData = data;
    [self setLoading:NO];
    
    [self.tableView reloadData];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (personalData == nil) ? 1 : kDescriptionRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *const Descriptions[kDescriptionRows] = {
        Localize(@"personal.data.fullname"),
        Localize(@"personal.data.email"),
        Localize(@"personal.data.phone"),
        Localize(@"personal.data.country"),
        Localize(@"personal.data.zip"),
        Localize(@"personal.data.city"),
        Localize(@"personal.data.address")
    };
    
    UIColor *dark = [UIColor colorWithHexString:kMainDarkElementsColor];
    UIColor *const Colors[kDescriptionRows] = {
        dark,
        dark,
        dark,
        dark,
        dark,
        dark,
        dark
    };
    
    NSString *identifier = DescriptionIdentifiers[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    LWPersonalItemTableViewCell *dataCell = (LWPersonalItemTableViewCell *)cell;
    dataCell.titleLabel.text = Descriptions[indexPath.row];
    dataCell.detailLabel.text = [self dataByCellRow:indexPath.row];
    dataCell.detailLabel.textColor = Colors[indexPath.row];
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [self dataByCellRow:indexPath.row];
    return [self calculateRowHeightForText:text];
}


#pragma mark - Utils

- (NSString *)stringFromData:(NSString *)data {
    if (data == nil || [data isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    return data;
}

- (CGFloat)calculateRowHeightForText:(NSString *)text {
    if (text == nil) {
        return 0.0;
    }
    
    CGFloat const kTopBottomPadding = 8.0;
    CGFloat const kLeftRightPadding = 20.0 * 2.0;
    CGFloat const kTitleWidth = 100.0;
    CGFloat const kDescriptionWidth = self.tableView.frame.size.width - kLeftRightPadding - kTitleWidth;
    
    UIFont *font = [UIFont fontWithName:kFontRegular size:kAssetDetailsFontSize];
    CGSize const size = CGSizeMake(kDescriptionWidth, CGFLOAT_MAX);
    CGRect rect = [text boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil];
    
    CGFloat const kDefaultRowHeight = 50.0;
    CGFloat const cellHeight = MAX(kDefaultRowHeight, rect.size.height + kTopBottomPadding * 2.0);
    return cellHeight;
}

- (NSString *)dataByCellRow:(NSInteger)row {
    NSString *const values[kDescriptionRows] = {
        [self stringFromData:personalData.fullName],
        [self stringFromData:personalData.email],
        [self stringFromData:personalData.phone],
        [self stringFromData:personalData.country],
        [self stringFromData:personalData.zip],
        [self stringFromData:personalData.city],
        [self stringFromData:personalData.address]
    };
    return values[row];
}

@end
