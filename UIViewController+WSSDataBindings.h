/*
 *  UIViewController+WSSDataBindings.h
 *
 * Created by Joshua Caswell on 10/17/13.
 * This code is in the public domain. I retain no copyright, and it is offered
 * without restriction _or warranty_. You are free to use the code in whatever
 * way you like. If you would like to mention that I created the code, it will
 * be appreciated, but it isn't at all necessary. For further details, please
 * see License.txt
 */

#import <UIKit/UIKit.h>

@interface UIViewController (WSSDataBindings)

/*
 * Establish a binding between the key path given by `binding` and the key path
 * `path` on `target`. This uses KVO to update the bound property, and also
 * immediately sets the value via KVC.
 */
- (void)WSSBind:(NSString *)binding
       toObject:(id)target
    withKeyPath:(NSString *)path;


/* This needs to be called from each view controller's implementation
 * of observeValueForKeyPath:ofObject:change:context: in order for the
 * the bindings to work. This is to avoid overriding that method in a 
 * category, which is unlikely to cause a problem in this case, but generally
 * is a very bad idea.
 */
- (void)WSSEvaluateBindingForKeyPath:(NSString *)path
                            ofObject:(id)target
                          usingValue:(id)value;

@end
