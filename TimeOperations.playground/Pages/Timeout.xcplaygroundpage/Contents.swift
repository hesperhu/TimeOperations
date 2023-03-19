import Combine
import SwiftUI
import PlaygroundSupport

var subscriptions = [AnyCancellable]()

/*:
使用timeout，可以触发消息队列结束，或者发送错误 2023-03-19(Sun) 11:13:28
*/

enum TimeOutError: Error {
    case timeout
}

let timeoutTime = 5.0
/*:
创建定时结束的消息队列 2023-03-19(Sun) 11:14:14
*/
let source = PassthroughSubject<Void, Never>()

let timeoutSubject = source.timeout(.seconds(timeoutTime), scheduler: DispatchQueue.main)
/*:
创建定时错误的消息队列 2023-03-19(Sun) 11:14:33
*/
let sourceWithFailure = PassthroughSubject<Void, TimeOutError>()
let timeoutWithFailure = sourceWithFailure.timeout(.seconds(timeoutTime), scheduler: DispatchQueue.main, customError: {.timeout})

/*:
UI显示两个消息队列 2023-03-19(Sun) 11:14:58
*/

let timeline = TimelineView(title: "按钮")
let timelineWithFailure = TimelineView(title: "按钮(带错误处理)")


let view = VStack{
    Button("\(timeoutTime)秒内按按钮") {
        source.send()
    }
    timeline
    
    Button("\(timeoutTime)秒内按按钮") {
        sourceWithFailure.send()
    }
    timelineWithFailure
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 300, height: 300))

timeoutSubject.displayEvents(in: timeline)
timeoutWithFailure.displayEvents(in: timelineWithFailure)

/*:
![](hsw_2023-03-19_10.51.46.png)
*/

/*:
控制台显示两个队列 2023-03-19(Sun) 11:15:34
*/

timeoutSubject
    .sink { value in
        print("消息队列完成: \(value)")
    } receiveValue: { value in
        print("消息队列数据: \(value)")
    }
    .store(in: &subscriptions)

timeoutWithFailure
    .sink { value in
        print("消息队列(带错误处理)完成: \(value)")
    } receiveValue: { value in
        print("消息队列(带错误处理)数据: \(value)")
    }
    .store(in: &subscriptions)

/*:
```
 消息队列数据: ()
 消息队列(带错误处理)数据: ()
 消息队列完成: finished
 消息队列(带错误处理)完成: failure(__lldb_expr_21.TimeOutError.timeout)
 ```
*/
