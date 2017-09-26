```
/* Sat. 23 Sept 2017
    @Vb
*/
```
[TOC]

---
# Lecture 13

## Timer

### Used to execute code periodically(周期性地)
> You can set it up to go off once at sometime in the future, or to repeatedly go off
>
> If repeatedly, the system will not guarantee exactly when it goes off, so this is not "real-time"
>
> But for most UI "order of magnitude(巨大)" activities, it's perfectly fine
>
> We don't generally use it for "animation" (more on that later)
>
> It's more for larger-grained(大型) activities

### Run loops
> Timer work with run loops
>
> So far your purposes, you can only use Timer on the main queue

### Fire one off with this method ...
```Swift
class func scheduledTimer(
    withTimeInterval: TimeInterval,
    repeats: Bool,
    block: (Timer) -> Void
) -> Timer
```

### Example
```Swift
private weak var timer: Timer?
timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) {
    // your code here
}
```
> Every 2 seconds (approximately), the closure will be executed.
>
> Note that the var we stored the timer in is weak.
>
> That's okay because the run loop will keep a strong pointer to this as long as it's scheduled

## NSTimer
### Stopping a repeating timer
> We need to be a bit careful with repeating timers ... you don't want them running forever
>
> Stop them by calling ```invalidate()``` on them ...

```Swift
timer.invalidate()
```
> This tells the run loop to stop scheduling the timer.
>
> The run loop will thus give up its strong pointer to this timer.
>
> If your pointer to the timer is weak, it will be set to nil at this point.
>
> This is nice because an invalidated timer like this is no longer of any use to you.

### Tolerance(延迟度)
> It might help system performance to set a tolerance for "late firing"
>
> For example, if you have timer that goes off once a minute, a tolerance of 10s might be fine.

```Swift
myOneMinuteTimer.tolerance = 10 // in seconds
```
> The firing time is relative to the start of the timer (not the last time it fired), i.e. no "drift(迁移)".