//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


/// 类型，nil，拆包(unwrap),显式转换  Mon, 7 Aug 2017

/// 只有 <类型>? 的变量(可选变量)才可以允许为nil，swift2以后println变为print，原本的print变为print(值, terminator:"")
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

/// 拆包用！
anOptionInteger = 2
1 + anOptionInteger!

/// 声明为已拆包的就可以不用每次！ 虽然容易忘记这是可选变量，有时为nil
var unwarppedOptionalInteger : Int!
unwarppedOptionalInteger = 1
1 + unwarppedOptionalInteger

/// 显式转换 不能通过直接赋值，只能显式转换
let anInteger = 2
let aString = String(anInteger)
//let aTString:String = anInteger
let aTString : String = String(anInteger)

///元组 有点像json
let aTuple = (1 , "yes")






