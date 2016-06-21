//
//  LWMathKeyboardView.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 14.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMathKeyboardView.h"
#import "LWMathKeyboardCursorView.h"

typedef NS_ENUM(NSInteger, LWMathKeyboardViewNumpad) {
    LWMathKeyboardViewNumpad0=0,
    LWMathKeyboardViewNumpad1,
    LWMathKeyboardViewNumpad2,
    LWMathKeyboardViewNumpad3,
    LWMathKeyboardViewNumpad4,
    LWMathKeyboardViewNumpad5,
    LWMathKeyboardViewNumpad6,
    LWMathKeyboardViewNumpad7,
    LWMathKeyboardViewNumpad8,
    LWMathKeyboardViewNumpad9,
    LWMathKeyboardViewNumpadDot,
    LWMathKeyboardViewNumpadBackspace
};

typedef NS_ENUM(NSInteger, LWMathKeyboardViewSign) {
    LWMathKeyboardViewSignDivide=1,
    LWMathKeyboardViewSignMultiply,
    LWMathKeyboardViewSignSubtract,
    LWMathKeyboardViewSignAdd,
    LWMathKeyboardViewSignEquals
};


@interface LWMathKeyboardView () {
    
    NSInteger previousSign;
    NSNumber *previousNumber;
    NSNumber *currentOperNumber;
    UIButton *highlightedSignButton;
    
    NSString *textFieldString;
    
    LWMathKeyboardCursorView *cursorView;
    
    BOOL isVisibleNow;
}

@property (weak, nonatomic) IBOutlet UIButton *delimiterButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *snippetButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numpadButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *signButtons;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;


#pragma mark - Actions

- (IBAction)snippetButtonClick:(UIButton *)sender;
- (IBAction)numpadButtonClick:(UIButton *)sender;
- (IBAction)signButtonClick:(UIButton *)sender;




@end


@implementation LWMathKeyboardView


#pragma mark - Root



-(void) awakeFromNib
{
    [super awakeFromNib];
    
    self.isVisible=NO;
    
}

-(void) setIsVisible:(BOOL)isVisible
{
    isVisibleNow=isVisible;
    cursorView.hidden=!isVisibleNow;
}

-(BOOL) isVisible
{
    return isVisibleNow;
}

-(void) setTargetTextField:(UITextField *)targetTextField
{
    textFieldString=targetTextField.text;
    _targetTextField=targetTextField;
    [cursorView removeFromSuperview];
    
    cursorView=[[LWMathKeyboardCursorView alloc] init];
    [targetTextField addSubview:cursorView];
    cursorView.center=CGPointMake(targetTextField.bounds.size.width-cursorView.bounds.size.width/2, targetTextField.bounds.size.height/2);
}

-(void) setText:(NSString *)text
{
    if(text.length==0)
        text=@"0";
    textFieldString=text;
    previousSign=0;
    previousNumber=nil;
    currentOperNumber=nil;
    [self highlightSign:nil];
}

- (void)updateView {
    NSArray *SnippedValues = @[@(100),@(1000),@(10000)];
    
    int item = 0;
    for (UIButton *button in self.snippetButtons) {
        NSString *value = [NSString stringWithFormat:@"%d", [SnippedValues[item] intValue]];
        [button setTitle:value forState:UIControlStateNormal];
        ++item;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(self.bounds.size.width==320)
    {
        for(UIButton *b in _numpadButtons)
        {
            b.titleLabel.font=[UIFont fontWithName:@"ProximaNova-Light" size:25];
        }
    }
    
    const CGFloat whLine = 1; // 1px between elements
    
    CGFloat wTotal = self.frame.size.width;
//    CGFloat wSign = [self.signButtons.firstObject frame].size.width;
    CGFloat wSign=wTotal/4-whLine*3;;
    CGFloat wNumpadArea = wTotal - wSign - whLine;
    CGFloat wNumpad = (wNumpadArea - whLine * 2) / 3;
    CGFloat wSnippet = wNumpadArea/3;//(wTotal - whLine * 2) / 3;
    
    CGFloat hTotal = self.frame.size.height;
    CGFloat hSnippet = [self.snippetButtons.firstObject frame].size.height;
    CGFloat hNumpadArea = hTotal - hSnippet - whLine;
    CGFloat hNumpad = (hNumpadArea - whLine * 3) / 4;
    CGFloat hSign = hNumpadArea / 5;
    
    for (NSInteger i = 0; i < self.snippetButtons.count; i++) {
        UIButton *button = self.snippetButtons[i];
        button.frame = CGRectMake(i * (wSnippet ), 0, wSnippet, hSnippet);
    }
    
    self.doneButton.frame=CGRectMake(wSnippet*self.snippetButtons.count, 0, self.bounds.size.width-(wSnippet*self.snippetButtons.count), hSnippet);
    for (NSInteger i = 0; i < self.signButtons.count; i++) {
        UIButton *button = self.signButtons[i];
        button.frame = CGRectMake(wNumpadArea + whLine, hSnippet + whLine + i * hSign, wSign, hSign);
    }
    NSInteger col = 0;
    NSInteger row = -1;
    for (NSInteger i = 0; i < self.numpadButtons.count; i++, col++) {
        if (i % 3 == 0) {
            col = 0;
            ++row;
        }
        UIButton *button = self.numpadButtons[i];
        button.frame = CGRectMake(col * (wNumpad + whLine),
                                  (hSnippet + whLine) + row * (hNumpad + whLine),
                                  wNumpad,
                                  hNumpad);
    }
    
    [self.delimiterButton setTitle:@"." forState:UIControlStateNormal];
}



#pragma mark - Actions

- (IBAction)snippetButtonClick:(UIButton *)sender {
    
    NSString *str = sender.titleLabel.text;
    textFieldString = str;
    previousSign=0;
    previousNumber=nil;
    currentOperNumber=nil;
    [self highlightSign:nil];
    
    if([self.delegate respondsToSelector:@selector(mathKeyboardView:volumeStringChangedTo:)])
        [self.delegate mathKeyboardView:self volumeStringChangedTo:textFieldString];
}

- (IBAction)numpadButtonClick:(UIButton *)sender {
    
    if(highlightedSignButton || currentOperNumber)
    {
        previousSign=highlightedSignButton.tag;
        [self highlightSign:nil];
        previousNumber=@(textFieldString.floatValue);
        currentOperNumber=nil;
        textFieldString=@"0";
    }
    
    
    if(sender.tag==LWMathKeyboardViewNumpadBackspace)
    {
            NSRange range = NSMakeRange(textFieldString.length - 1, 1);
            textFieldString = [textFieldString
                                         stringByReplacingCharactersInRange:range
                                         withString:@""];
            if(textFieldString.length==0)
                textFieldString=@"0";
 
    }
    else if(sender.tag==LWMathKeyboardViewNumpadDot)
    {
            if([textFieldString rangeOfString:@"."].location==NSNotFound && self.accuracy.intValue>0)
                textFieldString = [textFieldString stringByAppendingString:@"."];
    }
    else
    {
        
        if([textFieldString isEqualToString:@"0"])
        {
            textFieldString=[NSString stringWithFormat:@"%d", (int)sender.tag];
        }
        else
        {
            BOOL flagCanAdd=YES;
            if([textFieldString rangeOfString:@"."].location!=NSNotFound)
            {
                NSArray *arr=[textFieldString componentsSeparatedByString:@"."];
                if([arr[1] length]>=self.accuracy.intValue)
                    flagCanAdd=NO;
            }
            if(flagCanAdd)
                textFieldString=[textFieldString stringByAppendingFormat:@"%d", (int)sender.tag];
        }
    }
    
    if([self.delegate respondsToSelector:@selector(mathKeyboardView:volumeStringChangedTo:)])
        [self.delegate mathKeyboardView:self volumeStringChangedTo:textFieldString];

}

- (IBAction)signButtonClick:(UIButton *)sender
{
    NSInteger tag=sender.tag;
    
    if(textFieldString.length>=2)
    {
        NSString *lastSymbol=[textFieldString substringFromIndex:textFieldString.length-1];
        if([lastSymbol isEqualToString:@"."])
            textFieldString=[textFieldString substringToIndex:textFieldString.length-1];
        
    }
    
    if([self.delegate respondsToSelector:@selector(mathKeyboardView:volumeStringChangedTo:)])
        [self.delegate mathKeyboardView:self volumeStringChangedTo:textFieldString];

    if(previousSign==0 && tag!=LWMathKeyboardViewSignEquals)
    {
        previousNumber=@(textFieldString.floatValue);
        currentOperNumber=nil;
        [self highlightSign:sender];
        return;
    }
    
    if(previousSign>0 && tag!=LWMathKeyboardViewSignEquals && currentOperNumber!=nil)
    {
        previousSign=0;
        previousNumber=@(textFieldString.floatValue);
        currentOperNumber=nil;
        [self highlightSign:sender];
        return;
    }
    if(previousSign>0 && tag!=LWMathKeyboardViewSignEquals && highlightedSignButton==nil && previousNumber && currentOperNumber==nil)
    {
       
        float nextValue=[self makeAriphmeticOperation:previousSign val1:previousNumber.floatValue val2:textFieldString.floatValue];
        textFieldString=[self stringFromNumber:nextValue];
        [self highlightSign:sender];
        previousSign=0;
        previousNumber=nil;
        
        if([self.delegate respondsToSelector:@selector(mathKeyboardView:volumeStringChangedTo:)])
            [self.delegate mathKeyboardView:self volumeStringChangedTo:textFieldString];

        return;
    }
    
    
    if(tag==LWMathKeyboardViewSignEquals)
    {
        if(highlightedSignButton)
        {
            previousSign=highlightedSignButton.tag;
            previousNumber=@(textFieldString.floatValue);
            [self highlightSign:nil];
        }
        if(previousSign==0)
            return;
        
        
        float nextValue;
        if(!currentOperNumber)
        {
            nextValue=[self makeAriphmeticOperation:previousSign val1:previousNumber.floatValue val2:textFieldString.floatValue];
            currentOperNumber=@(textFieldString.floatValue);
        }
        else
            nextValue=[self makeAriphmeticOperation:previousSign val1:textFieldString.floatValue val2:currentOperNumber.floatValue];
        
        
        textFieldString=[self stringFromNumber:nextValue];

        if([self.delegate respondsToSelector:@selector(mathKeyboardView:volumeStringChangedTo:)])
            [self.delegate mathKeyboardView:self volumeStringChangedTo:textFieldString];

    }
}

-(NSString *) stringFromNumber:(float) number
{
    NSString *string;
    
    if(number==(int)number)
        string=[NSString stringWithFormat:@"%d", (int)number];
    else
        string=[NSString stringWithFormat:@"%f", number];
    
    if(string.length>10)
    {
        string=[string substringToIndex:10];
    }
    if([string rangeOfString:@"."].location!=NSNotFound)
    {
        while(1)
        {
            if(string.length==1)
                break;
            NSString *lastSymbol=[string substringFromIndex:string.length-1];
            if([lastSymbol isEqualToString:@"0"])
            {
                string=[string substringToIndex:string.length-1];
                continue;
            }
            if([lastSymbol isEqualToString:@"."])
            {
                string=[string substringToIndex:string.length-1];
            }
            break;
        }
    }
    return string;
}

-(float) makeAriphmeticOperation:(NSInteger) oper val1:(float) val1 val2:(float) val2
{
    if(oper==LWMathKeyboardViewSignAdd)
        return val1+val2;
    else if(oper==LWMathKeyboardViewSignDivide)
        return val1/val2;
    else if(oper==LWMathKeyboardViewSignMultiply)
        return val1*val2;
    else if(oper==LWMathKeyboardViewSignSubtract)
        return val1-val2;
    
    return 0;
}


-(IBAction)doneClicked:(id)sender
{
    if([self.delegate respondsToSelector:@selector(mathKeyboardDonePressed:)])
        [self.delegate mathKeyboardDonePressed:self];
}

-(void) highlightSign:(UIButton *) button
{
    for(UIButton *b in _signButtons)
    {
        b.backgroundColor=[UIColor whiteColor];
    }
    button.backgroundColor=[UIColor colorWithRed:247.0/255 green:248.0/255 blue:249.0/255 alpha:1];
    
    highlightedSignButton=button;
}





@end
