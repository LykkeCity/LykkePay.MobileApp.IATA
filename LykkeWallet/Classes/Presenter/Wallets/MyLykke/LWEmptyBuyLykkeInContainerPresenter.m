//
//  LWEmptyBuyLykkeInContainerPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 04/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWEmptyBuyLykkeInContainerPresenter.h"
#import "LWTabController.h"
#import "FRHyperLabel.h"


@interface UITapGestureRecognizer(Links)


- (BOOL)didTapAttributedTextInLabel:(UILabel *)label inRange:(NSRange)targetRange;
/**
 Returns YES if the tap gesture was within the specified range of the attributed text of the label.
 */

@end

@implementation UITapGestureRecognizer(Links)

- (BOOL)didTapAttributedTextInLabel:(UILabel *)label inRange:(NSRange)targetRange {
    NSParameterAssert(label != nil);
    
    CGSize labelSize = label.bounds.size;
    // create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:label.attributedText];
    
    // configure layoutManager and textStorage
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    
    // configure textContainer for the label
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = label.lineBreakMode;
    textContainer.maximumNumberOfLines = label.numberOfLines;
    textContainer.size = labelSize;
    
    // find the tapped character location and compare it to the specified range
    CGPoint locationOfTouchInLabel = [self locationInView:label];
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                         locationOfTouchInLabel.y - textContainerOffset.y);
    NSInteger indexOfCharacter = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer
                                                       inTextContainer:textContainer
                              fractionOfDistanceBetweenInsertionPoints:nil];
    if (NSLocationInRange(indexOfCharacter, targetRange)) {
        return YES;
    } else {
        return NO;
    }
}

@end

@interface LWEmptyBuyLykkeInContainerPresenter ()
{
    NSRange linkRange;
}

@property (weak, nonatomic) IBOutlet UILabel *textlabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ipadIconTopConstraint;


@end

@implementation LWEmptyBuyLykkeInContainerPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    _textlabel.textColor=nil;
    
    NSMutableParagraphStyle *parStyle=[[NSMutableParagraphStyle alloc] init];
    parStyle.alignment=NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size:14], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSParagraphStyleAttributeName:parStyle};
    
    
    linkRange=[_textlabel.text rangeOfString:@"click here"];

    NSMutableAttributedString *string=[[NSMutableAttributedString alloc] initWithString:_textlabel.text attributes:attributes];
    [string addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:171.0/255.0 green:0/255.0 blue:255.0/255.0 alpha:1]} range:linkRange];
    _textlabel.attributedText = string;
//    _textlabel.linkAttributeDefault=@{NSForegroundColorAttributeName:[UIColor colorWithRed:171.0/255.0 green:0/255.0 blue:255.0/255.0 alpha:1]};
//
//    [_textlabel setLinkForSubstring:@"click here" withLinkHandler:^(FRHyperLabel *label, NSString *substring){
//        [self depositPressed];
//    }];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
    [_textlabel addGestureRecognizer:gesture];
    _textlabel.userInteractionEnabled=YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    // Do any additional setup after loading the view from its nib.
}

-(void) textTapped:(UITapGestureRecognizer *) gesture
{
    if([gesture didTapAttributedTextInLabel:_textlabel inRange:linkRange])
        [self depositPressed];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self orientationChanged];
}

-(void) depositPressed
{
    
    NSArray *arr=self.navigationController.viewControllers;
    if([[arr firstObject] isKindOfClass:[LWTabController class]])
    {
        UITabBarController *tabBar=[arr firstObject];
        tabBar.selectedIndex=0;
        [self.navigationController setViewControllers:@[tabBar]];
    }
//    id sss=self.tabBarController;
//    
//    
//    if([self.delegate respondsToSelector:@selector(emptyPresenterPressedDeposit)])
//        [self.delegate emptyPresenterPressedDeposit];
}

-(NSString *) nibName
{
    if([UIScreen mainScreen].bounds.size.width==320)
        return @"LWEmptyBuyLykkeInContainerPresenter_iphone5";
    else if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        return @"LWEmptyBuyLykkeInContainerPresenter_ipad";
 
    }
    else
        return @"LWEmptyBuyLykkeInContainerPresenter";

}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) orientationChanged
{
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        _ipadIconTopConstraint.constant=166;
    else
        _ipadIconTopConstraint.constant=87;
}


@end
