/* 
 * UIViewController+WSSDataBindings.m
 *
 * Created by Joshua Caswell on 10/18/13.
 * This code is in the public domain. I retain no copyright, and it is offered
 * without restriction _or warranty_. You are free to use the code in whatever
 * way you like. If you would like to mention that I created the code, it will
 * be appreciated, but it isn't at all necessary. For further details, please
 * see License.txt
 */

#import "UIViewController+WSSDataBindings.h"
#import <objc/runtime.h>

@interface UIViewController (WSSDataBindingAddendum)

/* 
 * Ensure the controller will be able to access the binding object (for
 * unbinding) by using the controller and the binding name as the key to tie
 * the binding to the controller with objc_setAssociatedObject().
 */
- (NSUInteger)WSSAssociateKeyForBinding:(NSString *)bindingName;

@end

@implementation UIViewController (WSSDataBindingAddendum)

- (NSUInteger)WSSAssociateKeyForBinding:(NSString *)bindingName
{
    return ((NSUInteger)self ^ [bindingName hash]);
}

@end

#pragma mark -

/*
 * A binding object establishes itself as a KVObserver on the binding target
 * and uses KVC to update the bound property whenever necessary.
 * Its lifetime is tied to the target's, so that it will not linger as a
 * registered observer. It can also be destroyed via the bound object, using
 * -[UIViewController(WSSDataBindings) WSSUnbind:]
 */

@interface WSSBinding : NSObject

+ (instancetype)bindingWithBoundName:(NSString *)name onObject:(id)bound
                           toKeyPath:(NSString *)path ofObject:(id)target;

- (void)unbind;

@end

@implementation WSSBinding
{
    // When the binding is destroyed because its boundToTarget (which owns it
    // for memory management purposes) is being deallocated, a __weak ref
    // causes the target to warn that it still has registered observers. It's
    // not clear why that is; it's plausible that the ref is getting zeroed
    // too early, but it seems to still be valid in -[WSSBinding dealloc].
    // __unsafe_unretained works, but this does imply possible fragility here.
    // The boundObj is __weak, however, so that if it disappears somehow,
    // setValue:forKeyPath: will not raise an exception.
    NSString * bindingName;
    __weak id boundObj;
    NSString * boundToPath;
    __unsafe_unretained id boundToTarget;
}

+ (instancetype)bindingWithBoundName:(NSString *)name onObject:(id)bound
                           toKeyPath:(NSString *)path ofObject:(id)target
{
    return [[self alloc] initWithBoundName:name onObject:bound
                               toKeyPath:path ofObject:target];
}

- (id)initWithBoundName:(NSString *)name onObject:(id)bound
              toKeyPath:(NSString *)path ofObject:(id)target
{
    self = [super init];
    if( !self ) return nil;
    
    bindingName = [name copy];
    boundObj = bound;
    boundToPath = [path copy];
    boundToTarget = target;
    
    [boundToTarget addObserver:self
                    forKeyPath:boundToPath
                       // Set the value immediately and also get updates
                       options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
                       context:NULL];
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [boundObj setValue:[boundToTarget valueForKeyPath:boundToPath]
                forKeyPath:bindingName];
}

- (void)dealloc
{
    [boundToTarget removeObserver:self forKeyPath:boundToPath];
}

- (void)unbind
{
    // Dissociate self; this will lead to deallocation, where deregistration
    // for observation takes place.
    NSUInteger key = [boundObj WSSAssociateKeyForBinding:bindingName];
    objc_setAssociatedObject(boundToTarget, (void *)key, nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

#pragma mark - UIViewController+WSSDataBindings

@implementation UIViewController (WSSDataBindings)

- (void)WSSBind:(NSString *)bindingName
       toObject:(id)target
    withKeyPath:(NSString *)path
{
    WSSBinding * binding = [WSSBinding bindingWithBoundName:bindingName
                                                   onObject:self
                                                  toKeyPath:path
                                                   ofObject:target];
    
    // Attach the binding to both target and controller, but only make it
    // owned by the target. This provides automatic deregistration when the
    // target is destroyed, and allows the controller to unbind at will.
    // Disregard the target and bound path for the key to allow mirroring
    // Cocoa's unbind: method; this is simplest for the controller.
    NSUInteger key = [self WSSAssociateKeyForBinding:bindingName];
    objc_setAssociatedObject(target, (void *)key, binding,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, (void *)key, binding,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (void)WSSUnbind:(NSString *)bindingName
{
    WSSBinding * binding;
    NSUInteger key = [self WSSAssociateKeyForBinding:bindingName];
    binding = objc_getAssociatedObject(self, (void *)key);
    [binding unbind];
    objc_setAssociatedObject(self, (void *)key, nil,
                             OBJC_ASSOCIATION_ASSIGN);
}

@end
