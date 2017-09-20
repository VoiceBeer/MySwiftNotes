```
/* Sat. 20 Sept 2017
    @Vb
*/
```
[TOC]

---
# Lecture 9

## UITableView

![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/CBCBAB63BED24755838011E37D9592DF/3639)

### Plain Style & Grouped Style
![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/FBF7EC17993D4D9280455B09BDAE3F5C/3671)
![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/B931474745AD4430884867EC507BB46B/3676)
```Swift
// Table Header & Table Footer
var tableHeaderView: UIView
var tableFooterView: UIView

// Section Header & Section Footer
UITableViewDataSource's tableView(UITableView, titleForHeaderInSection: Int)
UITableViewDataSource's tableView(UITableView, titleForFooterInSection: Int)

// Table Cell
UITableViewDataSource's tableView(UITableView, cellForRowAt indexPath:)

```
### Cell Type
![image](http://note.youdao.com/yws/public/resource/09541f586de48ab936ffc56a3f25e64e/xmlnote/83CC2CD7A4D542EC93602B00A31CEEF2/3679)

## UITableView Protocols
### Connect all stuff up in code
> Connections to code are made using the UITableView's ```dataSource``` and ```delegate```
> - The ```delegate``` is used to control how the table is displayed (it's look and feel)
> - The ```dataSource``` provides the data that is displayed inside the cells
> 
> ```UITableViewController``` automatically sets itself as the UITableView's delegate & dataSource, your UITableViewController subclass will also have a property pointing to the UITableView ...

```Swift
var tableBView: UITableView // return self.view(UITableView) in UITableViewController
```
### When do we need to implement the dataSource?
> Whenever the data in the table is dynamic (i.e. not static cells)
>
> There are three important methods in this protocol ...
> - How many sections in the table?
> - How many rows in each section?
> - Give me a view to use to draw each cell at a given row in a given section

## Customizing Each Row
### Providing a UIView to draw each row
> It has to be a ```UITableViewCell``` (which is a subclass of UIView) or subclass thereof
>
> Only the visible ones will have a UITableViewCell, this means that UITableViewCells are reused as rows appear and disappear. Ramifications(衍生物) for multithreaded situations.

> The UITableView will ask its ```UITableViewDataSource``` for the ```UITableViewCell``` for a row

```Swift
func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let data = myInternalDataStructure[indexPath.section][indexPath.row]
    // myInternalDataStructure is conceptual(概念化的) here: it doesn't have to be an Array of Arrays
    
    let cell = ... // create a UITableViewCell and load it up with data
    return cell
}
```

### Examples
```Swift
// non-Custom cell, subtitle
func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let data = myInternalDataStructure[indexPath.section][indexPath.row]
    let dequeued = tv.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
    
    dequeued.textLabel?.text = data.importantInfo
    dequeued.detailTextLabel?.text = data.lessImportantInfo
    return cell
}

// custome cell
func tableView(_ tv: UITableBiew, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let data = myInternalDataStructure[indexPath.section][indexPath.row]
    let dequeued = tv.dequeueReusableCell(withIdentifier: "MyCustomCell", for: indexPath)
    if let cell = dequeued as? MyTableViewCell {
        cell.infoShownByThisCell = data.theDataTheCellNeedsToDisplayItsCustomLabelsEtc
    }
    return cell
}
```

## UITableViewDataSource
### How does a dynamic table know how many rows and sections?
> Via these ```UITableViewDataSource``` protocol methods ...

```Swift
func numberOfSections(in tv: UITableView) -> Int
func tableView(_ tv: UITableView, numberOfRowsInSection: Int) -> Int
```
### Number of sections is 1 by default
> If you don't implement ```numberOfSections(in tv: UITableView)```, it will be 1

### No default for numberOfRowsInSection
> This is a required method in this protocol(as is cellForRowAt)

### Static table
> Do not implement these ```dataSource``` methods for a static table

### Summary
> 1. Set the table view's ```dataSource``` to your Controller (automatic with UITableViewController)
> 2. Implement ```numberOfSections``` and ```numberOfRowsInSection```
> 3. Implement ```cellForRowAt``` to return loaded-up UITableViewCells

### Section titles are also considered part of the table's "data"
> So you return this information via UITableViewDataSource methods ...

```Swift
func tableView(UITableView, titleFor{Header,Footer}InSection: Int) -> String
```
> If a String is not sufficient(足够的), the UITableView's delegate can provide a UIView

## Table View Segues
### Preparing to segue from a row in a table view
> The sender argument to prepareForSegue is the UITableViewCell of that row ...

```Swift
func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
        switch identifier {
            case "XyzSegue": // handle XyzSegue here
            case "AbcSegue":
                if let cell = sender as? MyTableViewCell,
                   let indexPath = tableView.indexPath(for: cell),
                   let seguedToMVC = segue.destination as? MyVC {
                       seguedToMVC.publicAPI = data[indexPath.section][indexPath.row]
                   }
                   }
            
            
            default: break
        }
    }
}
```

## UITableViewDelegate
### The delegate controls how the UITableView is displayed
> Not the data it displays (that's the dataSource's job), how it is displayed

### Common for dataSource and delegate to be the same object
> Usually the Controller of the MVC containing the UITableView

### The delegate also lets you observe what the table view is doing
> Especially responding to when the user selects a row

## UITableView "Target/Action"
### UITableViewDelegate method sent when row is selected
> This is sort of like "table view target/action" (only needed if you're not segueing)
>
> Example: if the master in a split view wants to update the detail without segueing to a new one

```Swift
func tableView(UITableView, didSelectRowAt indexPath: IndexPath) {
    // go do something based on information about my Model
    // corresponding to indexPath.row in indexPath.section
    // maybe directly update the Detail if I'm the Master in a split view?
}
```

### Delegate method sent when Detail Disclosure button is touched
```Swift
func tableView(UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
```

## UITableView
### What if your Model changes?
```Swift
func reloadData()
```
> Causes the UITableView to call ```numberOfSectionsInTableView``` and ```numberOfRowsInSection``` all over again and then ```cellForRowAt``` on each visible row
>
> If only part of your Model changes, there are lighter-weight reloaders, for example ...

```Swift
func reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)
```

### Controlling the height of rows
> Row height can be fixed (UITableView's ```var rowHeight: CGFloat```)
>
> Or it can be determined using autolayout (rowHeight = ```UITableViewAutomaticDimension```)
>
> If you do automatic, help the table view out by setting ```estimatedRowHeight``` to something
>
> The UITableView's delegate can also control row heights ...

```Swift
func tableView(UITableView, {estimated}heightForRowAt indexPath: IndexPath) -> CGFloat
```
> Beware: the non-estimated version of this could get called A LOT if you have a big table