//
//  ZBRoutable.swift
//  ZBAppRouterFramework
//
//  Created by Zuhaib Imtiaz on 01/03/2025.
//


// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

// MARK: - Routable Protocol
public protocol ZBRoutable: Hashable, Sendable {
    var asRoute: ZBRoute { get }
}

// MARK: - Route Enum
public enum ZBRoute: Hashable, Sendable {
    case custom(ZBAnyRoutable)
    
    public init<T: ZBRoutable>(_ routable: T) {
        self = .custom(ZBAnyRoutable(routable))
    }
}

// MARK: - AnyRoutable (Type Erasure)
public struct ZBAnyRoutable: Hashable, Sendable {
    private let _routable: any ZBRoutable
    private let hashValueClosure: @Sendable () -> Int
    private let equalsClosure: @Sendable (Any) -> Bool
    
    public init<T: ZBRoutable>(_ routable: T) {
        self._routable = routable
        self.hashValueClosure = { routable.hashValue }
        self.equalsClosure = { other in
            guard let otherRoutable = other as? T else { return false }
            return routable == otherRoutable
        }
    }
    
    public func unwrap<T: ZBRoutable>(as type: T.Type) -> T? {
        _routable as? T
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashValueClosure())
    }
    
    public static func == (lhs: ZBAnyRoutable, rhs: ZBAnyRoutable) -> Bool {
        lhs.equalsClosure(rhs._routable)
    }
}
