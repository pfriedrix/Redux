//
//  File.swift
//  
//
//  Created by pfriedrix on 23.08.2024.
//

public struct Effect<State, Action> {
    let state: State
    let action: Action?
    
    public init(state: State, action: Action?) {
        self.state = state
        self.action = action
    }
    
    public init(state: State) {
        self.state = state
        self.action = nil
    }
}
