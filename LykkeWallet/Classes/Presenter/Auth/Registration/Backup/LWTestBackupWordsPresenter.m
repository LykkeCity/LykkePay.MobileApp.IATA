//
//  LWTestBackupWordsPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTestBackupWordsPresenter.h"
#import "LWPrivateKeyManager.h"

@interface LWTestBackupWordsPresenter ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *showButton;

@end

@implementation LWTestBackupWordsPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)showButtonPressed:(id) sender
{
    NSArray *arr=[[self.textField.text lowercaseString] componentsSeparatedByString:@" "];
    if(arr.count!=12)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Слов должно быть 12" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    BOOL success=[[LWPrivateKeyManager shared] savePrivateKeyLykkeFromSeedWords:arr];
    if(success==NO)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не получилось сгенерировать ключ. Проверьте слова." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSString *message=[NSString stringWithFormat:@"Приватный ключ: %@\n\nПубличный: %@", [LWPrivateKeyManager shared].wifPrivateKeyLykke, [LWPrivateKeyManager shared].publicKeyLykke];
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Успешно" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    


    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
