import Combine
import SwiftUI
import PlaygroundSupport

/*:
用View UI显示时间和延迟时间序列 2023-03-16(Thu) 08:52:39 
*/

let valuesPersecond = 1.0
let delayInSeconds = 1.5

let sourcePublisher = PassthroughSubject<Date, Never>()

let delaydPublisher = sourcePublisher.delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue.main)

let subscription = Timer
    .publish(every: 1.0/valuesPersecond, on: .main, in: .common)
    .autoconnect()
    .subscribe(sourcePublisher)

let sourceTimeLine = TimelineView(title: "\(valuesPersecond) per sec.")

let delayTimeLine = TimelineView(title: "\(delayInSeconds)s delay")

let view = VStack{
    sourceTimeLine
    delayTimeLine
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 375, height: 600))

sourcePublisher.displayEvents(in: sourceTimeLine)
delaydPublisher.displayEvents(in: delayTimeLine)
/*:
 PlayGround中的MK用法：[Markup Reference](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html#//apple_ref/doc/uid/TP40016497-CH2-SW1)
 
 PlaygroundSupport:[Playground Support](https://developer.apple.com/documentation/playgroundsupport)
 */
