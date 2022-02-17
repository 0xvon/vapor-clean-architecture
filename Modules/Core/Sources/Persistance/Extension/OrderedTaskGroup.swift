// Copyright © 2021 Yuta Saito
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the “Software”), to deal in the Software without
// restriction, including without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

/// Starts a new task group which provides a scope in which a dynamic number of tasks can be created
/// and returns values returned by tasks in the order that the tasks *added*.
///
/// This API is similar to `withThrowingTaskGroup`, but it differs only in the order of task result iterator.
///
/// For example:
///
///     let sources = [10, 1, 5]
///     try await withOrderedTaskGroup(of: Int.self) { group in
///       for i in [10, 5, 1] {
///         group.addTask {
///           try await Task.sleep(nanoseconds: UInt64(i) * 10_000_000)
///           return i
///         }
///       }
///       var items = [Int]()
///       for try await i in group {
///         print(i, terminator: " ")
///       }
///       // Prints 10 1 5
///     }
///
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public func withOrderedTaskGroup<ChildTaskResult, GroupResult>(
  of childTaskResultType: ChildTaskResult.Type,
  returning returnType: GroupResult.Type = GroupResult.self,
  body: (inout OrderedTaskGroup<ChildTaskResult, Error>) async throws -> GroupResult
) async throws -> GroupResult {
  try await withThrowingTaskGroup(of: OrderedTaskGroup<ChildTaskResult, Error>.InnerTaskResult.self)
  { innerGroup in
    var group = OrderedTaskGroup(inner: innerGroup)
    return try await body(&group)
  }
}

/// A task group serves as storage for dynamically created child tasks,
/// returning results in the order that the tasks *added*
///
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public struct OrderedTaskGroup<ChildTaskResult, Failure: Error> {

  typealias TaskIndex = Int
  typealias InnerTaskResult = (index: TaskIndex, result: ChildTaskResult)

  internal var inner: ThrowingTaskGroup<InnerTaskResult, Failure>
  internal var nextTaskIndex: TaskIndex
  internal var waitingTaskIndex: TaskIndex
  internal var resultBuffer: PriorityQueue<InnerTaskResult>

  internal init(inner: ThrowingTaskGroup<InnerTaskResult, Failure>) {
    self.inner = inner
    self.nextTaskIndex = 0
    self.waitingTaskIndex = 0
    self.resultBuffer = PriorityQueue<InnerTaskResult>(areInIncreasingOrder: { lhs, rhs in
      lhs.index > rhs.index
    })
  }
    
  /// Add a child task to the group
  /// - SeeAlso: `TaskGroup.addTask(priority:operation:)`
  public mutating func addTask(
    priority: TaskPriority? = nil,
    operation: @Sendable @escaping () async throws -> ChildTaskResult
  ) {
    let currentTaskIndex = nextTaskIndex
    nextTaskIndex += 1
    inner.addTask(
      priority: priority,
      operation: {
        (currentTaskIndex, try await operation())
      })
  }

  /// - SeeAlso: `TaskGroup.next()`
  public mutating func next() async throws -> ChildTaskResult? {
    if let head = resultBuffer.first, head.index == waitingTaskIndex {
      _ = resultBuffer.pop()
      waitingTaskIndex += 1
      return head.result
    }
    while let (taskIndex, result) = try await inner.next() {
      if taskIndex == waitingTaskIndex {
        waitingTaskIndex += 1
        return result
      } else {
        resultBuffer.push((taskIndex, result))
      }
    }
    return nil
  }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension OrderedTaskGroup: AsyncSequence {
  public typealias Element = ChildTaskResult

  public typealias AsyncIterator = OrderedTaskGroup.Iterator

  @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
  public struct Iterator: AsyncIteratorProtocol {
    public typealias Element = ChildTaskResult

    var group: OrderedTaskGroup
    var finished: Bool = false

    init(group: OrderedTaskGroup) {
      self.group = group
    }

    public mutating func next() async throws -> ChildTaskResult? {
      guard !finished else { return nil }
      guard let element = try await group.next() else {
        finished = true
        return nil
      }
      return element
    }

    public mutating func cancel() {

    }
  }
  public func makeAsyncIterator() -> Iterator {
    return Iterator(group: self)
  }
}

internal struct PriorityQueue<Element> {
  private var elements: [Element] = []
  private let areInIncreasingOrder: (Element, Element) -> Bool

  internal init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
    self.areInIncreasingOrder = areInIncreasingOrder
  }

  internal mutating func push(_ insertingElement: Element) {
    var insertingIndex = elements.count
    elements.append(insertingElement)
    elements.withUnsafeMutableBufferPointer { elements in
      while insertingIndex > 0 {
        let parentIndex = (insertingIndex - 1) / 2
        let parent = elements[parentIndex]
        guard areInIncreasingOrder(parent, insertingElement) else { break }
        elements.swapAt(parentIndex, insertingIndex)
        insertingIndex = parentIndex
      }
    }
  }

  internal mutating func pop() -> Element? {
    guard let movingElement = elements.popLast() else { return nil }
    guard let first = elements.first else { return nil }
    rotateTree(movingIndex: 0, movingElement: movingElement)
    return first
  }

  internal var first: Element? {
    return elements.first
  }

  private mutating func rotateTree(movingIndex: Int, movingElement: Element) {
    elements.withUnsafeMutableBufferPointer { elements in
      elements[movingIndex] = movingElement

      var movingIndex = movingIndex
      while true {
        var childIndex = movingIndex * 2 + 1
        guard childIndex < elements.count else { break }
        var child = elements[childIndex]
        let rightChildIndex = childIndex + 1
        if rightChildIndex < elements.count {
          let rightChild = elements[rightChildIndex]
          if areInIncreasingOrder(child, rightChild) {
            childIndex = rightChildIndex
            child = rightChild
          }
        }
        guard areInIncreasingOrder(movingElement, child) else { break }
        elements[childIndex] = movingElement
        elements[movingIndex] = child
        movingIndex = childIndex
      }
    }
  }
}
