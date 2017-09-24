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
### Getting the ```NSManagedObjectContext```
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
    tweet.tweeter = joe // is the same as joe.addToTweets(tweet)
    tweet.tweeter.name = "Joe Schmo"
}
```
> Note that we don't have to use that ugly ```NSEntityDescription``` method to create an Entity
>
> This is nicer than ```setValue(Date(), forKey: "created")```
>
> And Swift can type-checked to be sure you're actually passing a Date here (versus the value being Any? and thus un-typed-checkable)

> Setting the value of Relationship is no different than setting any other Attribute value
>
> And this will automatically add this tweet to joe's tweets Relationship too!

```Swift
if let joesTweets = joe.tweets as? Set<Tweet> {    // joe.tweets is an NSSet, thus as
    if let joesTweets.contains(tweet) { print("yes!")   // yes!
}
```
> Xcode also generates some convenience functions for "to-many" relationships
> 
> For example, for ```TwitterUser```, it creates an ```addToTweets(Tweet)``` function
>
> You can use this to add a Tweet to a ```TwitterUser```'s tweets Relationship

> ```context: tweet.mannagedObjectContext```
>
> Every NSManagedObject knows the managedObjectContext it is in
>
> So we could use that fact to create this ```TwitterUser``` in the same context as the tweet is in
>
> Of course, we could also just used context here

> ```tweet.tweeter.name = "Joe Schmo"```
>
> Relationships can be traversed using "dot notation"
>
> ```tweet.twitter``` is a ```TwitterUser```, so ```tweet.tweeter.name``` is the ```TwitterUser```'s name
>
> This is much nicer that ```value(forKeyPath:)``` because it is type-checked at every level

## Scalar Types
### Scalars
> By default Attributes some through as objects (e.g. ```NSNumber```)
>
> If you want as normal Swift types (e.g. Int32), inspect them in the Data Model and say no

## Deletion
### Deletion
> Deleting objects from the database is easy (sometimes too easy!)

```Swift
managedObjectContext.delete(_ object: tweet)
```
> Relationships will be updated for you (if you set Delete Rule for Relationships properly)
>
> Don't keep any strong pointers to tweet after you delete it

### prepareForDeletion
> This is a method we can implement in our NSManagedObject sbuclass ...

```Swift
func prepareForDeletion()
{
    // if this method were in the Tweet class
    // we wouldn't have to remove ourselves from tweeter.tweets (that happens automatically)
    // but if TwitterUser had, for example, a "number of retweets" attribute,
    // and if this Tweet were a retweet
    // then we might adjust it down by one here (e.g. tweeter.retweetCount -= 1)
}
```
## Querying
### So far you can ...
> Create objects in the database: ```NSEntityDescription``` or ```Tweet(context: ...)```
>
> Get/set properties with ```value(forKey:)/setValue(_, forKey:)``` or vars in a custom subclass
>
> Delete objects using the ```NSManagedObjectContext delete()``` method

### How to QUERY
> Basically you need to be able to retrieve objects from the database, not just create new ones.
>
> You do this by executing an ```NSFetchRequest``` in your ```NSManagedObjectContext```

### Three important things involed in creating an ```NSFetchRequest```
> 1. Entity to fetch (required, and can only fetch one kind of entity)
> 2. ```NSSortDescriptor```s to specify the order in which the Array of fetched objects are returned
> 3. ```NSPredicate``` specifying which of those Entities to fetch (optional, default is all of them)

### Creating an ```NSFetchRequest```
> We'll consider each of these lines of code one by one ...

```Swift
let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
request.sortDescriptors = [sortDescriptor1, sortDescriptor2, ...]
request.predicate = ...
```

### Specifying the kind of Entity we want to fetch
```Swift
let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
```
> (note this is a rare circumstance where Swift cannot infer the type)

> A given fetch returns object all of the same kind of Entity
>
> You can't have a fetch that returns some Tweets and some TwitterUsers (it's one or the other)
>
> ```NSFetchRequest``` is a generic type so that the ```Array<Tweet>``` that is fetched can also be typed

### NSSortDescriptor
> When we execute a fetch request, it's going to return an Array of ```NSManagedObjects```
>
> Arrays are "ordered", of course, so we should specify that order when we fetch
>
> We do that by giving the fetch request a list of "sort descriptors" that describe what to sort by.

```Swift
let sortDescriptor = NSSortDescriptor(
    key: "screenName", ascending: true,
    selector: #selector(NSString.localizedStandardCompare(_:)) // can skip this, this is the method that gonna use to compare items to do the sort
)
```
> We give an Array of these ```NSSortDescriptors``` to the NSFetchRequest because sometimes we want to sort first by one key, then within that sort, by another.
>
> Example: ```[lastNameSortDescriptor, firstNameSortDescriptor]```

### NSPredicate
> This is the guts of how we specify exactly which objects we want from the database
>
> Note that we use ```%@``` (more like printf) rather than ```\(expression)``` to specify variable data

```Swift
let searchString = "foo"
let predicate = NSPredicate(format: "text contains[c] %@", searchString)
let joe: TwitterUser = ... // a TwitterUser we inserted or queried from the database
let predicate = NSPredicate(format: "tweeter = %@ && created > %@", joe, aDate)
let predicate = NSPredicate(format: "tweeter.screenName = %@", "CS193p")
```
> Then above would all be predicate for searches in the Tweet table only.

> Here's a predicate for an intersting search for TwitterUsers instead ...

```Swift
let predicate = NSPredicate(format: "tweets.text contains %@", searchString)
```
> This would be used to find TwitterUsers (not Tweets) who have tweets that contain the string

### ```NSCompoundPredicate```
> You can use AND and OR inside a predicate string, e.g. "(name = %@) OR (title = %@)"
>
> Or you can combine NSPredicate objects with special ```NSCompoundPredicate```

```Swift
let predicates = [predicate1, predicate2]
let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
```
> This ```andPredicate``` is "predicate1 AND predicate2". OR available too, of course

### Function Predicates
> Can actually do predicates like "tweets.@count > 5" (TwitterUsers with more than 5 tweets).
>
> @count is a function (there are others) executed in the database itself

### Putting it all together
> Let's say wewant to query for all TwitterUsers ...

```Swift
let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
```
> ... who have created a tweet in the last 24 hours

```Swift
let yesterday = Date(timeIntervalSinceNow: -24*60*60)
request.predicate = NSPredicate(format: "any tweets.created > &@", yesterday)
```
> ... sorted by the TwitterUser's name ...

```Swift
request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
```
### Executing the fetch
```Swift
let context = AppDelegate.viewContext
let recentTweeters = try? context.fetch(request)
```
> The ```try?``` means "try this and if it throws an error, just give me nil back."
>
> We could, of course, use a normal try inside a do { } and  catch errors if we were interested
>
> Otherwise this fetch method ...
>
> Returns an empty Array (not nil) if it succeeds and there are no matches in the database.
>
> Returns an Array of ```NSManagedObject```s (or subclasses thereof) if there were any matches

### Query Results Faulting
> The above fetch does not necessarily fetch any actual data
>
> It could be an Array of "as yet unfaulted" objects, waiting for you to access their attributes.
>
> Core Data is very smart about "faulting" the data in as it is actually accessed.
>
> For example, if you did something like this ...

```Swift
for user in recentTweeters {
    print("fetched user \(user)")
}
```
> You may or may not see the names of the users in the output.
> 
> You might just see "unfaulted object", depending on whether it has already fetched them.
>
> But if you did this ...

```Swift
for user in recentTweeters {
    print("fetched user named \(user.name)")
}
```
> ... then you would definitely fault all these TwitterUsers in from the database.
>
> That's because in the second case, you actually access the NSManagedObject's data

## Core Data Thread Safety
### ```NSManagedObjectContext``` is not thread safe
> Luckily, Core Data access is usually very fast, so multithreading is only rarely needed.
>
> ```NSManagedObjectContext``` are created using a queue-based concurrency mdoel
>
> This means that you can only touch a context and its NSMO's in the queue it was created on.
>
> Often we use only the main queue and its ```AppDelegate.viewContext```, so it's not an issue

### Thread-Safe Access to an ```NSManagedObjectContext```
```Swift
context.performBlock {    // or performBlockAndWait until it finishes
    // do stuff with context (this will happen in its safe Q (the Q it was created on)
}
```
> Note that the Q might well be the main Q, so you're not necessarily getting "multithreaded."
>
> It's generally a good idea to wrap all your Core Data code using this
>
> Although if you have no multithreaded code at all in your app, you can probabaly skip it
>
> It won't cost anything if it's not in a multithreaded situation

### Convenient way to do database stuff in the background
> The persistentContainer has a simple method for doing database stuff in the background

```Swift
AppDelegate.persistentContainer.performBackgroundTask { context in
    // do some CoreData stuff using the passed-in context
    // this closure is not the main queue, so don't do UI stuff here (dispatch back if needed)
    // and don't use AppDelegate.viewContext here, use the passed context
    // you don't have to use NSManagedObjectContext's perform method here either
    // since you're implicitly doing this block on that passed context's thread
    try? context.save() // don't forget this (and catch errors if needed)
}
```
> This would generally only be needed if you're doing a big update
>
> You'd want to see that some Core Data update is a performance problem in Instruments first
>
> For small queries and small updates, doing it on the main queue is fine

## Core Data and UITableView
### ```NSFetchedResultsController```
> Hooks an ```NSFetchRequest``` up to a ```UITableViewController```
>
> Usually you'll have an ```NSFetchedResultsController``` var in your ```UITableViewController```
>
> It will be hooked up to an ```NSFetchRequest``` that returns the data you want to show
>
> Then use an NSFRC to answer all of your ```UITableViewDataSource``` protocol's questions

### Implementation of ```UITableViewDataSource``` ...
```Swift
var fetchedResultsController = NSFetchedResultsController...
func numberOfSectionsInTableView(sender: UITableView) -> Int {
    return fetchedResultsController?.sections?.count ?? 1
}
func tableView(sender: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let sections = fetchedResultsController?.sections, sections.count > 0 {
        return sections[section].numberOfObjects
    } else {
        return 0
    }
}
```
## NSFetchedResultsController
### Implementing ```tableView(_, cellForRowAt indexPath:)```
> What about ```cellForRowAt?```
>
> You'll need this important ```NSFetchedResultsController``` method ...

```Swift
func object(at indexPath: NSIndexPath) -> NSManagedObject
```
> Here's how you would use it ... 

```Swift
func tableView(_ tv: UITableView, cellForRowAt indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tv.dequeue...
    if let obj = fetchedResultsController.object(at: indexPath) {
        // load up the cell based on the properties of the obj
        // obj will be an NSManagedObject (or subclass thereof) that fetches into this row
    }
}
```

### How to create an ```NSFetchedResultsController```?
> Just need the ```NSFetchRequest``` to drive it (and a ```NSManagedObjectContext``` to fetch from).
>
> Let's say we want to show all tweets posted by someone with the name theName in our table:

```Swift
let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
request.sortDescriptors = [NSSortDescriptor(key: "created" ... )]
request.predicate = NSPredicate(format: "tweeter.name = %@", theName)
let frc = NSFetchedResultsController<Tweet>(    // note this is a generic type
    fetchRequest: request,
    managedObjectContext: context,
    sectionNameKeyPath: keyThatSaysWhichAttributeIsTheSectionName,
    cacheName: "MyTwitterQueryCache" // careful
)
```
> Be sure that any ```cacheName``` you use is always associated with exactly the same request.
>
> It's okay to specify ```nil``` for the ```cacheName``` (no cacheing of fetch results in that case)
>
> It is critical that the ```sortDescriptor``` matches up with the ```keyThatSaysWhichAttribute``` ...
>
> The results must sort such that all objects in the first section come first, second second, etc.
>
> If ```keyThatSaysWhichAttributeIsTheSectionName``` is ```nil```, your table will be one big section.

### NSFetchedResultsController also "watches" Core Data
> And automatically will notify your UITableView if something changes that might affect it!
>
> When it notices a change, it sends message like this to its delegate ...

```Swift
func controller(NSFetchedResultsController,
    didChange: Any,
    atIndexPath: NSIndexPath?
    forChangeType: NSFetchedResultsChangeType,
    newIndexPath: NSIndexPath?)
{
    // here you are supposed call appropriate UITableView methods to update rows
}
```
## Core Data and UITableView
### Things to remember to do...
> 1. Subclass ```FetchedResultsTableViewController``` to get ```NSFetchedResultsControllerDelegate```
> 2. Add a var called ```fetchedResultsController``` initialized with the ```NSFetchRequest``` you want
> 3. Implement your ```UITableViewDataSource``` methods using this ```fetchedResultsController``` var

### Then
> After you set the value of your ```fetchedResultsController``` ...

```Swift
try? fetchedResultsController?.performFetch() // would be better to catch errors
tableView.reloadData()
```
> Your table view should then be off and running and tracking changes in the database!
>
> To get those changes to appear in your table, set yourself as the NSFRC's delegate:
```fetchedResultsController?.delegate = self```
>
> This will work if you inherit from ```FetchedResultsTableViewController```