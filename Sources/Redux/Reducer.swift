//
//  Reducer.swift
//  ABZ.agency
//
//  Created by pfriedrix on 07.08.2024.
//

public protocol Reducer<State, Action>: Storable {
    @MainActor func reduce(into state: State, action: Action) async -> Effect<State, Action>
}
