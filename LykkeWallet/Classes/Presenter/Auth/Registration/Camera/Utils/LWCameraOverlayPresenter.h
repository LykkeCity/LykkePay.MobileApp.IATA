//
//  LWCameraOverlayPresenter.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 26.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKPresenter.h"
#import "NSObject+GDXObserver.h"
#import "LWAuthSteps.h"

@protocol LWCameraOverlayDelegate<NSObject>
@required
- (void)fileChoosen:(NSDictionary<NSString *,id> *)info;
- (void)pictureTaken;
@end


@interface LWCameraOverlayPresenter : TKPresenter {
    
}

@property (weak, nonatomic) id<LWCameraOverlayDelegate> delegate;
@property (weak, nonatomic) UIImagePickerController *pickerReference;
@property (assign, nonatomic) LWAuthStep step;

- (void)updateView;

@end
