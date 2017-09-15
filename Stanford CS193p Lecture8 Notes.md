```~~
/* Sat. 15 Sept 2017
    @Vb
*/
```
[TOC]

---
# Lecture 8

## Multithreading
> 两种概念
> 1. 算法等计算例如1000个东西的话通过多个线程来计算最后合并结果
> 2. 例如主屏线程, 后台读取数据线程等等

### Queues
> Multithreading is mostly about "queues" in iOS
>
> Functions (usually closures) are simply lined up in a queue (like at the movies)
>
> Then those functions are pulled off the queue and executed on an associated thread(s)
>
> Queues can be "serial" (one closure a time) or "concurrent" (multiple threads servicing it)

### Main Queue
> There is a very special serial queue called the "main queue"
>
> All UI activity MUST occur on this queue and this queue only
>
> And, conversely(相反的), non-UI activity that is at all time consuming must NOT occur on that queue.
>
> We do this because we want our UI to be highly responsive, and also because we want things that happen in the UI to happen predictably (serially 连续的)
>
> Functions are pulled off and worked on in the main queue only when it is "quiet"

### Global Queues
> For non-main-queue work, you're usually going to use a shared, global, concurrent queue

### Getting a queue
> Getting the main queue (where all UI activity must occur)
>
> ```let mainQueue = DispatchQueue.main```

> Getting a global, shared, concurrent(同时进行的) "background" queue
>
> This is almost always what you will use to get activity off the main queue

```Swift
let backgroundQueue = DispatchQueue.global(qos: DispatchQoS) // qos means Quality of Service
DispatchQoS.userInteractive // high priority, only do something short and quick
DispatchQoS.userInitiated // high priority, but might take a little bit of time
DispatchQoS.background // not directly initiated by user, so can run as slow as needed
DispatchQoS.utility // long-running background processes, low priority
```

### Putting a block of code on the queue
> Multithreading is simply the process of putting closures into these queues
>
> There are two primary ways of putting a closure onto a queue
>
> You can just plop a closure onto a queue and keep running on the current queue ...

```Swift
queue.async { ... }
```
> ... or you can block the current queue waiting until the closure finishes on that other queue ...

```Swift
queue.sync { ... }
```
> Almost always do the former

### Getting a non-global queue
> Very rarely you might need a queue other than main or global

> Your own serial queue (use this only if you have multiple, serially dependent activities)

```Swift
let serialQueue = DispatchQueue(label: "MySerialQ")
```
> Your own concurrent queue (rare that you would do this versus global queues)

```Swift
let concurrentQueue = DispatchQueue(label: "MyConcurrentQ", attributes: .concurrent)
```
### There is also another API to all of this
```Swift
OperatinQueue
Operation  // classes
```
> Usually we use the DispatchQueue API. This is because the "nesting" of dispatching reads very well in the code
>
> But the Operation API is also quite useful (especially for more complicated multithreading)

### Multithreaded iOS API
> Quite a few places in iOS will do what they do off the main queue
>
> They might even afford you the opportunity to do somthing off the main queue
>
> iOS might ask you for a function (a closure, usually) that executes off the main thread
>
> Don't forget that if you want to do UI stuff there, you must dispatch back to the main queue

### Example of a multithreaded iOS API
> This API lets you fetch the contents of an HTTP URL into a Data off the main queue

```Swift
let session = URLSession(configuration: .default) // can change the configuration, e.g. only fetch URL when it's on Wi-Fi
if let url = URL(string: "http://stanford.edu/...") {
    let task = session.dataTask(with: url) { (data: Data?, response, error) in
        // if want to do some UI stuff here, use DispatchQueue
        DispatchQueue.main.async {
            // do UI stuff here
            // That's because the UI code you want to do has been dispatched back to the main queue
        }
        
    }
    task.resume() // go to fetch
}
```

### Timing
> look at when each of these lines of code executes

```Swift
a: if let url = URL(string: "https://stanford.edu/...") {
b:      let task = session.dataTask(with: url) { (data: Data?, response, error) in
c:          // do somthing with the data
d:          DispatchQueue.main.async {
e:              // do UI stuff here
            }
f:          print("did some stuff with the data, but UI part hasn't happended yet")
        }
g:      task.resume()
   }
h: print("done firing off the request for the url's contents")
```

1. > Line a is obviously first
2. > Line b is next
    > 
    > It returns immediately. It does nothing but create a dataTask and assign it to task.
    >
    > Obviously its closure argument has yet to execute (it needs the data to be retrieved恢复 first)
3. > Line g happens immediately after line b. It also returns immediately
    >
    > All it does it fire off the url fetch (to get the data) on some other (unknown) queue
    >
    > The code on lines c, d, e and f will eventually execute on some other (unknown) queue
4. > Line h happens immediately after line g.
    > 
    > The url fetching task has now begun on some other queue (executing on some other thread)
5. > The first four lines of code (a, b, g, h) all ran back-to-back with no delay
    >
    > But line c will not get executed until sometime later (because it was waiting for the data)
    >
    > It could be moments after line g or it could be minutes (e.g., if over cellular)
6. > Then line d gets executed
    >
    > Since it is dispatching its closure to the main queue async, line d will return immediately
7. > Line f gets executed immediately after line d.
    >
    > Line e has not happened yet!
    >
    > Again, line d did nothing but asynchronously dispatch line e onto the (main) queue
8. > Finally, sometime later, line e gets executed
    >
    > Just like with line c, it's probably best to imagine this happens minutes after line g
    >
    > What's going on in our program might have changed dramatically in that time

> Summary: a b g h c d f e
>
> This is the "most likely" order
>
> It's not impossible that line e could happen before line f, for example.(when dispatch things to the main queue from the main queue, e could before f)

## UITextField
### Like UILabel, but editable
> Typing things in on an iPhone is secondary UI (keyboard is tiny)
>
> More of a mainstream UI element on iPad
>
> You can set attributed text, text color, alignment, font, etc., just like a UILabel

### Keyboard appears when UITextField becomes "first responder"
> It will do this automatically when the user taps on it
>
> Or you can make it the first responder by sending it the ```becomeFirstResponder``` message
>
> To make the keyboard go away, send ```resignFirstResponder``` to the UITextField

### Delegate can get involved with Return key, etc.
> ```func textFieldShouldReturn(sender: UITextField) -> Bool // when "Return" is pressed```
>
> Oftentime, you will ```sender.resignFirstResponder()``` in this method
>
> Returns whether to do normal processing when Return key is pressed (e.g. target/action)

### Finding out when editing has ended
> Another delegate method
>
> ```func textFieldDidEngEditing(sender: UITextField)```
>
> Sent when the text field resigns being first responder

## Keyboard
### Controlling the appearance of the keyboard
> Remember, whether keyboard is showing is a function of whether its first responder
>
> You can also control what kind of keyboard comes up.
>
> Set the properties defined in the ```UITextInputTraits``` protocol (```UITextField``` implements).

```Swift
var autocapitalizationType: UITextAutocapitalizationType // words, sentences, etc
var autocorrectionType: UITextAutocorrectionType // .yes or .no
var returnKeyType: UIReturnKeyType // Go, Search, Google, Done, etc
var isSecureTextEntry: Bool // for passwords, for example
var keyboardType: UIKeyboardType // ASCII, URL, PhonePad, etc
```

### Other Keyboard functionality
> Keyboards can have accessory views that appear above the keyboard (custom toolbar, etc.).
>
> ```var inputAccessoryView: UIView // UITextField method```

### Other UITextField properties
```Swift
var clearsOnBeginEditing: Bool
var adjustsFontSizeToFitWidth: Bool
var minimumFontSize: CGFloat // always set this if you set adjustsFontSizeToFitWidth
var placeholder: String? // drawn in gray when text field is empty
var background/disabledBackground: UIImage?
var defaultTextAttributes: [String:Any] // applies to entire text
```