//
//  File.swift
//
//
//  Created by pfriedrix on 22.08.2024.
//

import Foundation

extension Store where State: Codable {
    static private var storageKey: String {
        S.name + "-storage"
    }
    
    private func persist(_ state: State) {
        do {
            let encoded = try JSONEncoder().encode(state)
            UserDefaults.standard.set(encoded, forKey: Store.storageKey)
        } catch {
            print("Error: \(error)")
        }
    }
    
    public convenience init(reducer: S, defaultState: State) {
        let restoredState = Self.restore() ?? defaultState
        self.init(initial: restoredState, reducer: reducer)
    }
    
    public static func restore() -> State? {
        guard let saved = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        
        do {
            let decoded = try JSONDecoder().decode(S.State.self, from: saved)
            return decoded
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    public func dispatch(_ action: Action) {
        Task { @MainActor in
            await dispatch(state, action)
        }
    }
    
    @MainActor
    private func dispatch(_ currentState: State, _ action: Action) async {
        let effect = await reducer.reduce(into: currentState, action: action)
        persist(effect.state)
        
        DispatchQueue.main.async {
            self.state = effect.state
        }
        
        if let action = effect.action {
            await dispatch(effect.state, action)
        }
    }
}
