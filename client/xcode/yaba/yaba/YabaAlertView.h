//
//  YabaGoogleLoginView.h
//  yaba
//
//  Created by TwoPi on 16/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YabaAlertView;

@protocol YabaAlertViewDelegate <NSObject>
@optional

- (void)alertView:(YabaAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;


@end

@interface YabaAlertView : UIView

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* message;
@property (nonatomic) NSInteger cancelButtonIndex;
@property (nonatomic) NSInteger firstButtonIndex;
@property (nonatomic) NSInteger numberOfButtons;

@property (nonatomic,readonly) UIView * contentView;
@property (nonatomic, weak) id<YabaAlertViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString*)title
                      message:(NSString*)message
                      delegate:(id)delegate
                      cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;

@end


