import Foundation
/// A class responsible for managing the application's state and dispatching actions.
///
/// The `Store` class holds the application's state and provides a mechanism to dispatch
/// actions, which are handled by the associated reducer. The reducer updates the state
/// based on the action, and the store publishes the new state to any observing views or objects.
///
/// This class also handles asynchronous state updates and supports side effects through the
/// reducer's `Effect` mechanism.
///
/// - Parameters:
///   - R: The type of the reducer, which conforms to the `Reducer` protocol and defines
///        the state's structure and how actions are handled.
final public class Store<R: Reducer>: ObservableObject {
    
    /// The type representing the current state of the store.
    public typealias State = R.State
    
    /// The type representing the actions handled by the store.
    public typealias Action = R.Action
    
    /// The current state of the store
    public internal(set) var state: State
    
    /// The reducer responsible for handling actions and updating the state.
    internal let reducer: R
    
    /// Initializes the store with an initial state and a reducer.
    ///
    /// - Parameters:
    ///   - initial: The initial state of the store.
    ///   - reducer: The reducer that will handle actions and state updates.
    public required init(initial: State, reducer: R) {
        self.state = initial
        self.reducer = reducer
    }
    
    /// Dispatches an action to the store, triggering a state update.
    ///
    /// The action is sent to the reducer, which processes it and returns an effect that
    /// may update the state and/or trigger additional actions. The state is then updated
    /// on the main thread.
    ///
    /// - Parameter action: The action to dispatch to the reducer.
    @MainActor
    public func dispatch(_ action: Action) {
        dispatch(state, action)
        objectWillChange.send()
    }
    
    /// A private function that handles the dispatching of actions and state updates asynchronously.
    ///
    /// This function invokes the reducer to process the action and returns an effect. If the effect
    /// includes a new action, the method recursively dispatches the action until no further actions
    /// are returned.
    ///
    /// - Parameters:
    ///   - currentState: The current state before the action is applied.
    ///   - action: The action to process and apply to the state.
    @MainActor
    internal func dispatch(_ state: State, _ action: Action) {
        var currentState = state
        let effect = reducer.reduce(into: &currentState, action: action)
        
        self.state = currentState
        
        switch effect.operation {
        case .none: return
        case let .send(action):
            dispatch(action)
        case let .run(priority, operation):
            Task(priority: priority) { [ weak self ] in
                await operation(Send { action in
                    self?.dispatch(action)
                })
            }
        }
    }
}
