```~~
/* Sat. 4 Sept 2017
    @Vb
*/
```
[TOC]

---
# Lecture 5

## Gestures
> Gestures are recognized by instance of UIGestureRecognizer which is an abstract class

> Two sides to using a gesture recognizer
> 1. Adding a gesture recognizer to a UIView (asking the UIView to "recognize" that gesture)
> 2. Providing a method to "handle" that gesture (not necessarily handled by the UIView)

> The adding of the gesture recognizer is done with a method called addGestureRecognizer in UIView, and that method is usually called by controllers (Side 1)

> The second is provided by the UIView or a Controller, it depends on whether the gesture affects the model, or whether the gesture affects just the view.

### Adding a gesture recognizer to a UIView
> Imagine we wanted a UIView in our Controller's View to recognize a "pan" gesture. We can configure it to do so in the property observer for the outlet to that UIView

```Swift
@IBOutlet weak var pannableView: UIView {
    didSet {
        let panGestureRecognizer = UIPanGestureRecognizer(
            target: self, action: #selector(ViewController.pan(recognizer:))
            //target: self(ViewController), action: use #selector to choose a method(three ways: ViewController.pan, self.pan, pan(because the default is self))
        )
        pannableView.addGestureRecognizer(panGestureRecognizer)
    }
}
```
> The property observer's didSet code gets called when iOS hooks up this outlet at runtime

> First create the gesture recognizer, in this case named UIPanGestureRecognizer which has two arguments, both are the handler, the target is who's gonna handle it, and the action is what method is going to handle it

> Then add it to the view, only views are capable of recognizing gestures.

### A handler for a gesture needs gesture-specific information
> Each concrete subclass provides special methods for handling that type of gesture
> For example, UIPanGestureRecognizer provides 3 methods

```Swift
func translation(in: UIView?) -> CGPoint //cumulative since start of recognition(从识别开始后的积累), means how far this pan moved since it started
func velocity(in: UIView?) -> CGPoint // how fast the finger is moving (points/s)
func setTranslation(CGPoint, in: UIView?)
```

### The abstract superclass also provides state information

```Swift
var state: UIGestureRecognizerState { get }
```
> This sits around in ```.possible``` until recognition starts

> - For a continuous gesture (e.g. pan), it moves from ```.began``` thru repeated ```.changed``` to ```.ended```
> - For a discrete (e.g. swipe) gesture, it goes straight to ```.ended``` or ```.recognized```
> - Also can go to ```.failed //Start a gesture and system realize like, that wasn't a pan gesture, that was the start of a swipe, so it switches to a swipe.``` or ``` .cancelled //Like in the middle of panning and phone call comes in, so the pan gesture was cancelled```

### Pan handler
```Swift
func pan(recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
        case .changed: fallthrough 
        //Switch-case在别的语言例如 Java 中的话 case 是会都自动执行的要加 break 来跳出,但 Swift 不是,所以要是想要让他 fall through 的话就要加 fallthrough 关键字,直接 case.changed,.ended 也可以
        case .ended:
            let translation = recognizer.translation(in: pannableView) // Get the location of the pan in the pannableView's coordinate system
            // update anything that depends on the pan gesture using translation.x and .y
            recognizer.setTranslation(CGPoint.zero, in: pannableView) // By resetting the translation, the next one we get will be incremental movement
        default: break
    }
}
```

### UIPinchGestureRecognizer
```Swift
var scale: CGFloat //not read-only (can reset)
var velocity: CGFloat { get } //scale factor per second
```
### UIRotationGestureRecognizer
```Swift
var rotation: CGFloat //not read-only (can reset); inradians
var velocity: CGFloat { get } //radians per second
```
### UISwipeGestureRecognizer
> Set up the direction and number of fingers you want. Since it's discrete, the handler's only gonna be called once.

```Swift
var direction: UISwipeGestureRecognizerDirection // which swipe directions you want
var numberOfTouchesRequired: Int // finger count
```
### UITapGestureRecognizer
> Set up the number of taps and fingers you want

```Swift
var numberOfTapsRequired: Int // single tap, double tap, etc.
var numberOfTouchesRequired: Int // finger count
```

## Multiple MVCs
> iOS provides some Controllers whose View is "other MVCs" Examples: ```UITableBarController```, ```UISplitViewController```, ```UINavigationController```

### UITabBarController
![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/6A5D415F13C7480CA08CA5251DE571CB/2472)

### UISplitViewController
![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/8A89006045A84349BEEB4104D0ADBB30/2479)

### UINavigationController
![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/4DC39997CBB84E7EB3DE4D38882347CB/2483)

### Accessing the sub-MVCs
> You can get the sub-MVCs via the viewControllers property 

```Swift
var viewControllers: [UIViewController]? { get set }
// Can be optional (e.g. for tab bar)
// for a tab bar, they are in order, left to right, in the array
// for a split view, [0] is the master and [1] is the detail
// for a navigation controller, [0] is the root and the rest are in order on the stack
// even though this is settable, usually setting happens via storyboard, segues, or other
// for example, navigation controller's push and pop methods
```

> Every UIViewController knows the Split View, Tab Bar or Navigation Controller it is currently in by calling these properties in UIViewController

```Swift
var tabBarController: UITabBarController? { get }
var splitViewController: UISplitViewController? { get }
var navigationController: UINavigationController? { get }

// for example, to get the detail (right side) of the split view controller you are in
if let detail: UIViewController? = splitViewController?.viewControllers[1] { ... }
```

## Segues
> A segue is that one MVC can cause another MVC to appear

### Kinds of segues (they will adapt to their environment)
> - Show Segue (will push in a Navigation Controller, else Modal//动态)
> - Show Detail Segue (will show in Detail of a Split View or will push in a Navigation Controller)
> - Modal Segue (take over the entire screen while the MVC is up)
> - Popover Segue (make the MVC appear in a little popover window)

### Segues always create a new instance of an MVC

### prepare(for segue: UIStoryboardSegue, sender: Any?)

```Swift
func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
        switch identifier {
            case "Show Graph":
                if let vc = segue.destinationViewController as? GraphController {
                    vc.property1 = ...
                    vc.callMethodToSetItUp(...)
                }
            default: break
        }
    }
}
```
> The ***segue*** passed in contains important information about this segue:
> 1. the identifier from the storyboard
> 2. the Controller of the MVC you are segueing to (which was just created for you)

> The ***sender*** is either the instigating object from a storyboard (e.g. a UIButton) or the sender you provided if you invoked the segue manually in code

> Here is the ***identifier*** from the storyboard (it can be nil, so be sure to check for that case)
> 
> Your Controller might support preparing for lots of different segues from different instigators so this identifier is how you'll know which one you're preparing for

> ***segue.destinationViewController as? GraphController***
>
> Here we are looking at the Controller of the MVC we're segueing to
>
> It is Any so we must cast it to the Controller we (should) know it to be

> ***vc.property1 = ...*** and ***vc.callMethodToSetItUp(...)***
>
> It is crucial to understand that this preparation is happening BEFORE outlets get set!
>
> It is a very common bug to prepare an MVC thinking its outlets are set