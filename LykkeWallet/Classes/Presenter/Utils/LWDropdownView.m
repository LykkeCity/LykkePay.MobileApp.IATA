//
//  LWDropdownView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWDropdownView.h"
#import "LWDropdownViewCell.h"

@interface LWDropdownView() <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    UIButton *cancelButton;
    UIButton *doneButton;
    UILabel *titleLabel;
    
    
    UIView *shadow;
    
    
    NSInteger selectedIndex;
    
    
}

@property (strong, nonatomic) void(^completion)(NSInteger index);
@property (strong, nonatomic) NSArray *elements;
@property NSInteger activeIndex;

@property BOOL shouldShowDone;
@property BOOL shouldShowCancel;

@end

@implementation LWDropdownView

-(id) initWithTitle:(NSString *) title
{
    self=[super init];
    
    UIWindow *parentView=[UIApplication sharedApplication].keyWindow;
    
    
    self.backgroundColor=[UIColor whiteColor];
    
    if(self.shouldShowCancel)
    {
        cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"CANCEL" attributes:@{NSKernAttributeName:@(1.2), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14], NSForegroundColorAttributeName:[UIColor colorWithRed:140.0/255 green:148.0/255 blue:160.0/255 alpha:1]}] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton sizeToFit];
        [self addSubview:cancelButton];
    }
    
    if(self.shouldShowDone)
    {
        doneButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"DONE" attributes:@{NSKernAttributeName:@(0.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14], NSForegroundColorAttributeName:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1]}] forState:UIControlStateNormal];
        [doneButton sizeToFit];
        [doneButton addTarget:self action:@selector(donePressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
    }
    
    titleLabel=[[UILabel alloc] init];
    titleLabel.attributedText=[[NSAttributedString alloc] initWithString:title attributes:@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]}];
    [titleLabel sizeToFit];
    [self addSubview:titleLabel];
    
    
    tableView=[[UITableView alloc] init];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self addSubview:tableView];
    
    shadow=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
    shadow.backgroundColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.5];
    shadow.alpha=0;
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPressed)];
    [shadow addGestureRecognizer:gesture];
    
    [parentView addSubview:shadow];
    [parentView addSubview:self];
    
    self.frame=CGRectMake(0, parentView.bounds.size.height, parentView.bounds.size.width, parentView.bounds.size.height*0.66);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        
        shadow.alpha=1;
        self.center=CGPointMake(self.center.x, self.center.y-self.bounds.size.height);
    }];
    
    return self;
}

-(void) setActiveIndex:(NSInteger)activeIndex
{
    if(activeIndex!=-1)
    {
        selectedIndex=activeIndex;
        [tableView reloadData];
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

-(NSInteger) activeIndex
{
    return selectedIndex;
}



+(void) showWithElements:(NSArray *) elements title:(NSString *) title showDone:(BOOL) showDone showCancel:(BOOL) showCancel activeIndex:(int) index completion:(void(^)(NSInteger)) completion
{
    LWDropdownView *view=[[LWDropdownView alloc] initWithTitle:title];
    view.elements=elements;

    view.completion=completion;
    view.shouldShowDone=showDone;
    view.shouldShowCancel=showCancel;
    view.activeIndex=index;
    
}

-(void) orientationChanged
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    self.frame=CGRectMake(0, window.bounds.size.height*0.34, window.bounds.size.width, window.bounds.size.height*0.66);
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    tableView.frame=CGRectMake(0, 78, self.bounds.size.width, self.bounds.size.height-78);
    CGFloat pos=33;
    cancelButton.center=CGPointMake(20+cancelButton.bounds.size.width/2, pos);
    titleLabel.center=CGPointMake(self.bounds.size.width/2, pos);
    doneButton.center=CGPointMake(self.bounds.size.width-doneButton.bounds.size.width/2-20, pos);
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.elements.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWDropdownViewCell *cell=[[LWDropdownViewCell alloc] initWithTitle:_elements[indexPath.row]];
//    if(indexPath.row==_selectedIndex)
//    {
//        [cell showSelected:YES];
//    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex=indexPath.row;
    [self donePressed];
}

-(void) hideView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.center=CGPointMake(self.center.x, self.center.y+self.bounds.size.height);
        shadow.alpha=0;
    } completion:^(BOOL finished){
        [shadow removeFromSuperview];
        [self removeFromSuperview];
        
    }];
}

-(void) cancelPressed
{
    [self hideView];
}

-(void) donePressed
{
    [self hideView];
    self.completion(selectedIndex);
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
