```~~
/* Sat. 7 Sept 2017
    @Vb
*/
```
[TOC]

---
# Lecture 6

## View Controller Lifecycle
> A sequence of messages is sent to a View Controller as it progresses through its "lifetime"

### The start of the lifecycle
> Creation
> 
> MVCs are most often instantiated out of a storyboard (as you've seen).
> There are ways to do it in code (rare) as well

### What then?
> - Preparation if being segued to.
> - Outlet setting.
> - Appearing and disappearing
> - Geometry changes(几何图形的改变)
> - Low-memory situations.

### After instantiation(实例化) and outlet-setting, viewDidLoad is called
> This is an exceptionally good place to put a lot of setup code
> It's better than an init because your outlets are all set up by the time this is called

```Swift
override func viewDidLoad() { // only receive it once in the lifetime of a view controller
    super.viewDidLoad() // always let super have a chance in all lifecycle methods
    // do some setup of my MVC
}
```
> One thing you may well want to do here is update your UI from your Model.
Because now you know all of your outlets are set
>
> But be careful because the geometry of your view (its bounds) is not set yet!
>
> At this point, you can't be sure you're on an iPhone 5-sized screen or an iPad or ???
>
> So do not initialize things that are geometry-dependent here

### Just before your view appears on screen, you get notified
```Swift
func viewWillAppear(_ animated: Bool) // animated is whether you are appearing over time
```
> Your view will only get "loaded" once, but it might appear and disappear a lot. 
>
> So don't put something in this method that really wants to be in viewDidLoad
>
> Otherwise, you might be doing something over and over unnecessarily

> Do something here if things your display is changing while your MVC is off-screen

> You could use this to optimize performance(优化性能) by waiting until this method is called (as opposed to view) to kick off an expensive operation (probably in another thread)
>
> Because in viewDidLoad, it's not guaranteed that you're ever gonna come on screen, but if viewWillAppear happens, you know you'll gonna on screen

> Your view's geometry is set here, but there are other places to react to geometry

#### There is a "did" version of this as well
```Swift
func viewDidAppear(_ animated: Bool)
```
> Start an animation

### And you get notified when you will disappear off screen too
> This is where you put "remember what's going on" and cleanup code

> A lot of times here you're undoing the things you did in viewDidAppear

```Swift
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated) // call super in all the viewWill/Did... methods
    // do some clean up now that we've been removed from the screen
    // but be careful not to do anything time-consuming(费时) here, or app will be sluggish(行动迟缓)
    // maybe even kick off a thread to do stuff here
}
```
#### There is a "did" version of this too
```Swift
func viewDidDisappear(_ animated: Bool)
```

### Match relationship
> ```viewDidDisappear``` matches ```viewWillAppear```, ```viewWillDisappear``` matches ```viewDidAppear``` (undo each other)

### Geometry changed
> Most of the time this will be automatically handled with Autolayout
>
> But you can get involved in geometry changes directly with these methods

```Swift
// if you wanna get involved in the geometry change of your view, before Autolayout starts, do it in this
func viewWillLayoutSubviews() 

// if you wanna wait until Autolayout does what it does and then you wanna get involved, do it in this
func viewDidLayoutSubviews()
```

> Autolayout will happen between "will" and "did"

> They are called any time a view's frame changed and its subviews were thus re-layed out.(e.g. autorotation)

> You can reset the frames of your subviews here or set other geometry-related properties

> These methods might be called more often than you'd imagine (e.g. for pre- and post- animation arrangement, etc.)
> 
> So don't do anything in here that can't properly (and efficiently) be done repeatedly

### Autorotation
> Usually, the UI changes shape when the user rotates the device between portrait/landscape
>
> You can control which orientations your app supports in the settings of your project
>
> Almost always, your UI just responds naturally to rotation with autolayout
>
> But if you, for example, want to participate in the rotation animation, you can use this method

```Swift
func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
)
```

### Low-memory situations
> In low-memory situations, ```didReceiveMemoryWarning``` gets called...

> This rarely happens, but well-designed code with big-ticket memory uses might anticipate it.

> Anything "big"(e.g. images and sounds) that is not currently in use and can be recreated relatively easily should probably be released (by setting any pointers to it to ```nil```)

### awakeFromNib()
> This method is sent to all objects that come out of a storyboard (including your Controller).
>
> Happens before outlets are set! (i.e. before the MVC is "loaded")
>
> Put code somewhere else if at all possible (e.g. viewDidLoad or viewWillAppear)

### Summary
> 1. instantiated (from storyboard usually)
> 2. awakeFromNib()
> 3. segue preparation happens
> 4. outlets get set!
> 5. viewDidLoad()
> - These pairs will be called each time your Controller's view goes on/off screen ...
    >   ```viewwillAppear``` and ```viewDidAppear```
    >   ```viewWillDisappear``` and ```viewDidDisappear```
> - These "geometry changed" methods might be called at any time after ```viewDidLoad``` ...
    >   ```viewWillLayoutSubviews``` (... then autolayout happens, then ...) ```viewDidLayoutSubviews```
> - If memory gets low, you might get ...
    > ```didReceiveMemoryWarning```
> 6. leave the heap

## Memory Management
### Automatic Reference Counting
> Reference types (classed) are stored in the heap
>
> How does the system know when to reclaim the memory for these from the heap?
>
> It "counts references" to each of them and when there are zero references, they get tossed.
>
> This is done automatically
>
> It is known as "Automatic Reference Counting" and it is NOT garbage collection

### Influencing ARC
> You can influence ARC by how you declare a reference-type var with these keywords ...
```strong```,```weak```,```unowned```

#### strong
> strong is "normal" reference counting, it's the default, don't even ever type this keyword
>
> As long as anyone, anywhere has a strong pointer to an instance, it will stay in the heap

#### weak
> weak means "if no one else is interested in this, then neither am I, set me to nil in that case" (I'm looking at this thing in the heap but if no one else is interested in the heap then you can throw it out of the heap and set me to nil)
>
> Because it has to be nil-able, weak only applies to Optional pointers to reference types
>
> A weak pointer will NEVER keep an object in the heap
>
> Great example: outlets (strongly held by the view hierarchy, so outlets can be weak)

#### unowned
> unowned means "don't reference count this; crash if I'm wrong"
>
> This is very rarely used
>
> Usually only to break memory cycles between objects (more on that in a moment), it can only used to make a memory cycle when you're 100% sure that you know who's using that pointer, because automatic reference counting is not going to be counting it as a strong reference, and it's also not going to check. And so if you use it, and that thing you're pointing to has left the heap, it will crash your program

## Closures
### Capturing
> Closures are stored in the heap as well (i.e. they are ++reference types++)
>
> They can be put in Arrays, Dictionarys, etc. They are a first-class type in Swift
>
> What is more, they "capture" variables they use from the surrounding code into the heap too.
>
> Those captured variables need to stay in the heap as long as the closure stays in the heap
>
> This can create a memory cycle

### An example
> Hard to record in words, see lecture6 1:10:45 - 1:23:51, the slides and the demo

#### essentials

```Swift
func addUnaryOperation(symbol: String, operation: (Double) -> Double)

addUnaryOperation("@"){ [unowned self]/[weak self = self] in
    self.display.textColor = UIColor.green / self?.display.textColor = UIColor.green
    return sqrt($0)
}

// unowned case: if self(view controller) is out of the heap, this would crash, but it's fine, because if the viewcontroller is not even in the heap, this calculator operation won't be executed
// weak case: self? would be nil and it will not execute the rest of that line
```