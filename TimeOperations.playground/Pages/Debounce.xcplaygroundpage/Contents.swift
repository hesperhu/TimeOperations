import Combine
import SwiftUI
import PlaygroundSupport

/*:
debouce可以消除队列中的抖动消息 2023-03-18(Sat) 11:06:22
*/

var subscriptions = [AnyCancellable]()
/*:
定义去抖动等待的时间
*/
let debounceTime = 1.3
/*:
 1. 定义一个含有抖动消息的队列
 2. 定义一个去抖动的消息队列
*/
let passthroughPublisher = PassthroughSubject<String, Never>()
let debouncedPublisher = passthroughPublisher
    .debounce(for: .seconds(debounceTime), scheduler: DispatchQueue.main)
    .share()
/*:
用UI显示两个消息队列
*/
let passthroughTimeLine = TimelineView(title: "原始消息：")
let debouncedTimeLine = TimelineView(title: "过滤后的消息：")

let view = VStack {
    passthroughTimeLine
    debouncedTimeLine
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 400, height: 300))

passthroughPublisher.displayEvents(in: passthroughTimeLine)
debouncedPublisher.displayEvents(in: debouncedTimeLine)
/*:
![](hsw_2023-03-18_11.03.32.png)
*/

/*:
用控制台显示两个消息队列
*/
passthroughPublisher
    .sink { value in
        print("Source message[\(deltaTime)s]: \(value)")
    }
    .store(in: &subscriptions)

debouncedPublisher
    .sink { value in
        print("Debounced message[\(deltaTime)s]: \(value)")
    }
    .store(in: &subscriptions)
passthroughPublisher.feed(with: typingHelloWorld)
/*:
```
 Source message[0.0s]: H
 Source message[0.0s]: He
 Source message[0.1s]: Hel
 Source message[0.2s]: Hell
 Source message[0.4s]: Hello
 Source message[0.5s]: Hello
 Debounced message[1.8s]: Hello
 Source message[2.0s]: Hello W
 Source message[2.1s]: Hello Wo
 Source message[2.1s]: Hello Wor
 Source message[2.4s]: Hello Worl
 Source message[2.4s]: Hello World
 Debounced message[3.7s]: Hello World
 ```
*/
