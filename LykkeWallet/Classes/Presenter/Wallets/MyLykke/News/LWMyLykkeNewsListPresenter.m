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
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        
    
    _newsView.clipsToBounds=YES;
    _newsView.layer.cornerRadius=_newsView.bounds.size.height/2;
    
    NSDictionary *attr=@{NSKernAttributeName:@(1.2), NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14]};
    _newsLabel.attributedText=[[NSAttributedString alloc] initWithString:@"NEWS" attributes:attr];
    _newsLabel.textColor=[UIColor whiteColor];
    

    
    [self.tableView registerNib:[UINib nibWithNibName:@"LWNewsFirstTableViewCell" bundle:nil] forCellReuseIdentifier:@"LWNewsFirstTableViewCell"];
//    [self.tableView registerNib:[UINib nibWithNibName:@"LWMyLykkeNewsCommonTableViewCell" bundle:nil] forCellReuseIdentifier:@"LWMyLykkeNewsCommonTableViewCell"];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200.0;
    self.tableView.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];

    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(equityPressed)];
    [self.equityView addGestureRecognizer:gesture];
//    self.tableView.bounces=NO;
    self.tableView.editing=NO;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [[LWAuthManager instance] requestLykkeNewsWithCompletion:^(NSArray *newsArr){
        
        newsArray=newsArr;
        self.tableView.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
        if(self.isViewLoaded && self.view.window)
            [self setLoading:NO];
        [self.tableView reloadData];
    }];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!newsArray)
        self.tableView.backgroundColor=[UIColor whiteColor];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:246.0/255 green:247.0/255 blue:248.0/255 alpha:1]];
    else
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setLoading:NO];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.title=@"MY LYKKE";

    if(!newsArray)
        [self setLoading:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0 && [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
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
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        return newsArray.count;
    else
    {
        if(newsArray.count==0)
            return 0;
        int count=(int)(newsArray.count-2)/3;
        if((newsArray.count-2)%3==0)
            return count+1;
        else
            return count+2;
    }
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
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
            _cell.element2=newsArray[1];
        _cell.delegate=self;

        cell=_cell;
    }
    else
    {
        
        NSArray *topLevelObjects=[[NSBundle mainBundle] loadNibNamed:@"LWMyLykkeNewsCommonTableViewCell" owner:self options:nil];
        LWMyLykkeNewsCommonTableViewCell *_cell = [topLevelObjects objectAtIndex:0];
        
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
            _cell.element=newsArray[indexPath.section];
        else
        {
            int index=(int)(indexPath.section-1)*3+2;
            _cell.element=newsArray[index];
            if(newsArray.count>index+1)
                _cell.element2=newsArray[index+1];
            if(newsArray.count>index+2)
                _cell.element3=newsArray[index+2];
            [_cell hideEmpty];
        }
        _cell.delegate=self;
        cell=_cell;
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

-(void) newsCellPressedElement:(LWNewsElementModel *) element
{
    LWNewsDetailPresenter *presenter=[[LWNewsDetailPresenter alloc] init];
    presenter.url=[element detailsURL];
    [self.navigationController pushViewController:presenter animated:YES];
 
}

//-(void) authManager:(LWAuthManager *)manager didGetNews:(LWPacketGetNews *)packet
//{
//    [self setLoading:NO];
//    newsArray=packet.news;
//    self.tableView.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
//    [self.tableView reloadData];
//}


-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.delegate listScrolled:scrollView];
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}



@end
