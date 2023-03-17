import Combine
import SwiftUI
import PlaygroundSupport

/*:
collect(.byTime())可以按指定的时间跨度对消息进行分组 2023-03-17(Fri) 21:40:19
*/

var subscriptions = [AnyCancellable]()
let valuesPerscond = 1.0
let collectTimeStride = 2.5

/*:
创建源序列，以及对应的消息分组序列 2023-03-17(Fri) 21:42:18
*/

let sourcePublisher = PassthroughSubject<Date, Never>()
let collectPublisher = sourcePublisher
    .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
/*:
定时器发送消息，与源序列对接 2023-03-17(Fri) 21:43:09
*/
Timer
    .publish(every: 1.0/valuesPerscond, on: .main, in: .common)
    .autoconnect()
    .subscribe(sourcePublisher)
    .store(in: &subscriptions)

/*:
使用UI展现两个队列 2023-03-17(Fri) 21:43:41
*/

let sourceTimeLine = TimelineView(title: "消息队列：")
let collectedTimeline = TimelineView(title: "消息分组(\(collectTimeStride))")
let view = VStack {
    sourceTimeLine
    collectedTimeline
}
PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 300, height: 200))
/*:
 ![UI](hsw_2023-03-17_21.44.52.png)
*/


/*:
使用print展现两个队列 2023-03-17(Fri) 21:44:10
*/

sourcePublisher.displayEvents(in: sourceTimeLine)
collectPublisher.displayEvents(in: collectedTimeline)

sourcePublisher
    .sink { date in
        print("source message: \(date)")
    }
    .store(in: &subscriptions)

collectPublisher
    .sink { dates in
        print("colleted message: \(dates)")
    }
    .store(in: &subscriptions)

/*:
``` 控制台输出：
 source message: 2023-03-17 13:44:43 +0000
 source message: 2023-03-17 13:44:44 +0000
 colleted message: [2023-03-17 13:44:43 +0000, 2023-03-17 13:44:44 +0000]
 source message: 2023-03-17 13:44:45 +0000
 source message: 2023-03-17 13:44:46 +0000
 source message: 2023-03-17 13:44:47 +0000
 colleted message: [2023-03-17 13:44:45 +0000, 2023-03-17 13:44:46 +0000, 2023-03-17 13:44:47 +0000]
 source message: 2023-03-17 13:44:48 +0000
 source message: 2023-03-17 13:44:49 +0000
 colleted message: [2023-03-17 13:44:48 +0000, 2023-03-17 13:44:49 +0000]
```
*/
