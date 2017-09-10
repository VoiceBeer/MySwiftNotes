```~~
/* Sat. 10 Sept 2017
    @Vb
*/
```
[TOC]

---
# Lecture 7 

## Thrown Errors

### In Swift, methods can throw errors
> keyword throws on the end

```Swift
func save() throws
// must put calls to functions like this in a do {} block and use the word try to call them
do {
    try context.save()
} catch let error {
    // error will be something that implements the Error protocol, e.g., NSError
    // usually these are enums that have associated values to get error details
    throw error // this would re-throw the error (only ok if the method we are in throws)
}
```

> If you are certain a call will not throw, you can force try with try! ...
>
> ```try! context.save() // will crash your program if save() actually throws an error```
>
> Or you can conditionally try, turning the return into an Optional (which will be nil if fail) ...
> 
> ```let x = try? errorProneFunctionThatReturnsAnInt() // x will be Int? ```
> 
> Means try to call this method that throws, and if it does throw, just give back nil, errorProneFunctionThatReturnsAnInt() returns int, but if it returns an Int throws, then x will be nil, so x is Int?

## Entensions
### Extending existing data structures
> Can add methods/properties to a class/struct/enum (even if you don't have the source)

```Swift
// adds a method to UIViewController
extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController
        } else {
            return self
        }
    }
}
```
> Can be used to clean up the Face demo ```prepare(for segue:, sender:)``` code...

```Swift
// From
var destination: UIViewController? = segue.destinationViewController
if let navcon = destination as? UINavigationController {
    destination = navcon.visibleViewController
}
if let myvc = destination as? MyVC {...}

// To
if let myvc = segue.destinationViewController.contentViewControoler as? MyVC {...}
```

### Some restrictions
> You can't re-implement methods or properties that are already there (only add new ones)
> The properties you add can have no storage associated with them (computed only)

## Protocols
### A way to express an API more concisely
> A protocol is simply a collection of method and property declarations

### A protocol is a TYPE
> It can be used almost anywhere any other type is used: vars, function parameters, etc.

### The implementation of a Protocol's methods and properties
> The implementation is provided by an implementing type (any class, struct or enum).
>
> Because of this, a protocol can have no storage associated with it (any storage required to implement the protocol is provided by an implementing type)
>
> It is also possible to add implementation to a protocol via an extension to that protocol (but remember that extensions also cannot use any storage)

### Three aspects to a protocol
> 1. the protocol declaration (which properties and methods are in the protocol)
> 2. a class, struct or enum declaration that claims to implement the protocol
> 3. the code in said class, struct or enum that implements the protocol

### Optional methods in a protocol
> Normally any protocol implementor must implement all the methods/properties in the protocol
>
> However, it's possible to mark some methods in a protocol optional(Not the Optional type, 这个方法可写可不写)
>
> Any protocol that has optional methods must be marked @objc
>
> And any optional-protocol implementing class must inherit from NSObject
>
> These sorts of protocols are used often in iOS for delegation
>
> Except for delegation, a protocol with optional methods is rarely (if ever) used
>
> As you can tell from the @objc designation, it's mostly for backwards compatibility

### Declaration of the protocol itself
```Swift
protocol SomeProtocol: InheritedProtocol1, InheritedProtocol2 {
    // must specify whether a property is get only or both get and set
    var someProperty: Int { get set }
    func aMethod(arg1: Double, anotherArgument: String) -> SomeType
    mutating func changeIt()
    init(arg: Type)
}
```
> Anyone that implements SomeProtocol must also implement InheritedProtocol1 and 2
>
> Swift don't support multiple inheritance but it support multiple protocols
>
> Any functions that are expected to mutate the receiver should be marked mutating (unless you are going to restrict your protocol to class implementers only with class keyword ```protocol SomeProtocol: class, Inheri...```)
>
> You can even specify that implementers must implements a given initializer