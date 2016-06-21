//
//  LWExchangeAssetsPopupView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeAssetsPopupView.h"
#import "LWAssetModel.h"
#import "LWCache.h"
#import "Macro.h"

@interface LWExchangeAssetsPopupView() <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    UIButton *cancelButton;
    UILabel *titleLabel;
    UIView *shadow;
    NSArray *assets;
    
    int activeAssetNum;
}

@end

@implementation LWExchangeAssetsPopupView


-(id) init
{
    self=[super init];
    
    shadow=[[UIView alloc] init];
    shadow.backgroundColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.5];
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [shadow addGestureRecognizer:gesture];
    
    self.backgroundColor=[UIColor whiteColor];
    tableView=[[UITableView alloc] init];
    tableView.dataSource=self;
    tableView.delegate=self;
    [self addSubview:tableView];
    
    cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    
    NSDictionary *attributes = @{NSKernAttributeName:@(0.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14], NSForegroundColorAttributeName:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1]};

    [cancelButton setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"exchange.assets.modal.cancel") attributes:attributes] forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    titleLabel=[[UILabel alloc] init];
    
    attributes = @{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]};
    titleLabel.attributedText=[[NSAttributedString alloc] initWithString:Localize(@"exchange.popup.basecurrency") attributes:attributes];
    
    [titleLabel sizeToFit];
    [self addSubview:titleLabel];
    
    assets=[LWCache instance].baseAssets;
    for(LWAssetModel *asset in assets)
        if([asset.identity isEqualToString:[LWCache instance].baseAssetId])
        {
            activeAssetNum=(int)[assets indexOfObject:asset];
            break;
        }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarDidRotate:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];

    if([tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];


    return self;
}

-(void) statusBarDidRotate:(NSNotification *) notification
{
    [self setNeedsLayout];
}


-(void) layoutSubviews
{
//    [super layoutSubviews];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
   
    shadow.frame=window.bounds;
    self.frame=CGRectMake(0, window.bounds.size.height-445, window.bounds.size.width, 445);

    cancelButton.center=CGPointMake(20+cancelButton.bounds.size.width/2, 25.5+8.5);
    titleLabel.center=CGPointMake(self.bounds.size.width/2, 23.5+10);
    
    tableView.frame=CGRectMake(0, 70, self.bounds.size.width, self.bounds.size.height-70);
    
}



-(void) show
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [window addSubview:shadow];
    [window addSubview:self];
    shadow.alpha=0;
    [self layoutSubviews];
    
    self.center=CGPointMake(self.center.x, self.center.y+self.bounds.size.height);
    
    [UIView animateWithDuration:0.5 animations:^{
    
        shadow.alpha=1;
        self.center=CGPointMake(self.center.x, self.center.y-self.bounds.size.height);

    
    }];
    
}

-(void) hide
{
    [UIView animateWithDuration:0.5 animations:^{
        
        shadow.alpha=0;
        self.center=CGPointMake(self.center.x, self.center.y+self.bounds.size.height);
        
        
    } completion:^(BOOL finished){
        [shadow removeFromSuperview];
        [self removeFromSuperview];
    
    }];

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
    return assets.count;
}

-(UITableViewCell *) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(30, 0, 200, 50)];
    label.text=[assets[indexPath.row] name];
    label.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    label.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    [cell addSubview:label];
    
    if(indexPath.row==activeAssetNum)
    {
        UIImageView *sign=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        sign.image=[UIImage imageNamed:@"CheckMark.png"];
        [cell addSubview:sign];
        sign.center=CGPointMake(tableView.bounds.size.width-30-6, 25);
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 30, 0, 30)];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 30, 0, 30)];
    }
    
}

-(void) tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(activeAssetNum==indexPath.row)
        return;

    LWAssetModel *asset=assets[indexPath.row];
    activeAssetNum=(int) indexPath.row;
    [tableView reloadData];
    if([self.delegate respondsToSelector:@selector(popupView:didSelectAssetWithId:)])
        [self.delegate popupView:self didSelectAssetWithId:asset.identity];
    [self hide];
}


-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
