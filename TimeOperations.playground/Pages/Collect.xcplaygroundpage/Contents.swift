import Combine
import SwiftUI
import PlaygroundSupport

/*:
collect(.byTime()/.byTimeOrCount())可以按指定的时间跨度对消息进行分组 2023-03-17(Fri) 21:40:19
*/

var subscriptions = [AnyCancellable]()
let valuesPerscond = 1.0
let collectTimeStride = 2.5
let collectMaxCount = 2

/*:
创建源序列，以及对应的消息分组序列,flat消息分组序列 2023-03-17(Fri) 21:42:18
*/

let sourcePublisher = PassthroughSubject<Date, Never>()
let collectPublisher = sourcePublisher
    .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
let flatCollectPublisher = collectPublisher
    .flatMap { dates in
        dates.publisher
    }
let collectPublisherCountLimit = sourcePublisher
    .collect(.byTimeOrCount(DispatchQueue.main, .seconds(collectTimeStride), collectMaxCount))
    .flatMap { dates in
        dates.publisher
    }
/*:
定时器发送消息，与源序列对接 2023-03-17(Fri) 21:43:09
*/
Timer
    .publish(every: 1.0/valuesPerscond, on: .main, in: .common)
    .autoconnect()
    .subscribe(sourcePublisher)
    .store(in: &subscriptions)

/*:
使用UI展现四个队列 2023-03-17(Fri) 21:43:41
*/

let sourceTimeLine = TimelineView(title: "消息队列：")
let collectedTimeline = TimelineView(title: "消息分组(\(collectTimeStride))")
let flatCollectedTimeline = TimelineView(title: "flat消息分组(\(collectTimeStride))")
let collectedCountLimitTimeLine = TimelineView(title: "消息分组\(collectTimeStride)秒\(collectMaxCount)个")
let view = VStack {
    sourceTimeLine
    collectedTimeline
    flatCollectedTimeline
    collectedCountLimitTimeLine
}
PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 300, height: 800))
/*:
 ![UI](hsw_2023-03-18_10.07.43.png)
*/


/*:
使用print展现四个队列 2023-03-17(Fri) 21:44:10
*/

sourcePublisher.displayEvents(in: sourceTimeLine)
collectPublisher.displayEvents(in: collectedTimeline)
flatCollectPublisher.displayEvents(in: flatCollectedTimeline)
collectPublisherCountLimit.displayEvents(in: collectedCountLimitTimeLine)

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

flatCollectPublisher
    .sink { date in
        print("flat colleted message: \(date)")
    }
    .store(in: &subscriptions)

collectPublisherCountLimit
    .sink { date in
        print("collected count limited message: \(date)")
    }
    .store(in: &subscriptions)


/*:
``` 控制台输出：
 source message: 2023-03-18 02:07:25 +0000
 source message: 2023-03-18 02:07:26 +0000
 collected count limited message: 2023-03-18 02:07:25 +0000
 collected count limited message: 2023-03-18 02:07:26 +0000
 colleted message: [2023-03-18 02:07:25 +0000, 2023-03-18 02:07:26 +0000]
 flat colleted message: 2023-03-18 02:07:25 +0000
 flat colleted message: 2023-03-18 02:07:26 +0000
 source message: 2023-03-18 02:07:27 +0000
 source message: 2023-03-18 02:07:28 +0000
 collected count limited message: 2023-03-18 02:07:27 +0000
 collected count limited message: 2023-03-18 02:07:28 +0000
 source message: 2023-03-18 02:07:29 +0000
 colleted message: [2023-03-18 02:07:27 +0000, 2023-03-18 02:07:28 +0000, 2023-03-18 02:07:29 +0000]
 flat colleted message: 2023-03-18 02:07:27 +0000
 flat colleted message: 2023-03-18 02:07:28 +0000
 flat colleted message: 2023-03-18 02:07:29 +0000
 collected count limited message: 2023-03-18 02:07:29 +0000
 source message: 2023-03-18 02:07:30 +0000
 source message: 2023-03-18 02:07:31 +0000
 collected count limited message: 2023-03-18 02:07:30 +0000
 collected count limited message: 2023-03-18 02:07:31 +0000
 colleted message: [2023-03-18 02:07:30 +0000, 2023-03-18 02:07:31 +0000]
 flat colleted message: 2023-03-18 02:07:30 +0000
 flat colleted message: 2023-03-18 02:07:31 +0000
 source message: 2023-03-18 02:07:32 +0000
 source message: 2023-03-18 02:07:33 +0000
 collected count limited message: 2023-03-18 02:07:32 +0000
 collected count limited message: 2023-03-18 02:07:33 +0000
```
*/
