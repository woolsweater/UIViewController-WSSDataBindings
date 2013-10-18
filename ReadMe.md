UIViewController+WSSDataBindings

This is a category on UIViewController that implements dirt-simple data
bindings between a key path on the controller and a key path on another object.

Bindings are created via `WSSBind:toObject:withKeyPath:`, which mirrors Cocoa's
NSKeyValueBindingCreation protocol method, although you may note the absence of
an "options" dictionary (see the "dirt-simple" epithet above). This registers 
the controller to KVObserve the target's key path. It creates a Block which 
will later use KVC to update the bound value, and it immediately sets the bound
value.

The Block is stored in a dictionary that's associated to the controller, and
is keyed via a private class, WSSBindingKey. WSSBindingKey just wraps up the
target of the binding and its key path.

The implementation has one catch: in order to avoid implementing 
`observeValueForKeyPath:ofObject:change:context:` in a category (unlikely to 
cause a problem in this case, but wise to avoid in general*), the actual VC
implementation must include that method, calling 
`WSSEvaluateBindingForKeyPath:ofObject:usingValue:` and passing the bound-to 
key path and object, and the new value as retrieved from the KVO change 
dictionary:

    - (void)observeValueForKeyPath:(NSString *)keyPath
                         ofObject:(id)object
                           change:(NSDictionary *)change
                          context:(void *)context
    {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        [self WSSEvaluateBindingForKeyPath:keyPath
                                  ofObject:object
                                usingValue:newValue];
    
    }

Another "feature" of the "dirt-simple" nature of this implementation is that 
there's no way to remove a binding. I may add that, but doing it in a way which
mirror's Cocoa's simple `unbind:`, passing the _controller's_ key path,
complicates the storing of the binding Block to a degree that doesn't make it
worthwhile to me right now.

Of course, the code is dedicated to the public domain, so you're welcome to do
whatever the hell you want with it, including implementing that bit. 
See License.txt for details. I appreciate attribution, but it's not technically
necessary. Enjoy!
    
---
*And necessary if you want to use that method for something else in your VC!