//
//  LWRefundPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRefundPresenter.h"
#import "LWRefundTableViewCell.h"
#import "LWRefundInformationPresenter.h"
#import "UIViewController+Navigation.h"
#import "LWValidator.h"
#import "ZBarReaderViewController.h"
#import "LWCache.h"
#import "UIViewController+Loading.h"
#import "LWCameraMessageView.h"
#import "LWPacketGetRefundAddress.h"
#import "LWCameraMessageView2.h"

@import AVFoundation;


@interface LWRefundPresenter () <UITableViewDelegate, UITableViewDataSource, LWRefundTableViewCellDelegate, ZBarReaderDelegate>
{
    NSMutableDictionary *cellsDict;
    
}

@property (weak, nonatomic) IBOutlet UIButton *emailRefundButton;

@end

@implementation LWRefundPresenter

const int kNumberOfCells=5;

static int CellTypes[kNumberOfCells] = {
    RefundCellTypeInfo,
    RefundCellTypeAddress,
    RefundCellTypeInfo,
    RefundCellTypeAfter,
    RefundCellTypeInfo
    
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cellsDict=[[NSMutableDictionary alloc] init];
    self.tableView.delegate=self;
    
    
    NSString *prevAddress=[LWCache instance].refundAddress;
    
    for(int i=0;i<kNumberOfCells;i++)
    {
        LWRefundTableViewCell *cell=[[LWRefundTableViewCell alloc] initWithType:CellTypes[i] width:self.tableView.bounds.size.width];
        if(i==0)
        {
            cell.titleLabel.text=@"Refund address";
            if(prevAddress.length)
                [cell showChangeButton];
            else
                [cell hideChangeButton];
            cell.delegate=self;
        }
        else if(i==1)
        {
            
            cell.addressString=prevAddress;
            cell.delegate=self;
        }
        else if(i==2)
            cell.titleLabel.text=@"Refund valid after";
        else if(i==3)
        {
            cell.daysValidAfter=[LWCache instance].refundDaysValidAfter;
            cell.sendAutomatically=[LWCache instance].refundSendAutomatically;

        }
        else if(i==4)
        {
            cell.titleLabel.text=@"Information";
            [cell addDisclosureImage];
            cell.delegate=self;
        }
        cellsDict[@(i)]=cell;
    }
    
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveRefundSettings) name:@"SaveRefundSettings" object:nil];
    
    
    // Do any additional setup after loading the view from its nib.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [LWValidator setButton:self.emailRefundButton enabled:YES];
    [self setBackButton];

}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    LWRefundTableViewCell *cell=cellsDict[@(1)];
    NSString *address=cell.addressString;
    
    cell=cellsDict[@(3)];
    
    
 //   [[LWAuthManager instance] requestSetRefundAddress:@{@"Address":address,@"SendAutomatically":@(cell.sendAutomatically),@"ValidDays":@(cell.daysValidAfter)}];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setTitle:@"REFUND"];
    [self setLoading:YES];
    
    [[LWAuthManager instance] requestGetRefundAddress];

}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfCells;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWRefundTableViewCell *cell=cellsDict[@(indexPath.row)];
    
    return [cell height];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWRefundTableViewCell *cell=cellsDict[@(indexPath.row)];
    
    return cell;
}

-(void) addressViewPressedApplyOnCell:(LWRefundTableViewCell *)cell_
{
    LWRefundTableViewCell *firstCell=cellsDict[@(0)];
    [firstCell showChangeButton];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [self setLoading:YES];
    
    LWRefundTableViewCell *cell=cellsDict[@(3)];
    
    [[LWAuthManager instance] requestSetRefundAddress:@{@"Address":[LWCache instance].refundAddress,@"SendAutomatically":@(cell.sendAutomatically),@"ValidDays":@(cell.daysValidAfter)}];
//    [[LWAuthManager instance] requestSetRefundAddress:@{@"Address":[LWCache instance].refundAddress,@"SendAutomatically":@(YES),@"ValidDays":@(1)}];

//    [[LWAuthManager instance] requestSetRefundAddress:[LWCache instance].refundAddress];
    
    
}

-(void) addressCellPressedChange
{
    LWRefundTableViewCell *firstCell=cellsDict[@(0)];
    [firstCell hideChangeButton];

    LWRefundTableViewCell *addressCell=cellsDict[@(1)];
    [addressCell openAddressCell];


    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}



-(void) cellTapped:(LWRefundTableViewCell *)cell
{
    if(cell==cellsDict[@(4)])
    {
        LWRefundInformationPresenter *presenter=[LWRefundInformationPresenter new];
        [self.navigationController pushViewController:presenter animated:YES];

    }
}

-(void) saveRefundSettings
{
    LWRefundTableViewCell *cell=cellsDict[@(3)];
    
    [[LWAuthManager instance] requestSetRefundAddress:@{@"SendAutomatically":@(cell.sendAutomatically),@"ValidDays":@(cell.daysValidAfter)}];
 
}

-(void) authManager:(LWAuthManager *)manager didGetRefundAddress:(LWPacketGetRefundAddress *)address
{
    [self setLoading:NO];
    LWRefundTableViewCell *cell=cellsDict[@(0)];
    
    if(address.refundAddress.length)
        [cell showChangeButton];
    else
        [cell hideChangeButton];
    
    cell=cellsDict[@(1)];
    cell.addressString=address.refundAddress;
    
    cell=cellsDict[@(3)];
    cell.daysValidAfter=address.validDays;
    cell.sendAutomatically=address.sendAutomatically;

}

-(void) authManagerDidSetRefundAddress:(LWAuthManager *)manager
{
    [self setLoading:NO];
    [[LWAuthManager instance] requestGetRefundAddress];
}

-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    [self setLoading:NO];
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];

}

-(void) addressViewPressedScanQRCode:(LWRefundTableViewCell *)cell
{
    
#if TARGET_IPHONE_SIMULATOR
    // Simulator
#else
    
    void (^block)(void)=^{
    
        ZBarReaderViewController *codeReader = [ZBarReaderViewController new];
        codeReader.readerDelegate=self;
        codeReader.supportedOrientationsMask = ZBarOrientationMaskAll;
        codeReader.showsZBarControls=NO;
        codeReader.showsHelpOnFail=NO;
        codeReader.tracksSymbols=YES;
        
        
        
        ZBarImageScanner *scanner = codeReader.scanner;
        [scanner setSymbology: ZBAR_EAN8 config: ZBAR_CFG_ENABLE to: 0];
//        [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
        
        [self.navigationController pushViewController:codeReader animated:YES];
        
        [codeReader setTitle:@"SCAN QR-CODE"];
    };
    
    void (^messageBlock)(void)=^{
        [self.view endEditing:YES];
        LWCameraMessageView *view=[[NSBundle mainBundle] loadNibNamed:@"LWCameraMessageView" owner:self options:nil][0];
        UIWindow *window=[[UIApplication sharedApplication] keyWindow];
        view.center=CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);
        
        [window addSubview:view];
        
        [view show];
    };

    
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        block();
    } else if(authStatus == AVAuthorizationStatusDenied){
        messageBlock();
 
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [self.view endEditing:YES];
        LWCameraMessageView2 *view=[[NSBundle mainBundle] loadNibNamed:@"LWCameraMessageView2" owner:self options:nil][0];
        UIWindow *window=[[UIApplication sharedApplication] keyWindow];
        view.center=CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);
        
        [window addSubview:view];
        
        [view showWithCompletion:^(BOOL result){
            if(result)
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(granted){
                            block();
                        } else {
                            messageBlock();
                        }
                    });
                }];
        }];
    } else {
        // impossible, unknown authorization status
    }
    
    

#endif

//    [self presentViewController:codeReader animated:YES completion:nil];
    
    
}

#pragma mark - ZBar's Delegate method

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
#if TARGET_IPHONE_SIMULATOR
    // Simulator
#else
    //  get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // just grab the first barcode
        break;
    
    // showing the result on textview
    
    LWRefundTableViewCell *cell=cellsDict[@(1)];
    cell.addressString=symbol.data;
    
    
    
    // dismiss the controller
    //    [reader dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
#endif

}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
