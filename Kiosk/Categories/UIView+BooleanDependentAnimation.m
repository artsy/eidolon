#import "UIView+BooleanDependentAnimation.h"

@implementation UIView (BooleanDependentAnimation)

+ (void)animateIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration :(void (^)(void))animations
{
    [self animateIf:shouldAnimate withDuration:duration delay:0 options:0 :animations completion:nil];
}

+ (void)animateIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options :(void (^)(void))animations
{
    [self animateIf:shouldAnimate withDuration:duration delay:0 options:options :animations completion:nil];
}

+ (void)animateIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration :(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    [self animateIf:shouldAnimate withDuration:duration delay:0 options:0 :animations completion:completion];
}

+ (void)animateIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration  delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options :(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    if (!shouldAnimate) {
        if(animations) animations();
        if(completion) completion(YES);
        
    } else {
        [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
    }
}

+ (void)animateIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)damping initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options :(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    if (!shouldAnimate) {
        if(animations) animations();
        if(completion) completion(YES);
        
    } else {
        [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:damping initialSpringVelocity:velocity options:options animations:animations completion:completion];
    }
}

+ (void)animateTwoStepIf:(BOOL)shouldAnimate withDuration:(NSTimeInterval)duration :(void (^)(void))initialAnimations midway:(void (^)(void))midwayAnimations completion:(void (^)(BOOL finished))completion
{
    [self animateIf:shouldAnimate withDuration:duration/2 :^{
        if (initialAnimations) {
            initialAnimations();
        }
    } completion:^(BOOL finished) {
        [self animateIf:shouldAnimate withDuration:duration/2 :^{
            if (midwayAnimations) {
                midwayAnimations();
            }
        } completion:completion];
    }];
}

@end
