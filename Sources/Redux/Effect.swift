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
public struct Effect<State, Action> {
    
    /// The current state of the effect.
    let state: State
    
    /// The action that might be triggered, if any.
    let action: Action?
    
    /// Initializes an effect with both state and an optional action.
    ///
    /// This initializer allows creating an effect that holds both a state and an
    /// optional action. The action may trigger side effects or additional behavior
    /// in the state management system.
    ///
    /// - Parameters:
    ///   - state: The state associated with the effect.
    ///   - action: The action that may be triggered, if any.
    public init(state: State, action: Action?) {
        self.state = state
        self.action = action
    }
    
    /// Initializes an effect with a state but without any action.
    ///
    /// This initializer creates an effect with only the state, without any
    /// associated action. This is useful when no immediate action is needed,
    /// and only the state is required.
    ///
    /// - Parameter state: The state associated with the effect.
    public init(state: State) {
        self.state = state
        self.action = nil
    }
}
