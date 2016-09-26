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

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
 
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIWindow *window=self.view.window;
    for(UIGestureRecognizer *g in window.gestureRecognizers)
    {
        g.delaysTouchesBegan=NO;
    }
}


-(void) showCustomKeyboard
{
    if(_keyboardView && _keyboardView.isVisible)
        return;
    if(!_keyboardView)
    {
        _keyboardView=[[[NSBundle mainBundle] loadNibNamed:@"LWMathKeyboardView" owner:self options:nil] firstObject];
        [self adjustCustomKeyboardFrame];
        _keyboardView.center=CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height+_keyboardView.bounds.size.height/2);
        
        _keyboardView.delegate=self;
//        _keyboardView.targetTextField=sumTextField;
        [_keyboardView setText:@"0"];
        [self.view addSubview:_keyboardView];
        [_keyboardView layoutSubviews];
    }
    
    
//    self.operationButton.translatesAutoresizingMaskIntoConstraints = YES;
    _keyboardView.isVisible=YES;
    [UIView animateWithDuration:0.5 animations:^{
        _keyboardView.center=CGPointMake(_keyboardView.bounds.size.width/2, self.view.bounds.size.height-_keyboardView.bounds.size.height/2);
//        self.operationButton.center=CGPointMake(self.operationButton.center.x, self.operationButton.center.y-_keyboardView.bounds.size.height);
    }];
}

-(void) adjustCustomKeyboardFrame
{
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
    
//    _keyboardView.frame=CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.width*0.6);

    
    CGRect rrr=_keyboardView.frame;
    CGRect eee=self.view.frame;
//    _keyboardView.center=CGPointMake(_keyboardView.bounds.size.width/2, _keyboardView.center.y-_keyboardView.bounds.size.height);
//    [_keyboardView layoutIfNeeded];
    
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
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
//    if(_keyboardView)
//        [self adjustCustomKeyboardFrame];
}

-(BOOL) shouldDismissIpadModalViewController
{
    return YES;
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


-(void) showCopied
{
    UIWindow *window=[UIApplication sharedApplication].windows[0];
    UIView *shadowView=[[UIView alloc] initWithFrame:window.bounds];
    shadowView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.3];
    [window addSubview:shadowView];
    
    UIView *view=[[UIView alloc] init];
    view.backgroundColor=[UIColor whiteColor];
    view.clipsToBounds=YES;
    [window addSubview:view];
    
    UIView *labelView=[[UIView alloc] init];
    UILabel *label=[[UILabel alloc] init];
    label.font=[UIFont systemFontOfSize:18];
    label.textColor=[UIColor colorWithRed:36.0/255 green:182.0/255 blue:53.0/255 alpha:1];
    label.text=Localize(@"wallets.currency.copied");
    
    [label sizeToFit];
    
    UIImageView *signView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, label.bounds.size.height*1.2, label.bounds.size.height*1.2)];
    signView.image=[UIImage imageNamed:@"CopiedCheckMarkSign.png"];
    labelView.frame=CGRectMake(0, 0, label.bounds.size.width+10+signView.bounds.size.width, signView.bounds.size.width);
    [labelView addSubview:label];
    [labelView addSubview:signView];
    
    label.center=CGPointMake(labelView.bounds.size.width-label.bounds.size.width/2, labelView.bounds.size.height/2);
    
    
    view.frame=CGRectMake(0, 0, labelView.bounds.size.width+80, labelView.bounds.size.height+25);
    view.layer.cornerRadius=view.bounds.size.height/2;
    
    [view addSubview:labelView];
    
    labelView.center=CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
    
    view.center=CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);
    
    
    
    shadowView.alpha=0;
    view.alpha=0;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        shadowView.alpha=1;
        view.alpha=1;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.3 animations:^{
            
            shadowView.alpha=0;
            view.alpha=0;
        } completion:^(BOOL finished){
            [shadowView removeFromSuperview];
            [view removeFromSuperview];
            
        }];
        
        
    });
    
    
}



@end
