import Combine
import SwiftUI
import PlaygroundSupport

var subscriptions = [AnyCancellable]()

/*:
throttle可以对消息进行采样 2023-03-19(Sun) 07:44:58
*/

let throttleDelay = 1.0
/*:
创建四个消息队列，一个消息源，两个采样消息队列，一个去抖动队列(用来对比效果) 2023-03-19(Sun) 07:45:38
*/
let source = PassthroughSubject<String, Never>()
let throttle = source
    .throttle(for: .seconds(throttleDelay), scheduler: DispatchQueue.main, latest: false)
    .share()
let throttleLatest = source
    .throttle(for: .seconds(throttleDelay), scheduler: DispatchQueue.main, latest: true)
    .share()
let debounced = source
    .debounce(for: .seconds(throttleDelay), scheduler: DispatchQueue.main)
    .share()
/*:
UI显示四个消息队列 2023-03-19(Sun) 07:46:02
*/
let sourceTimeLine = TimelineView(title: "消息源")
let throttleTimeLine = TimelineView(title: "最早节流消息")
let throttleLatestTimeLine = TimelineView(title: "最新节流消息")
let debounceTimeLine = TimelineView(title: "去抖动消息")
let view = VStack{
    sourceTimeLine
    throttleTimeLine
    throttleLatestTimeLine
    debounceTimeLine
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 400, height: 400))

source.displayEvents(in: sourceTimeLine)
throttle.displayEvents(in: throttleTimeLine)
throttleLatest.displayEvents(in: throttleLatestTimeLine)
debounced.displayEvents(in: debounceTimeLine)
/*:
![](hsw_2023-03-19_07.54.35.png)
*/

/*:
控制台显示消息队列 2023-03-19(Sun) 07:48:03
*/

source
    .sink { value in
        print("消息源(+\(deltaTime)s)：\(value)")
    }
    .store(in: &subscriptions)

throttle
    .sink { value in
        print("..最早节流消息(+\(deltaTime)s)：\(value)")
    }
    .store(in: &subscriptions)

throttleLatest
    .sink { value in
        print("..最新节流消息(+\(deltaTime)s)：\(value)")
    }
    .store(in: &subscriptions)

debounced
    .sink { value in
        print("->去抖动消息(+\(deltaTime)s)：\(value)")
    }
    .store(in: &subscriptions)

source.feed(with: typingHelloWorld)

/*:
```
 消息源(+0.0s)：H
 ..最新节流消息(+0.0s)：H
 ..最早节流消息(+0.0s)：H
 消息源(+0.0s)：He
 消息源(+0.1s)：Hel
 消息源(+0.2s)：Hell
 消息源(+0.4s)：Hello
 消息源(+0.6s)：Hello
 ..最新节流消息(+1.0s)：Hello
 ..最早节流消息(+1.0s)：He
 ->去抖动消息(+1.6s)：Hello
 消息源(+2.0s)：Hello W
 消息源(+2.0s)：Hello Wo
 ..最新节流消息(+2.0s)：Hello Wo
 ..最早节流消息(+2.0s)：Hello W
 消息源(+2.2s)：Hello Wor
 消息源(+2.5s)：Hello Worl
 消息源(+2.5s)：Hello World
 ..最新节流消息(+3.1s)：Hello World
 ..最早节流消息(+3.1s)：Hello Wor
 ->去抖动消息(+3.5s)：Hello World

 ```
*/
