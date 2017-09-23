```
/* Sat. 23 Sept 2017
    @Vb
*/
```
[TOC]

---
# Lecture 10

## Core Data
> Object-oriented database

### How does it work?
> Create a visual mapping (using Xcode tool) between database and objects
>
> Create and query for objects using object-oriented API
>
> Access the "columns in the database table" using vars on those objects

### How to access in the code?
> Need an ```NSManagedObjectContext```

### How to get a context?
> get one out of an ```NSPersistentContainer```(in ```AppDelegate.swift```)
>
> You can access that AppDelegate var like this...

```Swift
(UIApplication.shared.delegate as! AppDelegate).persistentContainer
```
### Getting the NSManagedObjectContext
> We get the context we need from the persistentContainer using its ```viewContext``` var.
>
> This returns an ```NSManagedObjectContext``` suitable (only) for use on the main queue

```Swift
let container = (UIApplication.shared.delegate as! AppDelegate)
```

### Convenience
> ```(UIApplication.shared.delegate as! AppDelegate).persistentCOntainer``` is kind of messy
>
> Sometimes add a static version to AppDelegate...

```Swift
static var persistentContainer: NSPersistentContainer {
    return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
}
```
>
> so you can access the container like this ...

```Swift
let coreDataContainer = AppDelegate.persistentContainer
```
>
> And possibly even add this static var too ... 

```Swift
static var viewContext: NSManagedObjectContext {
    return persistentContainer.viewContext
}
```
> So that we can do this ...

```Swift
let context = AppDelegate.viewContext
```

### Inserting objects into the databse
```Swift
let context = AppDelegate.viewContext
let tweet: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: "Tweet", into: context)
```
> Note that this ```NSEntityDescription``` class method returns an ```NSManagedObject``` instance
>
> All objects in the database are represented by ```NSManagedObjects``` or subclasses thereof
>
> An instance of ```NSManagedObject``` is a manifestation(表示) of an Entity(实体) in our Core Data Model(i.e., the Data Model that we just graphically built in Xcode).
>
> Attributes of a newly-inserted object will start out ```nil``` (unless you specify a default in Xcode)

### How to access Attributes in an ```NSManagedObject``` instance
> You can access them using the following two ```NSKeyValueCoding``` protocol methods ...

```Swift
func value(forKey: String) -> Any?
func setValue(Any?, forKey: String)
```
> Using ```value(forKeyPath:)/setValue(_,forKeyPath:)```(with dots) will follow your Relationships

```Swift
let username = tweet.value(forKeyPath: "tweeter.name") as? String
```

### The ```key``` is an Attribute name in your data mapping

### The ```value``` is whatever is stored (or to be stored) in the database
> It'll be ```nil``` if nothing has been stored yet (unless Attribute has a default in Xcode)
>
> Numbers are ```Double```, ```Int```, etc. (if Use Scalar Type checked in Data Model Editor in Xcode).
>
> Binary data values are ```NSData```s
>
> Date values are ```NSDate```s
>
> "To-many" relationships are ```NSSet```s but can be cast (with as?) to ```Set<NSManagedObject>```
>
> "To-one" relationships are ```NSManagedObject```s

### Changes (writes) only happen in memory, until you save
> You must explicitly(
明确地) save any changes to a context, but note that this throws

```Swift
do {
    try context.save()
} catch {   // note, by default catch catches any error into a local variable called error
    // deal with error
}
```
> Don't forget to save your changes any time you touch the database
>
> Group up as many changes into a single save as possible

### Always set/get using vars by creating a suclass of NSManagedObject
> The subclass will have vars for each attribute in the database
>
> Name our subclass the same name as the Entity it matches (not strictly required, but do it)
>
> Xcode will generate all the code necessary to make this work

### How do I access my Entities with these subclasses?
```Swift
// let's create an instance of the Tweet Entity in the database ...
let context = AppDelegate.viewContext
if let tweet = Tweet(context: context) {
    tweet.text = "140 characters of pure joy"
    tweet.created = Date()
    let joe = TwitterUser(context: tweet.managedObjectContext)
    tweet.tweeter = joe
    tweet.tweeter.name = "Joe Schmo"
}
```
> Note that we don't have to use that ugly ```NSEntityDescription``` method to create an Entity