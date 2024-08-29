//
//  Binding.swift
//  ABZ.agency
//
//  Created by pfriedrix on 07.08.2024.
//

import SwiftUI

extension Store {
    public func binding<Value>(for keyPath: KeyPath<State, Value>, set action: @escaping (Value) -> Action) -> Binding<Value> {
        return Binding(
            get: { [ weak self ] in
                guard let self = self else { fatalError("Store is deallocated") }
                return state[keyPath: keyPath]
            },
            set: { [ weak self ] newValue in
                guard let self = self else { return }
                dispatch(action(newValue))
            }
        )
    }
}

extension Store where State: Codable {
    public func binding<Value>(for keyPath: KeyPath<State, Value>, set action: @escaping (Value) -> Action) -> Binding<Value> {
        return Binding(
            get: { [ weak self ] in
                guard let self = self else { fatalError("Store is deallocated") }
                return state[keyPath: keyPath]
            },
            set: { [ weak self ] newValue in
                guard let self = self else { return }
                dispatch(action(newValue))
            }
        )
    }
}
