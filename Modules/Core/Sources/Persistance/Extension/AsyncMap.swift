extension Collection {
    internal func asyncMap<NewElement>(_ transform: (Element) async throws -> NewElement) async throws -> Array<NewElement> {
        // `withoutActuallyEscaping` is safe here because `TaskGroup` captures `item` closure
        // but `TaskGroup`'s lifetime is limited in this scope.
        // The `item` is captured by coroutine frame due to coroutine splitting, but the
        // frame's lifetime is upper bounded by the caller frame.
        return try await withoutActuallyEscaping(transform) { transform in
            return try await withOrderedTaskGroup(of: NewElement.self) { group in
                for element in self {
                    group.addTask {
                        return try await transform(element)
                    }
                }
                var newElements: [NewElement] = []
                newElements.reserveCapacity(self.count)
                for try await item in group {
                    newElements.append(item)
                }
                return newElements
            }
        }
    }
}
