/* 
 * UIViewController+WSSDataBindings.m
 *
 * Created by Joshua Caswell on 10/17/13.
 * This code is in the public domain. I retain no copyright, and it is offered
 * without restriction _or warranty_. You are free to use the code in whatever
 * way you like. If you would like to mention that I created the code, it will
 * be appreciated, but it isn't at all necessary. For further details, please
 * see License.txt
 */

#import "UIViewController+WSSDataBindings.h"
#import <objc/runtime.h>


/*
 * WSSBindingKey wraps up the bound-to object and key path so that they can
 * be used in combination as a key for the bindings dictionary.
 */
@interface WSSBindingKey : NSObject <NSCopying>

+ (instancetype)bindingKeyWithKeyPath:(NSString *)path ofObject:(id)target;

@end

@implementation WSSBindingKey
{
    NSValue * targetVal;
    NSString * keyPath;
}

+ (instancetype)bindingKeyWithKeyPath:(NSString *)path ofObject:(id)target
{
    return [[self alloc] initWithKeyPath:path ofObject:target];
}

- (id)initWithKeyPath:(NSString *)path ofObject:(id)target
{
    self = [super init];
    if( !self ) return nil;
    
    // Take a pointer to the target to avoid it having to conform to NSCopying
    targetVal = [NSValue valueWithNonretainedObject:target];
    keyPath = [path copy];
    
    return self;
}

- (NSUInteger)hash
{
    static NSUInteger halfNSUIntegerBits = CHAR_BIT * sizeof(NSUInteger) / 2;
    NSUInteger targetHash = [targetVal hash];
    targetHash = (targetHash << halfNSUIntegerBits) |
                 (targetHash >> halfNSUIntegerBits);
    return targetHash ^ [keyPath hash];
}

- (BOOL)isEqual:(id)other
{
    if( self == other ) return YES;
    
    if( ![other isKindOfClass:[self class]] ) return NO;
    
    WSSBindingKey * otherKey = other;
    
    return [targetVal isEqual:otherKey->targetVal] &&
           [keyPath isEqual:otherKey->keyPath];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [WSSBindingKey bindingKeyWithKeyPath:keyPath
                                       ofObject:[targetVal nonretainedObjectValue]];
}

@end

typedef void (^BindingBlock)(id);

@implementation UIViewController (WSSDataBindings)

- (void)WSSBind:(NSString *)bindingPath
       toObject:(id)target
    withKeyPath:(NSString *)path
{
    [target addObserver:self
             forKeyPath:path
                options:NSKeyValueObservingOptionNew
                context:NULL];
    
    __weak id weakSelf = self;
    BindingBlock binding = ^(id val){
        [weakSelf setValue:val forKeyPath:bindingPath];
    };
    WSSBindingKey * key = [WSSBindingKey bindingKeyWithKeyPath:path
                                                      ofObject:target];
    [[self WSSBindingsDict] setObject:binding forKey:key];

    // Get the initial value
    [self setValue:[target valueForKeyPath:path] forKeyPath:bindingPath];
}

static char bindings_dict_key;
- (NSMutableDictionary *)WSSBindingsDict
{
    NSMutableDictionary * bindingsDict;
    bindingsDict = objc_getAssociatedObject(self, &bindings_dict_key);
    if( !bindingsDict ){
        bindingsDict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &bindings_dict_key,
                                 bindingsDict,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return bindingsDict;
}

- (void)WSSEvaluateBindingForKeyPath:(NSString *)path
                            ofObject:(id)target
                          usingValue:(id)value
{
    WSSBindingKey * key = [WSSBindingKey bindingKeyWithKeyPath:path
                                                      ofObject:target];
    BindingBlock binding = [[self WSSBindingsDict] objectForKey:key];
    if( binding ){
        binding(value);
    }
}

@end
