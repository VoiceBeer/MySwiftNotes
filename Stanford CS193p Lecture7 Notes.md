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
>
> You can even specify that implementers must implement a given initializer (if you're a class, then you have to mark the initializer required)

### How an implementer says "I implement that protocol"

```Swift
class SomeClass: SuperclassOfSomeClass, SomeProtocol, AnotherProtocol {
    // implementation of SomeClass here, including ...
    required init(...) // In a class, intis must be marked required (or otherwise a subclass might not conform)
    // which must include all the properties and methods in SomeProtocol & AnotherProtocol
}
```

> Claims of conformance to protocols are listed after the superclass for a class

> Obviously, enums and structs would not have the superclass part

```Swift
enum SomeEnum: SomeProtocol, AnotherProtocol {}
```

> You are allowed to add protocol conformance via an extension

```Swift
extension Something: SomeProtocol {
    // implementation of SomeProtocol here
    // no stored propertied though
}
```

### Using protocols like the type that they are!
```Swift
// Declaration
protocol Moveable {
    mutating func move(to point: CGPoint)
}
class Car: Moveable {
    func move(to point: CGPoint) { ... }
    func changeOil()
}
struct Shape: Moveable {
    mutating func move(to point: CGPoint) { ... }
    func draw()
}
let prius: Car = Car()
let square: Shape = Shape()

// Operation
var thingToMove: Moveable = prius
thingToMove.moveTo(...)
thingToMove.changeOil() // Wrong, what matters is the type when it comes to sending the messages, not what's actually in there
thingToMove = squre
let thingToMove: [Moveable] = [prius, square]

func slide(slider: Moveable) {
    let positionToSlideTo = ...
    slider.moveTo(positionToSlideTo)
}
slider(prius)
slider(square)

func slipAndSlide(x: Slippery & Moveable)
slipAndSlide(prius) //Wrong, because prius doesn't implement slippery
```

## Advanced use of Protocols
### Mixing in generics makes protocol even more powerful
> Protocols can be used to restrict a type that a generic can handle
>
> Consider the type that was "sort of " Range<T> ... this type is actually ...

```Swift
struct Range<Bound: Comparable> {
    let lowerBound: Bound
    let upperBound: Bound
}
```

> Comparable is a protocol which dictates that the given type must implement greater/less than

> Making a protocol that itself uses generics is also a very leveraged API design approach

### "Multiple inheritance" with protocols
> Consider the struct CountableRange (i.e. what you get with 3..<5) ...
> This struct implements MANY protocols (here are just a few):

```Swift
IndexableBase - startIndex, endIndex, index(after:) and subscripting (e.g. [])
Indexable - index(offsetBy:)
BidirectionalIndexable - index(before:)
Sequence - makeIterator (and thus supports for in)
Collection - basically Indexable & Sequence
```

### Extensions also contribute to the power of protocols
> An extension can be used to add default implementation to a protocol
>
> Since there's no storage, said implementation has to be in terms of other API in the protocol

> For example, for the ```Sequence``` protocol, you really only need to implement ```makeIterator``` (An iterator implements the IteratorProtocol which just has the method next().)
>
> If you do, you will automatically get implementations for all these other methods in ```Sequence```: ```contains```,```forEach()```,```joined(separator:)```,```min()```,```max()```, even ```filter()``` and ```map()```.
>
> All of these are implemented via an extension to the ```Sequence``` protocol

## Delegation
### A very important (simple) use of protocols
> It's a way to implement "blind communication" between a View and its Controller

![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/942AB74854B24BDC9110601E89F32920/3177)

### How it plays out
> 1. A View declares a delegation protocol (i.e. what the View wants the Controller to do for it)
> 2. The View's API has a weak delegate property whose type is that delegation protocol
> 3. The View uses the delegate property to get/do things it can't own or control on its own
> 4. The Controller declares that it implements the protocol
> 5. The Controller sets self as the delegate of the View by setting the property in #2 above
> 6. The Controller implements the protocol (probabbly it has lots of optional methods in it)

### Now the View is hooked up to the Controller
> But the View still has no idea what the Controller is, so the View remains generic/reusable

### Example
> UIScrollView has a delegate property

```Swift
weak var delegate: UIScrollViewDelegate?
```
> The ```UIScrollViewDelegate``` protocol looks like this

```Swift
@objc protocol UIScrollViewDelegate {
    optional func scrollViewDidScroll(scrollView: UIScrollView)
    optional func viewForZooming(in scrollView: UIScrollView) -> UIView
    // ... and many more...
}
```
> A Controller with a UIScrollView in its View would be declared like this ...
> 
> ``` class MyViewController: UIViewController, UIScrollViewDelegate { ... }```
>
> And in its viewDidLoad() or in the scroll view outlet setter, it would do ... ```scrollView.delegate = self```
>
> And it then would implement any of the protocol's methods it is interested in

## UIScrollView
### Adding subviews to a UIScrollView
```Swift
scrollView.contentSize = CGSize(width: 3000, height: 2000)
logo.frame = CGRect(x: 2700, y: 50, width: 120, height: 180)
scrollView.addSubview(logo)
aerial.frame = CGRect(x: 150, y: 200, width: 2500, height: 1600)
scrollView.addSubview(aerial)
```
### Scrolling in a UIScrollView
### Positioning subviews in a UIScrollView
```Swift
aerial.frame = CGRect(x: 0, y:0, width: 2500, height: 1600)
logo.frame = CGRect(x: 2300, y: 50, width: 120, height: 180)
scrollView.contentSize = CGSize(width: 2500, height: 1600)
```
### Where in the content is the scroll view currently positioned?
```Swift
let upperlLeftOfVisible: CGPoint = scrollView.contentOffset
```
> In the content area's coordinate system

### What area in a subview is currently visible?
```Swift
let visibleRect: CGRect = aerial.convert(scrollView.bounds, from: scrollView)
```
> Why the convertRect?
> 1. Because the scrollView's bounds are in the scrollView's coordinate system
> 2. And there might be zooming going on inside the scrollView too ...

### How do you create one?
> Just like any other UIView. Drag out in a storyboard or use UIScrollView(frame:).
> Or select a UIView in your storyboard and choose "Embed In -> Scroll View" from Editor menu

### To add your "too big" UIView in code using addSubview ...
```Swift
if let image = UIImage(named: "bigimage.jpg") {
    let iv = UIImageView(image: image) // iv.frame.size will = image.size
    scrollView.addSubview(iv)
}
```
> All of the subviews' frames will be in the UIScrollView's content area's coordinate system (that is, (0,0) in the upper left & width and height of contentSize.width & .height).

### Now don't forget to set the contentSize
> Common bug is to do the above lines of code (or embed in Xcode) and forget to say: ```scrollView.contentSize = imageView.frame.size (for example)```

### Scrolling programmatically
> ```func scrollRectToVisible(CGRect, animated: Bool)```

### Other things you can control in a scroll view
> Whether scrolling is enabled.
>
> Locking scroll direction to user's first "move".
>
> The style of the scroll indicators (call ```flashScrollIndicators``` when your scroll view appears)
>
> Whether the actual content is "inset" from the content area (```contentInset``` property)

### Zooming
> All UIView's have a property (transform) which is an affine transform (translate, scale, rotate)
>
> Scroll view simply modifies this transform when you zoom.
>
> Zooming is also going to affect the scroll view's contentSize and contentOffset

### Will not work without minimum/maximum zoom scale being set
```Swift
scrollView.minimumZoomScale = 0.5 // 0.5 means half its normal size
scrollView.maximumZoomScale = 2.0 // 2.0 means twice its normal size
```

### Will not work without delegate method to specify view to zoom
>```func viewForZooming(in scrollView: UIScrollView) -> UIView```
> If your scroll view only has one subview, you return it here. More? Up to you

### Zooming programatically
```Swift
var zoomScale: CGFloat
func setZoomScale(CGFloat, animated: Bool)
func zoom(to rect: CGRect, animated: Bool)
```

### Lots and lots of delegate methods
> The scroll view will keep you up to date with what's going on

### Example: delegate method will notify you when zooming ends
```Swift
func scrollViewDidEndZooming(UIScrollView, 
with view: UIView, // from method above 
atScale: CGFloat)
```
> If you redraw your view at the new scale, be sure to reset the transform back to identity