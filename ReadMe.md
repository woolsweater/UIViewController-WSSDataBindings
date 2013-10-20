**UIViewController+WSSDataBindings**

This is a category on `UIViewController` that implements dirt-simple data bindings between a key path on the controller and a key path on another object.

Bindings are created via `WSSBind:toObject:withKeyPath:`, which mirrors Cocoa's `NSKeyValueBindingCreation` protocol method, although you may note the absence of an "options" dictionary (see the "dirt-simple" epithet above). This registers a private `WSSBinding` helper object to KVObserve the target's key path. The helper is associated to both the controller and the bound-to object, and owned by the latter. The key for the association is a combination of the address of the controller and the hash of the binding name. 

This keying allows the controller to undo the binding using only the name. The  fact that the helper is owned by the bound-to target means that it will be  destroyed and can deregister itself from observing when the target begins  deallocation.

Future modifications may include insertion of value transformers.

Of course, the code is dedicated to the public domain, so you're welcome to do whatever the hell you want with it, including implementing that bit. See License.txt for details. I appreciate attribution, but it's not technically necessary. Enjoy!