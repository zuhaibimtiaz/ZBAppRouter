//
//  NavigateEnvironmentKey.swift
//  ZBAppRouterFramework
//
//  Created by Zuhaib Imtiaz on 05/03/2025.
//

import SwiftUI

// MARK: - Environment Key
//@MainActor
public struct ZBNavigateEnvironmentKey: @preconcurrency EnvironmentKey {
    @MainActor public static var defaultValue: ZBNavigationAction = ZBNavigationAction { _ in }
}

extension EnvironmentValues {
    public var navigate: ZBNavigationAction {
        get { self[ZBNavigateEnvironmentKey.self] }
        set { self[ZBNavigateEnvironmentKey.self] = newValue }
    }
}
