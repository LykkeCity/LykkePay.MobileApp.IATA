//
//  LWMyLykkeInfoPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeInfoPresenter.h"
#import "LWCommonButton.h"
#import "LWMyLykkeInfoTableViewCell.h"
#import "UIViewController+Navigation.h"
#import "LWAssetDescriptionModel.h"
#import "LWMyLykkeBuyPresenter.h"
#import "LWLykkeBuyTransferContainer.h"

#import "UIViewController+Loading.h"
@interface LWMyLykkeInfoPresenter () <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *titles;
    NSArray *texts;
}

@property (weak, nonatomic) IBOutlet LWCommonButton *buyButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;

@end

@implementation LWMyLykkeInfoPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    self.buyButton.type=BUTTON_TYPE_GREEN;
    self.buyButton.enabled=YES;
    [self adjustThinLines];

    
    [self registerCellWithIdentifier:@"LWMyLykkeInfoTableViewCellIdentifier"
                                name:@"LWMyLykkeInfoTableViewCell"];
    [self setBackButton];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.bounces=NO;
    [self.buyButton addTarget:self action:@selector(buyPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if([UIScreen mainScreen].bounds.size.width==320)
        self.buttonWidth.constant=270;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    UIView *view=[[UIView alloc] init];
    UIImageView *image=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    image.image=[UIImage imageNamed:@"IconLogo.png"];
    [view addSubview:image];
    
    UILabel *label=[[UILabel alloc] init];
    NSDictionary *attr=@{NSKernAttributeName:@(1.5), NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17]};
    label.attributedText=[[NSAttributedString alloc] initWithString:@"LYKKE EQUITY" attributes:attr];
    [label sizeToFit];
    [view addSubview:label];
    view.frame=CGRectMake(0, 0, 30+10+label.bounds.size.width, 30);
    label.center=CGPointMake(40+label.bounds.size.width/2, 15);
    
    self.navigationController.navigationBar.topItem.titleView=view;

    [self setLoading:YES];
    [[LWAuthManager instance] requestAssetDescription:@"LKK"];

}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titles.count;;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWMyLykkeInfoTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LWMyLykkeInfoTableViewCellIdentifier"];
    cell.titleLabel.text=titles[indexPath.row];
    cell.descriptionLabel.text=texts[indexPath.row];
    
    return cell;
}

-(void) authManager:(LWAuthManager *)manager didGetAssetDescription:(LWAssetDescriptionModel *)assetDescription
{
    [self setLoading:NO];
    
    NSMutableArray *desc=[[NSMutableArray alloc] init];
    NSMutableArray *titl=[[NSMutableArray alloc] init];
    if(assetDescription.assetClass)
    {
        [desc addObject:assetDescription.assetClass];
        [titl addObject:@"Asset class"];
    }
    if(assetDescription.details)
    {
        [titl addObject:@"Description"];
        [desc addObject:assetDescription.details];
    }
    if(assetDescription.issuerName)
    {
        [titl addObject:@"Issuer name"];
        [desc addObject:assetDescription.issuerName];
    }
    
    titles=titl;
    texts=desc;
    [self.tableView reloadData];
        
}

-(void) buyPressed
{
//    LWMyLykkeBuyPresenter *presenter=[[LWMyLykkeBuyPresenter alloc] init];
//    [self.navigationController pushViewController:presenter animated:YES];
//    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        
        LWLykkeBuyTransferContainer *presenter=[LWLykkeBuyTransferContainer new];
        [self.navigationController pushViewController:presenter animated:YES];
        
        //        LWBuyLykkeInContainerPresenter *presenter=[LWBuyLykkeInContainerPresenter new];
        //        [self.navigationController pushViewController:presenter animated:YES];
        
        //
        //
        //    LWMyLykkeBuyPresenter *presenter=[[LWMyLykkeBuyPresenter alloc] init];
        //    [self.navigationController pushViewController:presenter animated:YES];
        
        
        
        
    }
    else
    {
        //        LWMyLykkeIpadController *presenter=[LWMyLykkeIpadController new];
        //        [self.navigationController pushViewController:presenter animated:YES];
        
        LWLykkeBuyTransferContainer *presenter=[LWLykkeBuyTransferContainer new];
        [self.navigationController pushViewController:presenter animated:YES];
        
    }


}

-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    [self setLoading:NO];
    [self showReject:reject response:context.responseObject];
}

@end
