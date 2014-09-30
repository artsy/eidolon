#import <UIKit/UIKit.h>

@interface UIView (BooleanDependentAnimation)

/// Only animates if shouldAnimate is true, otherwise will perform block synchronously
+ (void)animateIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration :(void (^)(void))animations;

/// Only animates if shouldAnimate is true, otherwise will perform block synchronously with options
+ (void)animateIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options :(void (^)(void))animations;

/// Only animates if shouldAnimate is true, otherwise will perform block synchronously and perform completion in the same manner
+ (void)animateIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration :(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

/// Only animates with delay and options if shouldAnimate is true, otherwise will perform block synchronously and perform completion in the same manner
+ (void)animateIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options :(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

///Only animates with spring if shouldAnimate is true, otherwise will perform block synchronously and perform completion in the same manner
+ (void)animateIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)damping initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options :(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

/// Useful for a fade animation
+ (void)animateTwoStepIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration :(void (^)(void))initialAnimations midway:(void (^)(void))midwayAnimations completion:(void (^)(BOOL finished))completion;

@end
