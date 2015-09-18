#import <UIKit/UIKit.h>

@class RACCommand;

@interface RACAlertAction : UIAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler __attribute__((unavailable("For this subclass, use actionWithTitle:style: instead.")));
+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style;

/// Sets the actions's command. When the action is invoked, the command is
/// executed with the self. The button's enabledness is bound to the
/// command's `enabled`.
@property (nonatomic, strong) RACCommand *command;

@end
