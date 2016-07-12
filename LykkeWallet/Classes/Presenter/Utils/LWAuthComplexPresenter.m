//
//  LWAuthComplexPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 06.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"
#import "LWConstants.h"

#define KEYBOARD_SIZE_COEFF 0.8

@interface LWAuthComplexPresenter () <UITableViewDataSource, UITableViewDelegate> {
    UIRefreshControl *refreshControl;
    
}


@end


@implementation LWAuthComplexPresenter


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
}


-(void) showCustomKeyboard
{
    if(_keyboardView && _keyboardView.isVisible)
        return;
    if(!_keyboardView)
    {
        _keyboardView=[[[NSBundle mainBundle] loadNibNamed:@"LWMathKeyboardView" owner:self options:nil] firstObject];
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        {
            if(self.view.bounds.size.width!=320)
                _keyboardView.frame=CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.width*KEYBOARD_SIZE_COEFF);
            else
                _keyboardView.frame=CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.width*0.65);
        }
        else
        {
            _keyboardView.frame=CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.width*0.6);
        }
 
        _keyboardView.delegate=self;
//        _keyboardView.targetTextField=sumTextField;
        [_keyboardView setText:@"0"];
        [self.view addSubview:_keyboardView];
    }
    
    
//    self.operationButton.translatesAutoresizingMaskIntoConstraints = YES;
    _keyboardView.isVisible=YES;
    [UIView animateWithDuration:0.5 animations:^{
        _keyboardView.center=CGPointMake(_keyboardView.bounds.size.width/2, _keyboardView.center.y-_keyboardView.bounds.size.height);
//        self.operationButton.center=CGPointMake(self.operationButton.center.x, self.operationButton.center.y-_keyboardView.bounds.size.height);
    }];
}


-(void) hideCustomKeyboard
{
    _keyboardView.isVisible=NO;
    [UIView animateWithDuration:0.5 animations:^{
        _keyboardView.center=CGPointMake(_keyboardView.bounds.size.width/2, _keyboardView.center.y+_keyboardView.bounds.size.height);
//        self.operationButton.center=CGPointMake(self.operationButton.center.x, self.operationButton.center.y+_keyboardView.bounds.size.height);
    } completion:^(BOOL finished){
//        self.operationButton.translatesAutoresizingMaskIntoConstraints = NO;
        
    }];
    
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(0, @"Should be ovveriden");
    return nil;
}


#pragma mark - UITableViewDelegate

- (void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - Utils

- (void)registerCellWithIdentifier:(NSString *)identifier name:(NSString *)name {
    UINib *nib = [UINib nibWithNibName:name bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
}

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    
}

- (void)setRefreshControl
{
    if (self.tableView) {
        UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
        [self.tableView insertSubview:refreshView atIndex:0];
        
        refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor blackColor];
        [refreshControl addTarget:self action:@selector(startRefreshControl)
                 forControlEvents:UIControlEventValueChanged];
        [refreshView addSubview:refreshControl];
    }
}

- (void)stopRefreshControl {
    if (refreshControl) {
        [refreshControl endRefreshing];
    }
}

- (void)startRefreshControl {
    if (refreshControl) {
        [refreshControl beginRefreshing];
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        cell.backgroundColor = cell.contentView.backgroundColor;
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, (tableView.bounds.size.width-704)/2, 0, 0)];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
}



@end
