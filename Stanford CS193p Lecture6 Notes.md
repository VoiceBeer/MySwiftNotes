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


