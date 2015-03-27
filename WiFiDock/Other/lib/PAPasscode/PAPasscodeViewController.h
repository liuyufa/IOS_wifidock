//
//  PAPasscodeViewController.h
//  PAPasscode
//
//  Created by Denis Hennessy on 15/10/2012.
//  Copyright (c) 2012 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PasscodeActionSet,
    PasscodeActionEnter,
    PasscodeActionChange
} PasscodeAction;

@class PAPasscodeViewController;

@protocol PAPasscodeViewControllerDelegate <NSObject>

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller;

@optional

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller;
- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller;
- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller;
- (void)PAPasscodeViewController:(PAPasscodeViewController *)controller didFailToEnterPasscode:(NSInteger)attempts;

@end

@interface PAPasscodeViewController : UIViewController {
    UIView *contentView;
    NSInteger phase;
    UILabel *promptLabel;
    UILabel *messageLabel;
    UIImageView *failedImageView;
    UILabel *failedAttemptsLabel;
    UITextField *passcodeTextField;
    UIImageView *digitImageViews[4];
    UIImageView *snapshotImageView;
}

@property (readonly,nonatomic) PasscodeAction action;
@property (weak,nonatomic) id<PAPasscodeViewControllerDelegate> delegate;
@property (copy,nonatomic) NSString *passcode;
@property (copy,nonatomic) NSString *fileName;
@property (copy,nonatomic) NSString *filePath;
@property (assign,nonatomic) BOOL simple;
@property (assign,nonatomic) NSInteger failedAttempts;
@property (copy,nonatomic) NSString *enterPrompt;
@property (copy,nonatomic) NSString *confirmPrompt;
@property (copy,nonatomic) NSString *changePrompt;
@property (copy,nonatomic) NSString *message;

- (id)initForAction:(PasscodeAction)action;

@end
