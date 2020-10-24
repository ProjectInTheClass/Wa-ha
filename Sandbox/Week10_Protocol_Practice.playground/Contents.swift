import UIKit

var str = "Hello, playground"

protocol StackProtocol {
    mutating func push(_ value : Int)
    mutating func pop() -> Int
    func isEmpty() -> Bool
    func peek() -> Int
    func size() -> Int
}

struct Stack : StackProtocol {
    
    var st : [Int] = []

    mutating func push(_ value: Int) {
        st.append(value)
    }
    mutating func pop() -> Int {
        return st.removeLast()
    }
    func isEmpty() -> Bool{
        return st.isEmpty
    }
    func peek() -> Int {
        return st[st.count-1]
    }
    func size() -> Int{
        return st.count
    }
}

var stack = Stack()
stack.push(3)
stack.push(4)
print(stack.peek())
print(stack.pop())


protocol QueueProtocol {
    mutating func enqueue(_ value : Int)
    mutating func dequeue() -> Int
    func size() -> Int
}

struct Queue : QueueProtocol {
    var q : [Int] = []
    
    mutating func enqueue(_ value: Int) {
        q.append(value)
    }
    mutating func dequeue() -> Int{
        return q.removeFirst()
    }
    func size() -> Int {
        return q.count
    }
}

var queue = Queue()
queue.enqueue(3)
queue.enqueue(4)
queue.enqueue(5)
print(queue.dequeue())
print(queue.q)





