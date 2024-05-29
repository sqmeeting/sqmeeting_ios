#import "FrtcCustomPresentationController.h"

@implementation FrtcCustomPresentationController

- (CGRect)frameOfPresentedViewInContainerView {
    CGRect containerBounds = self.containerView.bounds;
    return CGRectMake(0, CGRectGetMaxY(containerBounds) - self.presentedViewHeight, CGRectGetWidth(containerBounds), self.presentedViewHeight);
}

- (void)presentationTransitionWillBegin {
    
    [self setupDimmingView];
    [self.containerView addSubview:self.dimmingView];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.dimmingView.alpha = 1.0;
    } completion:nil];
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.dimmingView.alpha = 0.0;
    } completion:nil];
}

- (void)setupDimmingView {
    self.dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    self.dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.dimmingView.alpha = 0.0;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped)];
    [self.dimmingView addGestureRecognizer:tapGesture];
}

- (void)dimmingViewTapped {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
