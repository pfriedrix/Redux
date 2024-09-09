//
//  Store.swift
//  ABZ.agency
//
//  Created by pfriedrix on 07.08.2024.
//

import Foundation

final public class Store<S: Reducer>: ObservableObject {
    public typealias State = S.State
    public typealias Action = S.Action
    
    @Published public internal(set) var state: State
    
    internal let reducer: S
    
    public required init(initial: State, reducer: S) {
        self.state = initial
        self.reducer = reducer
    }
    
    public func dispatch(_ action: Action) {
        Task { @MainActor in
            await dispatch(state, action)
        }
    }
    
    @MainActor
    private func dispatch(_ currentState: State, _ action: Action) async {
        let effect = await reducer.reduce(into: currentState, action: action)
        
        DispatchQueue.main.async {
            self.state = effect.state
        }
        
        if let action = effect.action {
            await dispatch(effect.state, action)
        }
    }
}

extension Store {
    public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }
}
