import Combine
import SwiftUI
import PlaygroundSupport

var subscriptions = [AnyCancellable]()

/*:
使用measureInterval(using:)来测量相邻消息的时间间隔 2023-03-19(Sun) 15:44:27
*/


/*:
创建一个消息队列，两个时间测量器队列 2023-03-19(Sun) 15:45:39
*/

let sourcePublisher = PassthroughSubject<String, Never>()

let measureTimePublisher = sourcePublisher.measureInterval(using: DispatchQueue.main)

let measureTimePublisherInRunLoop = sourcePublisher.measureInterval(using: RunLoop.main)

/*:
UI显示三个队列
*/

let sourceTimeline = TimelineView(title: "信息源")
let measuredTimeline = TimelineView(title: "测量信息(DQ)")
let measuredRLTimeLine = TimelineView(title: "测量信息(RL)")

let view = VStack{
    sourceTimeline
    measuredTimeline
    measuredRLTimeLine
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 300, height: 300))

measureTimePublisher.displayEvents(in: measuredTimeline)
sourcePublisher.displayEvents(in: sourceTimeline)
measureTimePublisherInRunLoop.displayEvents(in: measuredRLTimeLine)

/*:
![](hsw_2023-03-19_15.43.26.png)
*/

/*:
控制台显示三个队列信息 2023-03-19(Sun) 15:46:53
*/
sourcePublisher
    .sink{print("+\(deltaTime)s: 源信息: \($0)")}
    .store(in: &subscriptions)
measureTimePublisher
    .sink{print("+\(deltaTime)s: -->测量信息(DispQue): \(Double($0.magnitude) / 1_000_000_000.00 )")}
    .store(in: &subscriptions)
measureTimePublisherInRunLoop
    .sink { value in
        print("+\(deltaTime)s: ++>测量信息(RunLoop): \(value.magnitude)")
    }
    .store(in: &subscriptions)

sourcePublisher.feed(with: typingHelloWorld)

/*:
```
 +0.0s: 源信息: H
 +0.0s: ++>测量信息(RunLoop): 0.09597897529602051
 +0.0s: -->测量信息(DispQue): 0.096420907
 +0.0s: 源信息: He
 +0.0s: ++>测量信息(RunLoop): 0.0046509504318237305
 +0.0s: -->测量信息(DispQue): 0.004575954
 +0.1s: 源信息: Hel
 +0.1s: ++>测量信息(RunLoop): 0.10824799537658691
 +0.1s: -->测量信息(DispQue): 0.108253469
 +0.2s: 源信息: Hell
 +0.2s: ++>测量信息(RunLoop): 0.10560798645019531
 +0.2s: -->测量信息(DispQue): 0.105619363
 +0.4s: 源信息: Hello
 +0.4s: ++>测量信息(RunLoop): 0.18726706504821777
 +0.4s: -->测量信息(DispQue): 0.187276179
 +0.5s: 源信息: Hello
 +0.5s: ++>测量信息(RunLoop): 0.12061500549316406
 +0.5s: -->测量信息(DispQue): 0.120597812
 +1.9s: 源信息: Hello W
 +1.9s: ++>测量信息(RunLoop): 1.378132939338684
 +1.9s: -->测量信息(DispQue): 1.378142777
 +2.1s: 源信息: Hello Wo
 +2.1s: ++>测量信息(RunLoop): 0.2014549970626831
 +2.1s: -->测量信息(DispQue): 0.201470327
 +2.1s: 源信息: Hello Wor
 +2.1s: ++>测量信息(RunLoop): 0.00014102458953857422
 +2.1s: -->测量信息(DispQue): 0.000135757
 +2.4s: 源信息: Hello Worl
 +2.4s: ++>测量信息(RunLoop): 0.31730401515960693
 +2.4s: -->测量信息(DispQue): 0.317301633
 +2.4s: 源信息: Hello World
 +2.4s: ++>测量信息(RunLoop): 0.00013399124145507812
 +2.4s: -->测量信息(DispQue): 0.000142208
 ```
*/
