/// A structure representing an effect that holds a state and an optional action.
///
/// The `Effect` struct is used to encapsulate both the current state and
/// an optional action that may trigger additional behavior or state changes.
///
/// - Note: Effects are often used in conjunction with reducers
/// to handle side effects in a state management system.
///
/// - Parameters:
///   - State: The state associated with the effect.
///   - Action: An optional action that might be triggered as a result of the state.
public struct Effect<Action> {
    
    enum Operation {
        case none
        case send(Action)
        case run(TaskPriority? = nil, @Sendable (_ send: Send<Action>) async -> Void)
    }
    
    let operation: Operation
}

extension Effect {
    public static var none: Self {
        return Self(operation: .none)
    }
    
    public static func run(priority: TaskPriority? = nil,
                           operation: @escaping @Sendable (_ send: Send<Action>) async throws -> Void,
                           catch handler: (@Sendable (_ error: Error, _ send: Send<Action>) async -> Void)? = nil) -> Self {
        Self(operation: .run(priority) { send in
            do {
                try await operation(send)
            } catch {
                guard let handler = handler else { return }
                await handler(error, send)
            }
        })
    }
    
    public static func send(_ action: Action) -> Self {
        Self(operation: .send(action))
     }
}

extension Effect.Operation: Equatable {
    static func == (lhs: Effect.Operation, rhs: Effect.Operation) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.run(let lhsPriority, _), .run(let rhsPriority, _)):
            return lhsPriority == rhsPriority
        default:
            return false
        }
    }
}

@MainActor
public struct Send<Action>: Sendable {
    let send: @MainActor @Sendable (Action) -> Void
    
    public init(send: @escaping @MainActor @Sendable (Action) -> Void) {
        self.send = send
    }
    
    public func callAsFunction(_ action: Action) {
        guard !Task.isCancelled else { return }
        self.send(action)
    }
}

