//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

/// 对象,内存管理,字符串,数据  Mon, 8 Aug 2017
/*
 Tips:
 1.convenience, init, deinit, required
 2.存储属性,计算属性(get [set]),观察器(willSet, didSet),惰性属性(直到首次访问才会初始化的属性)
 3.protocol extension open public internal fileprivate private 运算符重载 <T>
 4.内存管理 retain-count retain-cycle weak unowned
 5.数据 NSData
 6.序列化和反序列化 encode decode
 7.设计模式
*/

//对象
class Vehicle {
    var color : String?
    var maxSpeed = 80
    
    func description() -> String{
        return "A \(self.color!) vehicle"
    }
    func travel() {
        print("Traveling at \(maxSpeed) kph")
    }
}
var tempVehicle = Vehicle()
tempVehicle.color = "Red"
tempVehicle.maxSpeed = 100
tempVehicle.description()
tempVehicle.travel()

//继承,Swift一个类只能有一个父类,不同于c++多重继承
class Car: Vehicle {
    override func description() -> String {
        let description = super.description()
        return description + ", which is a car"
    }
}
var tempCar = Car()
tempCar.color = "Blue"
tempCar.description()

//初始化与反初始化,相当于构造函数和析构函数,c++里的()和~(),反初始化在对象的retaincount降到0时运行
class InitAndDeinitExample {
    //指定的初始化器（也就是主初始化器）
    init() {
        print("I've been created!")
    }
    //便捷初始化器,是调用上述指定初始化器所必需的
    convenience init (test: String) {
        self.init() //必需
        print("I was called with the convenience initializer!")
    }
    //反初始化器
    deinit {
        print("I'm going away")
    }
}
/*
 转自http://swifter.tips/init-keywords/
 Swift有超级严格的初始化方法
 Swift 中不加修饰的 init 方法都需要在方法中保证所有非 Optional 的实例变量被赋值初始化,而在子类中也强制 (显式或者隐式地) 调用 super 版本的 designated 初始化,所以无论如何走何种路径,被初始化的对象总是可以完成完整的初始化的。
 所有的 convenience 初始化方法都必须调用同一个类中的 designated 初始化完成设置,另外 convenience 的初始化方法是不能被子类重写或者是从子类中以 super 的方式被调用的。
 初始化原则：
 初始化路径必须保证对象完全初始化(就是之前提到的所有非Optional的实例变量被赋值初始化),这可以通过调用本类型的 designated 初始化方法来得到保证；
 子类的 designated 初始化方法必须调用父类的 designated 方法,以保证父类也完成初始化。
 */
class ClassA {
    let numA: Int
    init(num: Int) {
        numA = num
    }
    
    convenience init(bigNum: Bool) {
        self.init(num: bigNum ? 10000 : 1)
    }
}

class ClassB: ClassA {
    let numB: Int
    
    override init(num: Int) {
        numB = num + 1
        super.init(num: num)
    }
}
/*
 只要在子类中实现重写了父类 convenience 方法所需要的 init 方法的话,我们在子类中就也可以使用父类的 convenience 初始化方法了。比如在上面的代码中,我们在 ClassB 里实现了 init(num: Int) 的重写。这样,即使在 ClassB 中没有 bigNum 版本的 convenience init(bigNum: Bool),我们仍然还是可以用这个方法来完成子类初始化：
 */
let anObj = ClassB(bigNum: true)
anObj.numA
// anObj.numA = 10000, anObj.numB = 10001
/*对于某些我们希望子类中一定实现的 designated 初始化方法,我们可以通过添加 required 关键字进行限制,强制子类对这个方法重写实现。这样做的最大的好处是可以保证依赖于某个 designated 初始化方法的 convenience 一直可以被使用。一个现成的例子就是上面的 init(bigNum: Bool)：如果我们希望这个初始化方法对于子类一定可用,那么应当将 init(num: Int) 声明为必须,这样我们在子类中调用 init(bigNum: Bool) 时就始终能够找到一条完全初始化的路径了：
*/
class ClassC {
    let numA: Int
    required init(num: Int) {
        numA = num
    }
    
    convenience init(bigNum: Bool) {
        self.init(num: bigNum ? 10000 : 1)
    }
}

class ClassD: ClassC {
    let numB: Int
    
    required init(num: Int) {
        numB = num + 1
        super.init(num: num)
    }
}
/*另外需要说明的是,其实不仅仅是对 designated 初始化方法,对于 convenience 的初始化方法,我们也可以加上 required 以确保子类对其进行实现。这在要求子类不直接使用父类中的 convenience 初始化方法时会非常有帮助。
*/
//初始化器还可以返回nil 在init关键字后面加个问号,并在初始化器确定它不能成功地构造该对象时,使用return nil
class ClassNil {
    init(){
        
    }
    convenience init? (value: Int) {
        self.init()
        if value > 5 {
            //不能初始化这个对象；返回nil,表示初始化失败
            return nil
        }
    }
}

let failableExample = ClassNil(value: 6)

//属性 计算属性(利用代码来计算他们的取值)和存储属性
class Rectangle {
    var width: Double = 0.0
    var height: Double = 0.0
    var area: Double { //不使用=用{},提供一个get,视情况加set
        //计算getter
        get {
            return width * height
        }
        set {
            //假定边长相等
            width = sqrt(newValue)
            height = sqrt(newValue)
        }
    }
}
var rect = Rectangle()
rect.width = 3.0
rect.height = 4.5
rect.area
rect.area = 9
rect.width

//属性观察器,类似于数据库里的触发器？ 创建一个属性观察器,需在属性后面添加大括号(类似计算属性的做法),并包含willSet(在属性值发生变化之前被调用,获得的是一个将要设定的值)和didSet(获得一个旧值).
class PropertyObserverExample {
    var number : Int = 0 {
        willSet(newNumber) {
            print("\(self.number) is about to change to \(newNumber)")
        }
        didSet(oldNumber) {
            print("Just changed from \(oldNumber) to \(self.number)")
        }
    }
}
var observer = PropertyObserverExample()
observer.number = 4 //0 is about to change to 4
                   //Just changed from 0 to 4  所以首先是willSet再是didSet,里面的self.number的变化的话可以举个例子,比如 a++ 就相当于willSet里的self.number, ++a 就相当于didSet里的self.number

//惰性属性 挺有趣的这个,可以推迟到真正需要时才初始化
class SomeExpensiveClass{
    init(id: Int) {
        print("Expensive class \(id) created")
    }
}
class LazyPropertyExample {
    var expensiveClass1 = SomeExpensiveClass(id: 1)
    lazy var expensiveClass2 = SomeExpensiveClass(id: 2)
    
    init() {
        print("Classes created")
    }
}
var lazyExample = LazyPropertyExample()
lazyExample.expensiveClass1
lazyExample.expensiveClass2 //创建lazyExample时就自动init了expensiveClass1,但是直到调用了expensiveClass2时才init了expensiveClass2

//协议 类似于接口interface
protocol Blinking {
    var isBlinking : Bool { get }
    var blinkSpeed : Double { get set } //必须是可获取和可设置
    func startBlinking(speed: Double) -> Void
}
class Light : Blinking { //可遵守多个协议,例如Light : Blinking1, Blinking2
    var isBlinking: Bool = false
    var blinkSpeed: Double = 0.0
    func startBlinking(speed: Double) {
        print("Start blinking")
        self.isBlinking = true
        self.blinkSpeed = speed
    }
}
var aBlinkingThing : Blinking?
aBlinkingThing //nil
aBlinkingThing = Light()
aBlinkingThing //light()
aBlinkingThing?.startBlinking(speed: 4.0)
aBlinkingThing?.blinkSpeed

//扩展 这个蛮实用的,可以扩展任意类型.扩展后会增加到每一个该类型的实例中.  扩展中只能添加计算属性,不能添加存储属性  还可以用扩展来使一个类型遵守一个协议
extension Int {
    var doubled : Int {
        return self * 2
    }
    func multiplyWith(anotherNumber: Int) -> Int {
        return self * anotherNumber
    }
}
2.doubled
2.multiplyWith(anotherNumber: 4)
extension Int : Blinking {
    var isBlinking: Bool {
        return false
    }
    var blinkSpeed: Double {
        get {
            return 0.0;
        }
        set {
            // do nothing
        }
    }
    func startBlinking(speed: Double) {
        print("I am the integer \(self). I do not blink")
    }
}
2.isBlinking
2.startBlinking(speed: 2.0)

//访问控制 private public internal 默认都是internal,但是定义为private的类的成员声明默认是private 
//五种修饰符访问权限open > public > interal > fileprivate > private
/*
 1.private : private访问级别所修饰的属性或者方法只能在当前类里访问。
 2.fileprivate : fileprivate访问级别所修饰的属性或者方法在当前的Swift源文件里可以访问
 3.internal（默认访问级别,internal修饰符可写可不写）: internal访问级别所修饰的属性或方法在源代码所在的整个模块都可以访问。如果是框架或者库代码,则在整个框架内部都可以访问,框架由外部代码所引用时,则不可以访问。如果是App代码,也是在整个App内部可以访问。
 4.public : 可以被任何人访问。但其他module中不可以被override和继承,而在module内可以被override和继承。
 5.open : 可以被任何人使用,包括override和继承。
 
 原文出自：www.hangge.com  转载请保留原文链接：http://www.hangge.com/blog/cache/detail_524.html
 */
public class AccessControl {
    //本模块使用
    internal var internalProperty = 123 //internal可省
    //所有人访问
    public var publicProperty = 123
    //只能在这个类内部访问
    private var privateProperty = 123
    fileprivate var filePrivateProperty = 123
    //可以将一个属性的setter声明为私有的,从而使这个属性是只读,除了源文件内部,其他文件不能读取值
    private(set) var privateSetterProperty = 123
}
var testAccessControl = AccessControl()
//testAccessControl.privateProperty
testAccessControl.filePrivateProperty
testAccessControl.privateSetterProperty //别的文件比如Swift_0807.swift里的话实例化了也不能读取值

//运算符 主要是可以定义新运算符,以及为新类型重载已有运算符,跟c++重载运算符差不多
class Vector2D {
    var x : Float = 0.0
    var y : Float = 0.0
    init (x: Float, y: Float){
        self.x = x
        self.y = y
    }
}
func +(left: Vector2D, right: Vector2D) -> Vector2D {
    return Vector2D(x: left.x + right.x, y: left.y + right.y)
}
let first = Vector2D(x: 2, y: 2)
let second = Vector2D(x: 4, y: 1)
let result = first + second
result.x
result.y

//泛型 跟Java泛型<T>差不多
class Tree<T> {
    var value : T
    var children : [Tree <T>] = [] //数组
    init(value : T) {
        self.value = value
    }
    func addChild(addValue : T) -> Tree<T> {
        let newChild = Tree<T>(value: addValue)
        children.append(newChild)
        return newChild
    }
}
let integerTree = Tree<Int>(value: 5)
integerTree.addChild(addValue: 10)
integerTree.addChild(addValue: 5)
integerTree.children
let stringTree = Tree<String>(value: "Hello")
stringTree.addChild(addValue: "Yes")
stringTree.addChild(addValue: "Internets")
stringTree.children
print(stringTree.children[0].value)

//Swift的内存管理
/*
 Swift用于跟踪哪些对象还在使用、哪些不再使用的技术称为引用计数(reference counting),有叫做引用计数(retain count)的计数器在引用对象的时候会+1,当不再将对象指定给该变量后,retain count会-1.降到0的时候该不被引用的对象就从内存中删除
 Swift在编译阶段就会添加retain count
 循环引用(retain cycle):两个对象相互引用,但是其他的用不到他们两个,所以这两个占内存.
    解决方法：
        如果属性是可选类型,只能用weak修饰符避免循环引用,引用对象但不改变这个对象的引用计数,。所引用对象被回收后改属性会被自动置为nil
        如果属性不是可选类型,只能用无主引用（unowned）。所引用对象被回收后属性不会被置为nil,此时访问会导致运行时错误。类似OC中的unsafe_unretained修饰符
 */
class Class1 {
    init() {
        print("Class 1 being created")
    }
    deinit {
        print("Class 1 going away")
    }
}
class Class2 {
    weak var weakRef : Class1?
    unowned var unownedRef : Class1 = Class1()
    init() {}
}

//字符串 由character组成的序列 比较的话用==,不像java里是equal 另外Swift里也是有===的
var hello = "hello"
hello.characters.count
for item in "Hello".characters {
    print(item)
}
if hello.hasPrefix("he") { print("Begins with he")}
if hello.hasSuffix("ol") { print("Ends with ol")}

//数据 Swift中将一些数据块表示为NSData对象,貌似oc里好像也是  下面这一句是Swift3格式
let data  = hello.data(using: String.Encoding.utf8)
//从URL中加载
//if let fileURL = Bundle.main.url(forResource: "test", withExtension: "txt") {
//    var loadedDataFromURL : NSData? = NSData(contentsOf: fileURL)
//    print(loadedDataFromURL!)
//}
let mainBundle = Bundle.main
print(mainBundle)
let fileURL = mainBundle.url(forResource: "Info", withExtension: "plist") //test.txt里的内容是 0！
print(fileURL!)
var loadedDataFromURL : NSData? = NSData(contentsOf: fileURL!)
print(loadedDataFromURL!) //转换成十六进制就是30 21 ,因为是字符0不是数字0,所以0的十六进制是30

//从文件中加载
let filePath = mainBundle.path(forResource: "Info", ofType: "plist")
print(filePath!)
let loadedDataFromPath = NSData(contentsOfFile: filePath!)

//序列化与反序列化 将对象转换为数据必须让对象遵守NSObject和NSCoding协议,然后添加两个方法：encode(with a Coder: NSCoder)和一个以NSCoder为参数的初始化函数
class SerializableObject : NSObject, NSCoding {
    var name : String?
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name!, forKey: "name")
    }
    override init() {
        self.name = "My Object"
    }
    required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String
    }
}
let anObject = SerializableObject()
anObject.name = "My Thing That I'm Saving"
//Transfer to data
let objectConvertedToData = NSKeyedArchiver.archivedData(withRootObject: anObject)
print(objectConvertedToData)
//Transfer to object
//因为转换有可能失败,所以上面的self.name = aDecoder.decodeObject后要用 as? 以及下面的as? 来判断是否是nil
let loadedObject = NSKeyedUnarchiver.unarchiveObject(with: objectConvertedToData) as? SerializableObject
loadedObject?.name

//Cocoa中的设计模式
/*
 1.MVC 
    NSData、数组和字典都是M； NSKeyedArchiver就是一个C类,取得信息进行逻辑运算； NSButton和UITextField都是V类,MVC太常用
 2.委托模式
    允许将一个对象的部分功能转交给另一个对象，比如重写两个类的行为，就需要两个单独的子类。用委托的话，只要一个单独出一个用作委托的对象就可以
 其他不写了,还没看
 */

//委托模式／代理模式
protocol HouseSecurityDelegate {  //定义一个协议用来重写
    func handlerIntruder()
}
class GuardDog : HouseSecurityDelegate {
    func handlerIntruder() {
        print("Releasing the hounds")
    }
}
class House { //创建一个用于委托执行GuardDog的handlerIntruder函数的委托对象
    var delegate : HouseSecurityDelegate?
    func burglarDetected() {
        delegate?.handlerIntruder()
    }
}
let myHouse = House()
myHouse.burglarDetected() //这时候是什么都没有的,因为还没有被委托

let theHounds = GuardDog()
myHouse.delegate = theHounds //theHounds检查了myHouse里是否实现了与要委托的事件handlerIntruder相适应的方法，然后将该方法委托给myHouse
myHouse.burglarDetected() //Releasing the hounds
