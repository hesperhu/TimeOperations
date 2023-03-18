import Combine
import Foundation

/*:
delay可以用来延迟时间序列 2023-03-17(Fri) 20:59:52
*/

var subscriptions = [AnyCancellable]()
/*:
三个publisher，其中两个是第一个的依次时延序列 2023-03-17(Fri) 20:55:30
*/
let relayPublisher = PassthroughSubject<Date, Never>()
let delayPublisher = relayPublisher.delay(for: 0.5, scheduler: DispatchQueue.main)
let delayPublisher2 = delayPublisher.delay(for: 0.5, scheduler: DispatchQueue.main)
/*:
 用定时器发送消息，连接第一个publisher 2023-03-17(Fri) 20:56:58
*/
Timer
    .publish(every: 1.5, on: .main, in: .common)
    .autoconnect()
    .subscribe(relayPublisher)
    .store(in: &subscriptions)

/*:
将三个消息序列合并，打印出来 2023-03-17(Fri) 20:56:52
*/
relayPublisher
    .merge(with: delayPublisher, delayPublisher2)
    .sink { value in
        print("\(Date.now): Message is \(value)")
    }
    .store(in: &subscriptions)

/*: 输出结果
 
```
 2023-03-18 03:12:07 +0000: Message is 2023-03-18 03:12:07 +0000
 2023-03-18 03:12:07 +0000: Message is 2023-03-18 03:12:07 +0000
 2023-03-18 03:12:08 +0000: Message is 2023-03-18 03:12:07 +0000
 2023-03-18 03:12:08 +0000: Message is 2023-03-18 03:12:08 +0000
 2023-03-18 03:12:09 +0000: Message is 2023-03-18 03:12:08 +0000
 2023-03-18 03:12:09 +0000: Message is 2023-03-18 03:12:08 +0000
 2023-03-18 03:12:10 +0000: Message is 2023-03-18 03:12:10 +0000
 2023-03-18 03:12:10 +0000: Message is 2023-03-18 03:12:10 +0000
 2023-03-18 03:12:11 +0000: Message is 2023-03-18 03:12:10 +0000
 2023-03-18 03:12:11 +0000: Message is 2023-03-18 03:12:11 +0000
 2023-03-18 03:12:12 +0000: Message is 2023-03-18 03:12:11 +0000
 2023-03-18 03:12:12 +0000: Message is 2023-03-18 03:12:11 +0000
 ```
*/
