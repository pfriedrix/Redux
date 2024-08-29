//
//  Store.swift
//  ABZ.agency
//
//  Created by pfriedrix on 07.08.2024.
//

public protocol Storable {
    associatedtype State
    associatedtype Action
}

extension Storable where State: Codable {
    static var name: String {
        String(describing: type(of: self))
    }
}
