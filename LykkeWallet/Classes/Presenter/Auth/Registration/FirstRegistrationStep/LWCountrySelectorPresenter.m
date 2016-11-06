//
//  LWCountrySelectorPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCountrySelectorPresenter.h"
#import "LWCountryTableViewCell.h"
#import "LWCountryModel.h"
#import "LWAuthManager.h"
#import "LWConstants.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"


@interface LWCountrySelectorPresenter () <UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate> {
    NSArray *countries;
    NSArray *searchCountries;
    NSArray *sections;
}

@property (nonatomic, strong) UISearchController *searchController;


#pragma mark - Utils

- (NSArray *)countriesBySection:(NSInteger)section;

@end


@implementation LWCountrySelectorPresenter


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = Localize(@"register.phone.country.title");
    
    countries = [NSArray array];
    sections = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    [self setCancelButtonWithTitle:Localize(@"register.phone.cancel")
                            target:self
                          selector:@selector(cancelClicked)];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    NSString *searchText = Localize(@"register.phone.country.placeholder");
    [self.searchController.searchBar setKeyboardType:UIKeyboardTypeDefault];
    [self.searchController.searchBar setPlaceholder:searchText];
    [self.searchController.searchBar setBarStyle:UIBarStyleDefault];
    [self.searchController.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [self.searchController.searchBar setBackgroundImage:[UIImage new]];
    [self.searchController.searchBar sizeToFit];
    
    [self registerCellWithIdentifier:kCountryTableViewCellIdentifier
                             forName:kCountryTableViewCell];
    
    self.tableView.sectionIndexColor = [UIColor colorWithHexString:kMainElementsColor];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setLoading:YES];
    
    //self.definesPresentationContext = YES;
    //self.extendedLayoutIncludesOpaqueBars = YES;
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    //self.tableView.contentOffset = CGPointMake(0, 44.0);
    //self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0);
    
    [[LWAuthManager instance] requestCountyCodes];
}

- (void)dealloc {
    [self.searchController.view removeFromSuperview];
}

- (void)cancelClicked {
    [self.searchController setActive:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    self.navigationController.navigationBar.translucent = NO;
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didGetCountryCodes:(NSArray *)countryCodes {
    [self setLoading:NO];
    countries = [countryCodes copy];
    [self.tableView reloadData];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
    
    [self cancelClicked];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.searchController.active) {
        return 1;
    }
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger result = 0;
    if (self.searchController.active) {
        result = searchCountries.count;
    }
    else {
        NSArray *items = [self countriesBySection:section];
        result = items.count;
    }
    return result;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.searchController.active) {
        return nil;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (self.searchController.active) {
        return 0;
    }
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.searchController.active) {
        return @"";
    }
    
    NSString *sectionHeader = [NSString stringWithFormat:@"  %@",
                               [sections objectAtIndex:section]];
    return sectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCountryTableViewCellIdentifier];
    [self configureCell:cell tableView:tableView indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LWCountryTableViewCell *cell = (LWCountryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [self.delegate countrySelected:cell.model.name
                                  code:cell.model.identity
                                prefix:cell.model.prefix];

        [self cancelClicked];
    }
}


#pragma mark - LWAuthenticatedTablePresenter

- (void)configureCell:(UITableViewCell *)cell tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    LWCountryTableViewCell *itemCell = (LWCountryTableViewCell *)cell;
    NSArray *items = nil;
    if (self.searchController.active) {
        items = searchCountries;
    }
    else {
        items = [self countriesBySection:indexPath.section];
    }

    LWCountryModel *model = (LWCountryModel *)[items objectAtIndex:indexPath.row];;
    if (model && itemCell) {
        itemCell.countryLabel.text = model.name;
        itemCell.codeLabel.text = model.prefix;
        itemCell.model = [model copy];
    }
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}


#pragma mark - Searching

- (void)searchForText:(NSString *)searchText
{
    if (searchText == nil ||
        [searchText isKindOfClass:[NSNull class]] ||
        searchText.length <= 0) {
        searchCountries = countries;
    }
    else {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", searchText];
        searchCountries = [countries filteredArrayUsingPredicate:resultPredicate];
    }
}


#pragma mark - Utils

- (NSArray *)countriesBySection:(NSInteger)section {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name beginswith[cd] %@", [sections objectAtIndex:section]];
    NSArray *sectionArray = [countries filteredArrayUsingPredicate:predicate];
    return sectionArray;
}

@end
