//
//  LWWebViewDocumentPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 05/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@interface LWWebViewDocumentPresenter : LWAuthComplexPresenter

@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSString *documentTitle;

@end
