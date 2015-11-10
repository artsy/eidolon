#import "RACAlertAction.h"
@import RxSwift;
#import <objc/runtime.h>

static void *RACAlertActionCommandKey = &RACAlertActionCommandKey;
static void *RACAlertActionEnabledDisposableKey = &RACAlertActionEnabledDisposableKey;

@implementation RACAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style {
    return [super actionWithTitle:title style:style handler:^(UIAlertAction *action) {
        [((RACAlertAction *)action).command execute:action];
    }];
}

- (RACCommand *)command {
    return objc_getAssociatedObject(self, RACAlertActionCommandKey);
}

- (void)setCommand:(RACCommand *)command {
    objc_setAssociatedObject(self, RACAlertActionCommandKey, command, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // Check for stored signal in order to remove it and add a new one
    RACDisposable *disposable = objc_getAssociatedObject(self, RACAlertActionEnabledDisposableKey);
    [disposable dispose];

    if (command == nil) return;

    disposable = [command.enabled setKeyPath:@keypath(self, enabled) onObject:self];
    objc_setAssociatedObject(self, RACAlertActionEnabledDisposableKey, disposable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
