import Foundation

public protocol Storable {
    
    /// Saves the current state to persistent storage.
    ///
    /// This method should handle serializing and storing the current state
    /// in a way that allows it to be restored later.
    func save()
    
    /// Loads the state from persistent storage.
    ///
    /// This method should handle retrieving and deserializing the state from
    /// storage. If no state is found, or if deserialization fails, it should return `nil`.
    ///
    /// - Returns: The loaded state, or `nil` if no valid state is found.
    static func load() -> Self?
}

/// Extension of `Store` that adds persistent storage capabilities for state management.
///
/// This extension allows the `Store` to automatically persist its state after each action
/// and restore its state during initialization. It is designed to work with states that conform
/// to the `Storable` protocol, which provides the `save` and `load` methods for managing persistence.
extension Store where State: Storable {
    
    /// Convenience initializer for `Store` that restores the state from storage if available.
    ///
    /// This initializer first attempts to restore the state from persistent storage using the `Storable.load()` method.
    /// If no saved state is found, or if the restoration fails, it defaults to the provided `defaultState`.
    /// After initialization, the state is immediately saved to storage.
    ///
    /// - Parameters:
    ///   - reducer: The reducer that handles state updates and actions.
    ///   - defaultState: The default state to use if no saved state is found.
    public convenience init(reducer: R, defaultState: State) {
        let restoredState = Self.restore()
        self.init(initial: restoredState ?? defaultState , reducer: reducer)
        
        if restoredState == nil {
            logger.info("State restored from storage: \(state)")
            state.save()
        } else {
            logger.info("State default used: \(state)")
        }
    }
    
    /// Restores the saved state from persistent storage.
    ///
    /// This method uses the `Storable.load()` function to retrieve the state from persistent storage.
    /// If no valid state is found, it returns `nil`, allowing the store to use the provided `defaultState`.
    ///
    /// - Returns: The restored state, or `nil` if no valid state is available.
    private static func restore() -> State? {
        State.load()
    }
    
    /// Dispatches an action to the store, triggering state updates and persisting the new state.
    ///
    /// This method asynchronously processes an action, allowing the reducer to apply changes to the state.
    /// After the state is updated, it is immediately saved to persistent storage using the `Storable.save()` method.
    /// All state changes are applied within the main actor context to ensure thread safety.
    ///
    /// - Parameter action: The action to be dispatched to the reducer for processing.
    @MainActor
    public func dispatch(_ action: Action) {
        logger.debug("Dispatching action: \(action)")
        
        dispatch(state, action)
        objectWillChange.send()
    }
    
    /// Handles the core logic for dispatching an action, reducing the state, and processing effects.
    ///
    /// This method uses the provided action to update the current state, then saves the updated state to storage.
    /// If the reducer returns an effect, it processes the effect, which may involve dispatching another action
    /// or performing asynchronous operations. This ensures that side effects are properly handled.
    ///
    /// - Parameters:
    ///   - state: The current state to be updated.
    ///   - action: The action to apply to the state.
    @MainActor
    internal func dispatch(_ state: State, _ action: Action) {
        var currentState = state
        let effect = reducer.reduce(into: &currentState, action: action)
        
        logger.info("New state after action \(action): \(currentState)")
        
        self.state = currentState
        self.state.save()
        
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

extension Storable where Self: Codable {
    
    /// Saves the current state to UserDefaults.
    ///
    /// - Parameter key: The key under which the state will be saved.
    public func save(forKey key: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save state: \(error)")
        }
    }
    
    /// Loads the state from UserDefaults.
    ///
    /// - Parameter key: The key under which the state is stored.
    /// - Returns: The loaded state, or `nil` if no valid state is found.
    public static func load(fromKey key: String) -> Self? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        do {
            let state = try decoder.decode(Self.self, from: data)
            return state
        } catch {
            print("Failed to load state: \(error)")
            return nil
        }
    }
}
