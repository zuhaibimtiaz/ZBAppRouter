//
//  AlertData.swift
//  ZBAppRouterFrameworkSC
//
//  Created by Zuhaib Imtiaz on 05/03/2025.
//
import SwiftUI

// MARK: - Alert Model
@MainActor
public struct AlertData: Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let message: String?
    public let primaryButton: Alert.Button
    public let secondaryButton: Alert.Button?
    
    public init(
        title: String,
        message: String? = nil,
        primaryButton: Alert.Button,
        secondaryButton: Alert.Button? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}
