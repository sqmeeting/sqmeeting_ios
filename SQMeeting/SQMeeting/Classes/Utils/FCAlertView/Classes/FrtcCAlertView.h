//
//  FrtcCAlertView.h
//  ShiftRide
//
//  Created by Nima Tahami on 2016-07-10.
//  Copyright © 2016 Nima Tahami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "FrtcPortraitView.h"

typedef void (^FrtcCAlertViewCallback)(NSInteger index, NSString *title);

@protocol FrtcCAlertViewDelegate;

@interface FrtcCAlertView : FrtcPortraitView <UITextFieldDelegate> {
    
    UIVisualEffectView *backgroundVisualEffectView;
    CGFloat defaultHeight;
    CGFloat defaultSpacing;
    UIView *alertView;
    UIView *alertViewContents;
    CAShapeLayer *circleLayer;
    NSMutableArray *alertButtons;
    NSMutableArray *alertTextFields;
    NSMutableArray *alertTextFieldHolder;
    NSInteger alertViewWithVector;
    NSString *doneTitle;
    UIImage *vectorImage;
    NSString *alertType;
    CGRect alertViewFrame;
    CGRect currentAVCFrames;
    CGRect descriptionLabelFrames;
    AVAudioPlayer *player;
    NSInteger alertTypeRatingHearts;
    NSInteger alertTypeRatingStars;
    UIView *ratingController;
    UIButton *item1;
    UIButton *item2;
    UIButton *item3;
    UIButton *item4;
    UIButton *item5;
    NSInteger currentRating;
}

@property (nonatomic, weak) id<FrtcCAlertViewDelegate> delegate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic, retain) NSAttributedString *attributedTitle;
@property (nonatomic, retain) NSAttributedString *attributedSubTitle;
@property (nonatomic, retain) UIFont *titleFont;
@property (nonatomic, retain) UIFont *subtitleFont;
@property (nonatomic, retain) UIView *alertBackground;
@property (nonatomic, retain) UITextField *textField;
@property CGFloat customHeight;
@property CGFloat customSpacing;
@property NSInteger numberOfButtons;
@property NSInteger autoHideSeconds;
@property CGFloat cornerRadius;
@property BOOL dismissOnOutsideTouch;
@property BOOL overrideForcedDismiss;
@property BOOL hideAllButtons;
@property BOOL hideDoneButton;
@property BOOL avoidCustomImageTint;
@property BOOL blurBackground;
@property BOOL bounceAnimations;
@property BOOL darkTheme;
@property BOOL detachButtons;
@property BOOL fullCircleCustomImage;
@property BOOL hideSeparatorLineView;
@property CGFloat customImageScale;

- (void) makeAlertTypeWarning;
- (void) makeAlertTypeCaution;
- (void) makeAlertTypeSuccess;
- (void) makeAlertTypeProgress;

typedef void (^FCRatingBlock)(NSInteger rating);
@property (nonatomic, copy) FCRatingBlock ratingBlock;

- (void) makeAlertTypeRateHearts:(FCRatingBlock)ratingBlock;
- (void) makeAlertTypeRateStars:(FCRatingBlock)ratingBlock;

@property BOOL animateAlertInFromTop;
@property BOOL animateAlertOutToTop;

@property BOOL animateAlertInFromRight;
@property BOOL animateAlertOutToRight;

@property BOOL animateAlertInFromBottom;
@property BOOL animateAlertOutToBottom;

@property BOOL animateAlertInFromLeft;
@property BOOL animateAlertOutToLeft;

- (void) setAlertSoundWithFileName:(NSString *)filename;

- (void) showAlertInView:(UIViewController *)view withTitle:(NSString *)title withSubtitle:(NSString *)subTitle withCustomImage:(UIImage *)image withDoneButtonTitle:(NSString *)done andButtons:(NSArray *)buttons;

- (void) showAlertInWindow:(UIWindow *)window withTitle:(NSString *)title withSubtitle:(NSString *)subTitle withCustomImage:(UIImage *)image withDoneButtonTitle:(NSString *)done andButtons:(NSArray *)buttons;

- (void) showAlertWithTitle:(NSString *)title withSubtitle:(NSString *)subTitle withCustomImage:(UIImage *)image withDoneButtonTitle:(NSString *)done andButtons:(NSArray *)buttons;

- (void) showAlertWithAttributedTitle:(NSAttributedString *)title withSubtitle:(NSString *)subTitle withCustomImage:(UIImage *)image withDoneButtonTitle:(NSString *)done andButtons:(NSArray *)buttons;

- (void) showAlertWithTitle:(NSString *)title withAttributedSubtitle:(NSAttributedString *)subTitle withCustomImage:(UIImage *)image withDoneButtonTitle:(NSString *)done andButtons:(NSArray *)buttons;

- (void) showAlertWithAttributedTitle:(NSAttributedString *)title withAttributedSubtitle:(NSAttributedString *)subTitle withCustomImage:(UIImage *)image withDoneButtonTitle:(NSString *)done andButtons:(NSArray *)buttons;


- (void)setAlertViewAttributes:(NSString *)title withSubtitle:(NSString *)subTitle withCustomImage:(UIImage *)image withDoneButtonTitle:(NSString *)done andButtons:(NSArray *)buttons;

- (void) dismissAlertView;

typedef void (^FCActionBlock)(void);
@property (nonatomic, copy) FCActionBlock actionBlock;
@property (nonatomic, copy) FCActionBlock doneBlock;
- (void)addButton:(NSString *)title withActionBlock:(FCActionBlock)action;
- (void)doneActionBlock:(FCActionBlock)action;

typedef void (^FCTextReturnBlock)(NSString *text);
@property (nonatomic, copy) FCTextReturnBlock textReturnBlock;
- (void)addTextFieldWithText:(NSString *)Text andTextReturnBlock:(FCTextReturnBlock)textReturn;
- (void)addTextFieldWithPlaceholder:(NSString *)placeholder andTextReturnBlock:(FCTextReturnBlock)textReturn;
- (void)addTextFieldWithCustomTextField:(UITextField *)field andPlaceholder:(NSString *)placeholder andTextReturnBlock:(FCTextReturnBlock)textReturn;

@property (nonatomic, retain) UIColor * colorScheme;
@property (nonatomic, retain)  UIColor * titleColor;
@property (nonatomic, retain)  UIColor * subTitleColor;
@property (nonatomic, retain) UIColor *alertBackgroundColor;

@property (nonatomic, retain)  UIColor * doneButtonTitleColor;
@property (nonatomic, retain)  UIFont * doneButtonCustomFont;
@property (nonatomic, retain)  UIColor * doneButtonHighlightedBackgroundColor;

@property (nonatomic, retain)  UIColor * firstButtonTitleColor;
@property (nonatomic, retain)  UIFont * firstButtonCustomFont;
@property (nonatomic, retain)  UIColor * firstButtonBackgroundColor;
@property (nonatomic, retain)  UIColor * firstButtonHighlightedBackgroundColor;

@property (nonatomic, retain)  UIColor * secondButtonTitleColor;
@property (nonatomic, retain)  UIFont * secondButtonCustomFont;
@property (nonatomic, retain)  UIColor * secondButtonBackgroundColor;
@property (nonatomic, retain)  UIColor * secondButtonHighlightedBackgroundColor;

@property (nonatomic, retain) UIColor * flatTurquoise;
@property (nonatomic, retain) UIColor * flatGreen;
@property (nonatomic, retain) UIColor * flatBlue;
@property (nonatomic, retain) UIColor * flatMidnight;
@property (nonatomic, retain) UIColor * flatPurple;
@property (nonatomic, retain) UIColor * flatOrange;
@property (nonatomic, retain) UIColor * flatRed;
@property (nonatomic, retain) UIColor * flatSilver;
@property (nonatomic, retain) UIColor * flatGray;

@end

@protocol FrtcCAlertViewDelegate <NSObject>
@optional
- (void)FrtcCAlertView:( FrtcCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title;
- (void)FrtcCAlertViewDismissed:(FrtcCAlertView *)alertView;
- (void)FrtcCAlertViewWillAppear:(FrtcCAlertView *)alertView;
- (void)FCAlertDoneButtonClicked:(FrtcCAlertView *)alertView;

@end