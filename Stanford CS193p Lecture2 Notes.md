```~~
/* Tues, 15 Aug 2017
    @Vb
*/
```

[TOC]

---

# Lecture 2

## MVC
> 虽然MVC已经接触过很多,但是这个讲解还是蛮好的

![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/9FB7ADCF93464258AEB5C8AD2D8D59F8/1339)
1. C可以访问M
2. C与V的联系叫做outlet(Xcode中比如将一个UILabel连接到代码选项中的outlet)
```Swift
@IBOutlet weak var display: UILabel!
```
3. M与C不能有交互,双黄线
4. V与C通讯是通过红色的target和黄色的action箭头那样的方式,target-action(目标对象-操作模式).控制器把自己设为目标，创建一个响应对应@IBAction操作的方法
```Swift
@IBAction func touchDigit(_ sender: UIButton) {}
```
5. delegate(委托)像是V里的一个变量,遵守一个protocol.比如UIScrollView的协议里有例如should,will,did等等的func定义,那么假设V里用了一个scroll,这个scroll的didScroll方法是委托给C来执行的,C中就可以相当于重写UIScrollView里面的didScroll方法来得到对应的需要的操作(比如创建一个空白项目默认生成的AppDelegate.swift里就有很多)
```Swift
func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
```
6. C和V另一个联系是dataSource,也是一个C放在V里的遵守协议的变量,可以用于得到例如数据的数目,数据等等.例如一个UITableView显示歌曲列表的话,在V中是不可能存数据的,所以用这个协议来与C层联系获得对应的数目和歌曲等等,而C是通过M得到的
7. M负责把模型里的数据转化为视图能接受的类型
8. M不能去联系C,但是可以通过像是电台发送数据改变的通知,C接收到通知后询问具体信息

---
## MVCs Working Together
![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/89C1E19B01DB46F3B1124D9D49B6EE6F/1404)
1. 一个MVC指向另一个MVC时,被指向的那个会被作为当前MVC的视图(例子:日历中,有显示年的MVC、显示月的MVC和显示日的MVC,在年MVC中,点击对应的月的按钮(这按钮在年MVC中就是V),然后年MVC就隐藏,换上月MVC,这个月MVC就相当于年MVC的V了
2. MVCs中的C可以指向同一个M
3. 不要变成这样
![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/BBBC937B7E184A549C74EDB72121BACD/1421)

---
## struct/class
1. Swift里常用的类都是struct(String,Double,Array,Dictionary)
2. class可以继承,struct不行
3. class储存在堆heap中,通过指针传递.struct不储存在堆中,通过拷贝值传递.class是引用类型,struct是值类型
4. 凡是通过拷贝值传递的都会采用"copy on write(写时拷贝)",当某个人想要修改这个内容的时候,才会真正把内容copy出去形成一个新的内容再改
5. M层可以用struct因为一般也不会被其他别的东西引用
6. struct会自动提供一个初始化器,不像class要自己写
7. 结构体如果定义一个函数可以修改结构体的值的话,在func前面要加mutating,与copy-on-write有关,修改了才会复制