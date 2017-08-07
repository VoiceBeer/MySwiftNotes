//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


/// 变量常量,类型,控制流,函数与闭包  Mon, 7 Aug 2017

//常量let必须有值,变量var可以不包含但是用的话必须有值
var someVariable : Int = 0
someVariable += 2

// 只有 <类型>? 的变量(可选变量)才可以允许为nil,swift2以后println变为print,原本的print变为print(值, terminator:"")
var anOptionInteger : Int? = nil
anOptionInteger = 42
let test = 1
if anOptionInteger != nil {
//    print("It has a value. \(test) ")
    print("It has a value. \(anOptionInteger!) ")
    print("test", terminator:"")
    print("test")
} else {
    print("It has no value.")
    
}

// 拆包用！
anOptionInteger = 2
1 + anOptionInteger!

// 声明为已拆包的就可以不用每次！ 虽然容易忘记这是可选变量,有时为nil
var unwarppedOptionalInteger : Int! = 1
1 + unwarppedOptionalInteger

// 显式转换 不能通过直接赋值,只能显式转换
let anInteger = 2
let aString = String(anInteger)
//let aTString:String = anInteger
let aTString : String = String(anInteger)

//元组 有点像json
let aTuple = (1 , "yes")
let theTemp = aTuple.1
let anotherTuple = (aNumber : 1, aString : "YES")
let theAnotherTemp = anotherTuple.aString

//数组 创建空数组的话必须指定类型
let arrayOfIntegers : [Int] = [1,2,3]
let implcitArrayOfIntegers = [1,2,3]
let emptyArray = [Int]()
var variableArray = [Int]()
variableArray.append(5)
variableArray.insert(2, at: 0)
variableArray.insert(10, at: 2)
variableArray.remove(at: 2)
variableArray.reverse() //快速颠倒一个数组
variableArray.count

//字典 键值对 json 由于机器判断出是String:String所以按照字母顺序 ["Age": "18", "Sex": "Male", "Caption": "Chris"]
var crew = [
    "Caption" : "Chris",
    "Age" : "18"
]
crew.count
crew.first
crew["Age"]
crew["Sex"] = "Male"
crew

var aNumberDictionary = [1 : 2]
aNumberDictionary[21] = 23
aNumberDictionary

var testDictionary : [AnyHashable : Any] = [
    1 : "test1",
    "test2" : 2
] //如果不事先声明AnyHashable : Any 的话会报键值对错,一个Int:String 一个String:Int

///控制流,if主体必须放在两个大括号间,不同于Java  ..<不包含最后一个值 ...包含最后一个值
let loopingArray = [1,2,3,4,5]
var loopSum = 0
for number in loopingArray { //number 隐式创建
    loopSum += number
}
loopSum

var firstCounter = 0
for index in 1 ..< 10 {
//    firstCounter++  // ++ 在swift3中移除,只能用 += 1 了
    firstCounter += 1
}
firstCounter
for index in 1 ... 10 {
    //    firstCounter++  // ++ 在swift3中移除,只能用 += 1 了
    firstCounter += 1
}
firstCounter

//这个写法别的语言很常见,貌似swift3删掉了,还是用item in list或者 ..< ... 之类的吧
//var sum = 0
//for var i = 0; i < 3; i++ {
//    sum += 1
//}
//sum

//do-while都不能用了,貌似变成repeat-while
//var countUp = 0
//do {
//    count++
//}while countUp < 5
var countUp = 0
repeat {
    countUp += 1
}while countUp < 5

var countUp2 = 0
while countUp2 < 5 {
    countUp2 += 1
}

//这个if-let挺精简的
var conditionalString : String? = "A string"
if let theString = conditionalString {
    print("The string is \(theString)")
}else {
    print("The string is nil")
}

//switch 可以根据元组切换,而且不会某一部分执行完后自动进入下一部分,也就是说不需要每一个case都加break.另外Swift中要么添加所有case,要么加一个default case
let tupleSwitch = ("Yes", 123)
switch tupleSwitch {
case ("Yes", 12):
    print("Yes and 12")
case ("Yes", _):
    print("Yes and something else")
default:
    break
}
//还可以根据范围
let somenumber = 15
switch somenumber {
case 0 ... 10:
    print("0 to 10")
case 11 ... 20 :
    print("11 to 20")
default:
    print("something else")
}

///函数与闭包 与java不同的是返回参数写在后面用 -> 来指明,也可以通过元组形式返回多个值
func forthFunction(firstValue : Int, secondValue : Int) -> (doubled : Int, quadrupled : Int) {
    return (firstValue * 2, secondValue * 4)
}
func testFunction(_ t1 : Int, _ t2 : Int) -> (doubled : Int, quadrupled : Int) {
    return (t1 * 2, t2 * 4)
}
forthFunction(firstValue: 2, secondValue: 4).doubled
forthFunction(firstValue: 2, secondValue: 4).1 //现在调用函数貌似必须加上参数名字,貌似以前可以不加,另外参数名字顺序也要一样.说是为了方便兼容oc?不过规范点也好
testFunction(2, 4)  //这里之所以可以不加参数名字是因为用了 _ 当作外部参数名， 内部参数名是t1和t2，函数内部用t1和t2就可以，但是外部是_也就是都可以的话，就不需要加上参数名了
//forthFunction(2, 4)
//forthFunction(secondValue:4 ,firstValue: 2)

func multiplyNumbers2 (firstNumber: Int, multiplier: Int = 2) -> Int {
    return firstNumber * multiplier;
}
multiplyNumbers2(firstNumber: 2, multiplier: 4)
multiplyNumbers2(firstNumber: 2)

//参数个数可变的函数 类似于public int sumNumbers(List<int> list){}原理 使用可变参数时，可以有任意多个非可变参数，但是只有列表中的最后一个参数可以是可变参数
func sumNumbers(numbers: Int...) -> Int {
    var total = 0
    for item in numbers {
        total += item
    }
    return total
}
sumNumbers(numbers: 2,3,4,5)

//inout,这个关键字用法跟c++里指针有关
/*
 两种传递参数方式
 1.值类型
    传递的是参数的一个副本，这样在调用参数的过程中不会影响原始数据。(除class外)
 2.引用类型
    把参数本身引用(内存地址)传递过去，在调用的过程会影响原始数据。(例如class)
 
 注意事项
 1.inout修饰的参数是不能有默认值的(例子中length = 10被赋予默认值)，有范围的参数集合也不能被修饰；
 2.一个参数一旦被inout修饰，就不能再被var和let修饰了。
*/
var value = 50
func testInout (first: inout Int, length: Int = 10){
    first += length
}
testInout(first: &value)
value //value就变成了60了,因为相当于是改变了指针指向的内存地址

//将函数用作变量 只要一个函数的参数与返回值类型都与声明中的函数相同，就可以将它存储在这个变量中
func addNumbers (firstNumber num1 : Int, toSecondNumber num2 : Int) -> Int {
    return num1 + num2
}

//var numbersFunc: (Int, Int) -> Int; //可以存储任何接受两个Int并返回一个Int的函数
var numbersFunc = addNumbers
numbersFunc(2, 3)

//函数还可以接受其他函数作为参数，意味着函数可以合并
func timesThree (number: Int) -> Int {
    return number * 3
}
func doSomethingToNumber (aNumber: Int, thingToDo: (Int)->Int) -> Int {
    //接受一个函数,内部名字叫thingToDo
    return thingToDo(aNumber)
}
doSomethingToNumber(aNumber: 4, thingToDo: timesThree)

//函数还可以返回其他函数,用函数创建函数
//第一个int就是外部传入的int,第一个箭头之后的int是内部adder的函数的参数的int,第二个箭头之后的int是createAdder返回的参数的int
//整一个结构可以看成是这样：一个接受Int叫做numberToAdd的参数的createAdder函数,这个函数会返回一个有一个Int型的传入参数,返回的也是Int的一个函数,相当于
// createAdder(numberToAdd: Int) -> ((Int) -> Int){} 加个括号就清楚很多了
// createAdder(numberToAdd: Int) -> A {};  A(Int) -> Int {}
func createAdder(numberToAdd: Int) -> (Int) -> Int {
    func adder(number: Int) -> Int {
        print(number)
        return number + numberToAdd
    }
    return adder
}
func createTest() -> (Int) -> Int {
    func adder(number: Int) -> Int {
        return number + 4
    }
    return adder
}

var addTwo = createAdder(numberToAdd: 4)
addTwo(2)   //上述例子是创建了一个createAdder(numberToAdd: 4)的新函数,这个函数等同于上面写的createTest()跟单独拿出来的有+4的adder其实效果一样的，将之存储在变量addTwo中，调用的话就是addTwo(2)，看下面这一句等同效果的可以方便理解
createAdder(numberToAdd: 4)(2)

//一个函数还可以“捕获”一个值，并多次使用它
func createIncrementor(incrementAmount: Int) -> (() -> Int) {
    var amount = 0
    func incrementor() -> Int {
        print("Before the add amount is :\(amount)")
        amount += incrementAmount
        return amount
    }
    return incrementor
}
var incrementByTen = createIncrementor(incrementAmount: 10)
print("First time:\(incrementByTen())")
print("Second time:\(incrementByTen())") //其他的都跟上一个差不多，这里之所以是20不是10是因为上一句调用过后，amount这个新函数createIncrementor(incrementAmount: 10)内部的amount已经有值了也就是10，看print，在加之前amount已经是10了，下面是一个新函数15所以amount还是0

var incrementByFifteen = createIncrementor(incrementAmount: 15)
incrementByFifteen()
/*捕获总结：
    1.嵌套函数可以捕获其外部函数所有的参数以及定义的常量和变量
    2.incrementor()函数并没有任何参数，但是在函数体内访问了amount变量。这是因为这个函数从外围函数捕获了amount变量的引用(参考前面的引用类型)。所以调用一次就指针修改一次，所以值也变了.捕获引用保证了amount变量在调用完createIncrementor后不会消失，并且保证了下一次执行incrementor函数时，amount依旧存在。
    3.因为归根结底还是c的高阶来的，所以这些指针类似物还是要注意
 */

//闭包 小的匿名代码块，可以像函数一样使用，基本格式：
/*
 {
    (形参) -> (返回值类型) in
        //执行代码
 }
 如果闭包没有参数,没有返回值.in和in之前的内容可以省略
 {
    //执行代码
 }
 尾随闭包写法:
 如果闭包是函数的最后一个参数,则可以将闭包写在()后面，如果函数只有一个参数,并且这个参数是闭包,那么()可以不写
 httpTool.loadRequest() {
 print("回到主线程", NSThread.currentThread());
 }
 // 开发中建议该写法
 httpTool.loadRequest {
 print("回到主线程", NSThread.currentThread());
 }
 */
var comparator = {(a: Int, b: Int) -> (Bool) in a < b}
comparator(1, 2)

var numbers = [2, 1, 56, 32, 120, 13]
var numberSorted = numbers.sorted(by: {
    $1 > $0
})






