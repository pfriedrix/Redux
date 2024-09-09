/// A protocol that defines the basic requirements for types that can store and manage state.
///
/// Types that conform to `Storable` are expected to define their associated
/// state and action types, making them capable of storing and handling
/// state transitions triggered by actions.
///
/// This protocol can be extended to provide additional functionality,
/// such as state persistence, when combined with other protocols (e.g., `Codable`).
///
/// - Associated Types:
///   - State: The type representing the state stored in the conforming type.
///   - Action: The type representing the actions that may trigger state changes.
public protocol Storable {
    
    /// The type of state being stored.
    associatedtype State
    
    /// The type of action that may trigger state transitions.
    associatedtype Action
}

extension Storable where State: Codable {
    
    /// A static property that returns the name of the conforming type as a string.
    ///
    /// This is useful for identifying types during state persistence
    /// or logging, especially when saving or retrieving states using
    /// a unique identifier.
    ///
    /// - Returns: The name of the conforming type as a `String`.
    static var name: String {
        String(describing: type(of: self))
    }
}
