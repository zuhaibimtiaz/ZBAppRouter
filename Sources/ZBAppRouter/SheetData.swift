//
//  SheetData.swift
//  ZBAppRouterFrameworkSC
//
//  Created by Zuhaib Imtiaz on 05/03/2025.
//
import SwiftUI

// MARK: - Sheet Model
@MainActor
public struct SheetData: Identifiable, Sendable {
    public let id = UUID()
    public let content: @Sendable () -> AnyView  // Ensure the closure is Sendable
    public let isFullScreen: Bool
    public let swipeToDismiss: Bool
    
    public init(
        @ViewBuilder content: @escaping @Sendable () -> some View,
        isFullScreen: Bool = false,
        swipeToDismiss: Bool = true
    ) {
        self.content = { AnyView(content()) }
        self.isFullScreen = isFullScreen
        self.swipeToDismiss = swipeToDismiss
    }
}
