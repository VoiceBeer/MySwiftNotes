```~~
/* Tues, 16 Aug 2017
    @Vb
*/
```
[TOC]

---
# Lecture 3

## Optional

> Swift里的Optional就是enum, !是用switch, if-let也是switch(if-let安全些不会崩溃只会跳出switch)

```Swift
enum Optional<T> {
    case none
    case some(T)
}

let x: String? = nil
//is
let x = Optional<String>.none

let x: String? = "hello"
//is
let x = Optional<String>.some("hello")

let y = x!
//is
switch x {
    case some(let value): y = value
    case none: //raise an exception
}

let x: String? = ...
if let y = x {
    //do
}
//is
switch x {
    case .some(let y):
        //do
    case .none:
        break
}

```

## Optional can be "chained"
```Swift
var display: UILabel? {
    if let temp1 = display {
        if let temp2 = temp1.text {
            let x = temp2.hashValue
        }
    }
}
//with Optional chaining using ? instead of ! to unwrap
if let x = display?.text?.hashValue {...} //x is an Int
let x = display?.text?.hashValue {...} //x is an Int?
//每当在Optional后面加?时, 如果它处于已赋值的状态, 那么抓取它然后继续. 如果是nil则整行都返回nil, 

```

## Optional defaulting
```Swift
let s: String? = ...
if s != nil {
    display.text = s
} else {
    display.text = " "
}
//can be expressed
display.text = s ?? " " //??运算符的左操作数非空，该运算符将返回左操作数，否则返回右操作数。

```

## Tuples

```Swift
let x: (String, Int, Double) = ("hello", 5, 0.85)
let (word, number, value) = x
print(word) //hello
print(value) //0.85
//named
let x: (w:String, i: Int, v:Double) = ("hello", 5, 0.85)
print(x.w)
print(x.v)

//Tuples as return values
func getSize() -> (weight: Double, height: Double) { return (250, 80) }
let x = getSize()
print(x.weight)//250

```

## Range
> A range in Swift is just two end points.

> A range can represent things like a selection in some text or a portion of an Array

> Range is generic, but T is comparable //range可以泛型, 但是T必须可比较, 因为range定义就是用来定范围所以要知道两个index比较大小

> Range 用法就是 ..< 和 ... 

> If the type of the upper/lower bound is an Int, ..< makes a CountableRange. //countablerange对range中所有的数都了解, 比如 0..<5就是countablerange, 他能知道里面是 0 1 2 3 4

> 如果要实现例如 for(int i=0.5; i<=15.25; i+=0.3)的话, 就要用到stride: for i in stride(from: 0.5, through: 15.25, by: 0.3), stride会创建一个新对象(closedcountablerange, ...), 

```Swift
struct Range<T> {
    var startIndex: T
    var endIndex: T
}

let array = ["a","b","c","d"]
let a = array[2...3] //["c","d"]
let b = array[2..<3] //["c"]
let d = array[4...1] //crash, lower bound must be smaller than upper bound

let f = "hello"[2..<4] //won't even compile
let f = "hello"[start..<end] //正确, 里面的start,end不是整数,是String.Index

```

## Data sturctures

> - class, struct, enum, protocol
> - 只有class可以有父类; 
> - 枚举中不能有存储属性, 枚举把它的数据保存在关联值中. 计算属性可以
> - 除了枚举外都能初始化, 枚举不需要初始化, 因为可以直接说明想要的情况
> - 结构体和枚举是值类型, 类是引用类型( let x = value type, x就不能变了; let x = reference type, 仍旧可以改变x里的值, 因为只是指向x的指针不变)

## Methods
### Parameters Names
> internal name, external name

> external name can be replaced with _ , so u won't call a func using external name: foo(123, externalSecond: 5.5) , usually use _ only to first parameter

> if u only put one parameter name, it will be both the external and internal name

```Swift
func foo(externalFirst internalFirst: Int, externalSecond internalSecond: Double) {
    var sum = 0.0
    for _ in 0..<internalFirst { sum += internalSecond}
}

func bar() {
    let result = foo(externalFirst: 123, externalSecond: 5.5)
}

```

### override, superclass, subclass
> Only reference type; override, final; 

### types, instance
> static func is on the type, not on instance of the type 

```Swift
static var pi: Double
let d = Double.pi
let x: Double = 23.85 //实例化double
let e = x.pi //wrong

```

## Properties
### Property Observers
> observe changes to any property with willSet and didSet, only used to stored properties
### Lazy Initialization
> A lazy property does not get initialized until someone accesses it

```Swift
lazy var myProperty = self.initializeMyProperty()
//在实力完全初始化之前, 这个延迟属性myProperty一定没有初始化
//所以这个myProperty语句上看已经被初始化, 但实际上还没被初始化, 直到有人访问他才真正的初始化

```

## Array
> array is a collection, and collections are sequences, and a sequence means can do for...in

```Swift
var a = Array<String>()
//same as
var a = [String]()

for animal in animals {}

//filter(includeElement: (T) -> Bool) ->[T]
let bigNumbers = [2,47,118].filter({ $0 > 20 }) //[47, 118]

//map(transform: (T) -> U) -> [U]
let stringified: [String] = [1,2,3].map { String($0) } 
// ["1", "2", "3"] 应该是map({ String($0) }), 但是是尾随闭包所以可以(如果闭包是函数的最后一个参数,则可以将闭包写在()后面,如果函数只有一个参数,并且这个参数是闭包,那么()可以不写)

//reduce(initial: U, combine: (U, T) -> U) -> U
let sum: Int = [1,2,3].reduce(0) { $0 + $1 } //adds up the numbers in the array
let sum = [1,2,3].reduce(0, +) //same thing because + is just a function in Swift

```
## Dictionary
> A dictionary is also a collection and thus can be sequenced. So for...in can be used

```Swift
var pac12teamRankings = Dictionary<String, Int>()
//same as
var pac12teamRankings = [String:Int]()

for (key, value) in pac12teamRankings {
    print("Team \(key) is ranked number \(value)")
}

```
## String
> A String is made up of Unicodes, but there's also the concept of a Character. (Café might be 5 Unicodes, but it's 4 Characters)

> 取得String里的字符可以用String结构体里的变量characters

```Swift
for c: Character in s.characters {}

let count = s.characters.count

let firstSpace: String.Index = s.character.index(of: " ")

```
## Other Classes
### NSObject
> Base class for all OC classes, some advanced feature will require you to subclass from NSObject while using Swift
### NSNumber
> Also from OC(because of NS), it can turn the Bool to Int: 0 is false, others are true except 0
### Date
### Data
> struct, value type

## Initialization
> Only need init when a value can't be set in any of these ways(using =, Optional nil, closure or use lazy), callers use your init(s) by using the name
> struct will get a default one with all properties as arguments if it has no initializers

> - set any property's value, even those that already had default values
> - call other init in your own class or struct using self.init(<args>)
> - class super.init(<args>)
> - A designated(除了convenience就是designated) init must (and can only) call a designated init that is in its immediate superclass
> - U must initialize all properties introduced by your class before calling a superclass's init //必须先初始化自身的属性后才能调用super.init
> - U must call a superclass's init before you assign a value to an inherited property
//只有调用了super.init后才能改变父类的属性

### Convenience init
> - A convenience init must (and can only) call an init in its own class
> - A convenience init must call that init before it can set any property values
> - U have to be fully initialized before your init can start using your class(在你的便利构造器开始使用这个类之前, 你必须先完全构造自身)

### Inheriting init
> - 1. If you do not implement any designated inits, you'll inherit all of your superclass's designateds 
> - 2. If you override all of your superclass's designated inits, you'll inherit all its convenience inits
> - 3. If you implement no inits, you'll inherit all of your superclass's inits
> - 4. Any init inherited by these rules qualifies to satisfy any of the rules on the previous slide

### Required init
> Any subclass must implement said init methods

### Failable init
> If an init is declared with a ? after the word init, it returns an Optional
init?(arg1: Type1, ...) {//might return nil}

```Swift
//e.g.
let image = UIImage(named: "foo") //Optional
//usually use if-let
if let image = UIImage(named: "foo") {
    //image was successfully created
} else {
    //couldn't create the image
}
```

## Any & AnyObject
> any不大用, 毕竟Swift强类型语言
> anyobject has to be a reference type, any can be anything
> To use a variable of type Any must convert

```Swift
let unknown: Any = ...
if let foo = unknown as? MyType {
    //如果foo是MyType的话...
}
```
## Casting
> casting with as? is not just for Any & AnyObject

```Swift
let vc: UIViewController = CalculatorViewController()
//vc.displayValue wrong, because vc is a UIViewController not a CalculatorViewController
if let calcVC = vc as? CalculatorViewController {
    calcVC.displayValue = 3.1415 // this's okay
}

```

## UserDefault
> A very lightweight and limited database, it only stores Property List data which is any combo of Array, Dictionary, String, Date, Data or a number (Int, etc.)

> like map?

```Swift
func set(Any?, forKey: String) // the Any has to be a Property List (or crash)
func object(forKey: String) -> Any? //the Any is guaranteed to be a Property List

let defaults = UserDefaults.standard
defaults.set(3.1415, forKey: "pi")
defaults.set([1,2,3,4,5], forKey: "My Array")
defaults.set(nil, forKey: "Some Setting")

func double(forKey: String) -> Double
func array(forKey: String) -> [Any]?
func dictionary(forKey: String) -> [String:Any]?

if !defaults.synchronize() {
    //your changes will be occasionally autosaved, but you can force them to be saved at any time with synchronize
}

```

## Assertions
> All it does is it executes the closure. If that returns true, it doesn't crash your program, if returns false, crashes your program and prints that message out (like try-catch in Java)

```Swift
assert( () -> Bool, "message")
```