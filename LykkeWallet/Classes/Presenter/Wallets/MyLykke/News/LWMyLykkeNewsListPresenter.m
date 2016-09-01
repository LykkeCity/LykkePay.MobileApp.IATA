//
//  LWMyLykkeNewsListPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 30/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeNewsListPresenter.h"
#import "LWNewsFirstTableViewCell.h"
#import "LWMyLykkeNewsCommonTableViewCell.h"
#import "LWPacketGetNews.h"
#import "LWNewsElementModel.h"
#import "LWTabController.h"
#import "LWMyLykkePresenter.h"
#import "LWNewsDetailPresenter.h"
#import "UIViewController+Loading.h"

@interface LWMyLykkeNewsListPresenter () <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *newsArray;
}

@property (weak, nonatomic) IBOutlet UIView *equityView;
@property (weak, nonatomic) IBOutlet UIView *newsView;
@property (weak, nonatomic) IBOutlet UILabel *newsLabel;

@end

@implementation LWMyLykkeNewsListPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate=self;
    
    _newsView.clipsToBounds=YES;
    _newsView.layer.cornerRadius=_newsView.bounds.size.height/2;
    
    NSDictionary *attr=@{NSKernAttributeName:@(1.2), NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14]};
    _newsLabel.attributedText=[[NSAttributedString alloc] initWithString:@"NEWS" attributes:attr];
    _newsLabel.textColor=[UIColor whiteColor];
    

    
    [self.tableView registerNib:[UINib nibWithNibName:@"LWNewsFirstTableViewCell" bundle:nil] forCellReuseIdentifier:@"LWNewsFirstTableViewCell"];
//    [self.tableView registerNib:[UINib nibWithNibName:@"LWMyLykkeNewsCommonTableViewCell" bundle:nil] forCellReuseIdentifier:@"LWMyLykkeNewsCommonTableViewCell"];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];

    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(equityPressed)];
    [self.equityView addGestureRecognizer:gesture];
    self.tableView.bounces=NO;
    self.tableView.editing=NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!newsArray)
        self.tableView.backgroundColor=[UIColor whiteColor];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!newsArray)
        [self setLoading:YES];
    [[LWAuthManager instance] requestLykkeNews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return CGFLOAT_MIN;
    return 10;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    v.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    return v;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return newsArray.count;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.section==0)
    {
        
        LWNewsElementModel *element=newsArray[0];
        
        NSArray *topLevelObjects;
        if(element.imageURL)
            topLevelObjects=[[NSBundle mainBundle] loadNibNamed:@"LWNewsFirstTableViewCell" owner:self options:nil];
        else
            topLevelObjects=[[NSBundle mainBundle] loadNibNamed:@"LWNewsFirstNoImageTableViewCell" owner:self options:nil];

        LWNewsFirstTableViewCell *_cell=[topLevelObjects objectAtIndex:0];
        _cell.element=element;
        cell=_cell;
    }
    else
    {
        
        NSArray *topLevelObjects=[[NSBundle mainBundle] loadNibNamed:@"LWMyLykkeNewsCommonTableViewCell" owner:self options:nil];
        LWMyLykkeNewsCommonTableViewCell *_cell = [topLevelObjects objectAtIndex:0];
        _cell.element=newsArray[indexPath.section];
        cell=_cell;
    }
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellPressed:)];
    [cell addGestureRecognizer:gesture];
    cell.tag=indexPath.section;
    
    return cell;
}

-(void) cellPressed:(UITapGestureRecognizer *) gesture
{
    LWNewsDetailPresenter *presenter=[[LWNewsDetailPresenter alloc] init];
    presenter.url=[newsArray[gesture.view.tag] detailsURL];
    [self.navigationController pushViewController:presenter animated:YES];
}

-(void) authManager:(LWAuthManager *)manager didGetNews:(LWPacketGetNews *)packet
{
    [self setLoading:NO];
    newsArray=packet.news;
    self.tableView.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    [self.tableView reloadData];
}

-(void) equityPressed
{
    
    LWMyLykkePresenter *presenter=[[LWMyLykkePresenter alloc] init];
    presenter.tabBarItem=self.tabBarItem;
    
    
    NSArray *arr=self.navigationController.viewControllers;
    LWTabController *tabController=arr[0];
    NSMutableArray *newTabcontrollers=[[NSMutableArray alloc] init];
    for(UIViewController *v in tabController.viewControllers)
    {
        if([v isKindOfClass:[LWMyLykkeNewsListPresenter class]])
        {
            [newTabcontrollers addObject:presenter];
        }
        else
            [newTabcontrollers addObject:v];
    }
    [tabController setViewControllers:newTabcontrollers];
    
    
}



@end
