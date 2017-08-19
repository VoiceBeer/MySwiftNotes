```~~
/* Tues, 17-19 Aug 2017
    @Vb
*/
```
[TOC]

---
# Lecture 4
## Views
> i.e. UIView subclass represents a rectangular area

### Hierarchical
> Only one superview(var superview: UIView?), but many (or zero) subviews(var subviews: [UIView]), those later in the subviews array are on top of those earlier

> Usually graphically, but also can be done in code.

```Swift
func addSubview(_ view: UIView) //sent to view's (soon to be) superview
func removeFromSuperview() //sent to the view you want to remove (not its superview)
```

### UIWindow
> The UIView at the very, very top of the view hierarchy (even includes status bar), usually only one UIWindow in an entire iOS application

### The start of the view hierarchy
> The top of the hierarchy is the Controller's var view: UIView
> MVC, C中一般都拥有这个指向视图层次结构顶层的var变量

## Initializing a UIView
> Try to avoid an initializer if possible but having one in UIView is slightly more common than having a UIViewController initializer

```Swift
init(frame: CGRect) //initializer if the UIView is created in code
init(coder: NSCder) //initializer if the UIView comes out of a storyboard

// if you need an initializer, implement them both
func setup() {...}
override init(frame: CGRect) {
    super.init(frame: frame) //a designed initializer
    setup()
}
required init(coder aDecode: NSCoder) {
    super.init(coder: aDecoder)
    //a required initializer
    setup()
}
//都调用setup能保证无论是通过代码还是Interface Builder构造，都能够正确地完成构造

//Another alternative to initializers in UIView is awakeFromNib()
awakeFromNib() 
//他不是初始化器，是在初始化完成后立马调用的。这个要跟生命周期有关，生命周期里，把一些预先准备的窗口、控件和屏幕初始化后冷冻保存在nib文件里，当该对象被唤醒之后，会向他发送awakeFromNib来让他知道自己是清醒状态

```

## Coordinate System Data Structures
### CGFloat
> Always use this instead of Double or Float for anything to do with a UIView's coordinate system
> Convert to/from a Double or Float by using initializers, e.g. let cgf = CGFloat(aDouble)
### CGPoint
> Simply a struct with two CGFloats in it: x and y.

```Swift
var point = CGPoint(x: 37.0, y: 55.2)
point.y -= 30
point.x += 20.0

```
### CGSize
> Also a struct with two CGFloats in it: width and height.

```Swift
var size = CGSize(width: 100.0, height: 50.0)
size.width += 42.5
size.height += 75
```

### CGRect
> A struct with a CGPoint and a CGSize in it

```Swift
struct CGRect {
    var origin: CGPoint
    var size: CGSize
}
let rect = CGRect(origin: a CGPoint, size: aCGSize) //there are other inits as well

//lots of properties and functions on CGRect
var minX: CGFloat //left edge
var midY: CGFloat //midpoint vertically
intersects(CGRect) -> Bool //CGRect.intersects(anotherCGRect), 返回两个CGRect是否有交集
contains(CGPoint) -> Bool //does the CGRect contain the given CGPoint?

```

## View Coordinate System
> Origin is upper left

> UIKit中增加y代表向下

> Units are points, not pixels

> With this var contentScaleFactor: CGFloat in UIView, you can find out how many pixels there are per point, in other words how high resolution your screen is

> The most important var in all of UIView is this one: bounds(var bounds: CGRect), bounds.size.width can get the width of bounds， bounds.origin -> (0, 0)

```Swift
var center: CGPoint //the center of a UIView in its superview's coordinate system
var frame: CGRect //the rect containing a UIView in its superview's coordinate system

```
> Dont get confused with frame and center, bounds decides where you are drawing, frame and center is where you are in your superview

## bounds vs frame
> center is where your center is in your superview's coordinate system(UIView.center会返回这个UIView的中心在他父类视图中的位置 )

![iamge](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/268DDAA650A64CA1A663BF1456BB3A2D/1963)
> never use frame or center to draw, they are only used to position you in your super view

## Creating Views
> Most often created via your stroyboard -> Xcode's Object Palette, after draging out a generic UIView, you must use the *Identity Inspector* to changes its class to your subclass

> On rare occasion, you will create a UIView via code, use the frame initializer -> let newView = UIView(frame: myViewFrame), or just let newView = UIView() (frame will be CGRect.zero, means width and height are all zero, and it'll be at 0,0, so u won't even see it)

![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/53D1C1276EAE481885A741FC77B9EDD3/1988)

## Custom Views
> Two situations that need to create own UIView subclass. 1: want to do some custom drawing on screen. 2: need to handle touch events in a special way(i.e. different than a button or slider does)

> To draw, just create a UIView subclass and override drawRect

```Swift
override func draw(_ rect: CGRect)
```
> The rect is a subarea of the entire drawing area descibed by UIView's bounds

> NEVER CALL draw(CGRect)!!! EVER! Or else! If you want to draw, the only way is create a UIView subclass and override drawRect. If your view needs to be redrawn, let the system know that by calling...

```Swift
setNeedsDisplay()
setNeedsDisplay(_ rect: CGRect) //rect is the area that needs to be redrawn, iOS will then call your draw(CGRect) at an appropriate time
```

### How to implement draw(CGRect)
> 1. Get a drawing *context* and tell it what to draw like, move to this point, draw a line to here, add an arc over here, put some text over here, things like that.
> 2. Create a path object using UIBezierPath and tell this object things like move to ... over here

### Core Graphics Concepts (CG)
> The function UIGraphicsGetCurrentContext() gives a context you can use in draw(CGRect) and then you can tell it to create a path by moving and all that stuff. 
> 1. Get a context to draw into
> 2. Create paths (out of lines, arcs, etc)
> 3. Set drawing attributes like colors, fonts, textures, linewidths, linecaps, etc
> 4. Stroke of fill the above-created paths with the given attributes

### UIBezierPath
> UIBezierPath encapsulates all of those CG concepts into an object

> UIBezierPath automatically draws in the "current" context (draw(CGRect) sets this up for you)

> Has methods to draw (lineto, arc, etc.) and set attributes (linewidth, etc.)

> Use UIColor to set stroke and fill colors, then it has methods to *stroke* and/or *fill* 

## Defining a Path
> 1. Create a UIBezierPath
> 2. Move around, add lines or arcs to the path
> 3. Close the path (if you want)
> 4. Set attributes and stroke/fill

```Swift
// 1
let path = UIBezierPath()
// 2
path.move( to: CGPoint(80, 50))
path.addLine( to: CGPoint(140, 150))
path.addLine( to: CGPoint(10, 150))
//3
path.close()
//4
UIColor.green.setFill() //a method in UIColor, not UIBezierPath
UIColor.red.setStroke() //a method in UIColor
path.linewidth = 3.0 //a property in UIBezierPath, not UIColor
path.fill() //fill is a method in UIBezierPath, after saying path.fill, a green triangle appeared
path.stroke //a method in UIB, get a red line around the triangle 

```

## Drawing
> UIBezierPath can draw other common shapes like roundRect, oval, etc.

> By saying addClip() to clip your drawing to a UIBezierPath's path

> func contains(_ point: CGPoint) -> Bool can return whether the point is inside the path, the path must be closed

## UIColor
> There are type(aka static) vars for standard colors, e.g. let green = UIColor.green

> You can also create them from RGB, HSB or even a pattern (using UIImage)

> Background color of a UIView: var backgroundColor: UIColor

> Colors can have alpha (transparency)

```Swift
let semitransparentYellow = UIColor.yellow.withAlphaComponent(0.5)
//Alpha is between 0.0(fully transparent) and 1.0(fully opaque)
```
> Drawing in a view with transparency requires to set the UIView var opaque = false, or also can make your entire UIView transparent by setting UIView's var alpha: CGFloat, not UIColor

## View Transparency
### What happens when views overlap and have transparency?
> Subviews list order determines who's in front. The subview sub zero is all the way in the back, then other views is in the order in front of it.

### Hide a view without removing it from hierarchy
> By saying var hidden: Bool, almost identical to saying alpha = 0

## Drawing Text
> To draw in drawRect, use NSAttributedString, but it's not like String (i.e. where let means immutable and var means mutable)

```Swift
let text = NSAttributedString(String: "hello")
text.draw(at: aCGPoint)
let textSize: CGSize = text.size // how much space the string will take up

```
> If you want a mutable NSAttributedString, use NSMutableAttributedString, let mutableText = NSMutableAttributedString(String: "some string")

## Attributed String
### Setting attributes on an attributed string

```Swift
func setAttributes(_ attributes: [String:Any]?, range: NSRange)
func addAttributes(_ attributes: [String:Any]?, range: NSRange)
```

## Fonts
> Get preferred font for a given text style (e.g. body, etc) using this UIFont type method: static func preferred(forTextStyle: UIFontTextStyle) -> UIFont (UIFontTextStyle.headline/.body/.footnote)

> System fonts usually appear on things like buttons, static func systemFont(ofSize: CGFloat) -> UIFont, static func boldSystemFont(ofSize: CGFloat) -> UIFont

## Drawing Images
> UIImageView or create a UIImage object:

> let image: UIImage? = UIImage(named: "foo") //note that its an Optional, add "foo.jpg" to your project in the Images.xcassets file

> Another way, get from files:

```Swift
let image: UIImage? = UIImage(contentsOfFile: aString)
let image: UIImage? = UIImage(data: aData) //raw jpg, png, tiff, etc. image data
```
> Or even create one by drawing with Core Graphics

> Once you have a UIImage, you can blast its bits on screen

```Swift
let image: UIImage = ...
image.draw(atPoint: aCGPoint) //the upper left corner put at aCGPoint
image.draw(inRect: aCGRect) //scales the image to fit aCGRect
image.drawAsPattern(inRect: aCGRect) //tiles the image into aCGRect
```
## Redraw on bounds change
> By default, there is no redraw, the "bits" are scaled to the new bounds size

> It's controlled via a var in UIView called contentMode, it can be things like .left/.right/.top/..../.center, don't scale the view, just place it somewhere. ContentMode has .scaleToFill/.scaleAspectFill/.scaleAspectFit // .ScaleToFill is the default, but redraw is the most thing