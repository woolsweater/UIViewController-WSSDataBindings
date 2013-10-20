/*
 *  UIViewController+WSSDataBindings.h
 *
 * Created by Joshua Caswell on 10/18/13.
 * This code is in the public domain. I retain no copyright, and it is offered
 * without restriction _or warranty_. You are free to use the code in whatever
 * way you like. If you would like to mention that I created the code, it will
 * be appreciated, but it isn't at all necessary. For further details, please
 * see License.txt
 */

#import <UIKit/UIKit.h>

@interface UIViewController (WSSDataBindings)

/*
 * Bind the named property (which can be any valid key _path_) on the
 * controller to the path on the target. The property will be updated via
 * KVO whenever the targeted value changes.
 */

- (void)WSSBind:(NSString *)bindingName
       toObject:(id)target
    withKeyPath:(NSString *)path;

/*
 * Remove the named binding. Since a property cannot be bound to more than one
 * target at a time, only the name is required.
 */
- (void)WSSUnbind:(NSString *)bindingName;

@end