//
//  NavigationAction.swift
//  ZBAppRouterFramework
//
//  Created by Zuhaib Imtiaz on 05/03/2025.
//
import SwiftUI

// MARK: - ZBNavigationAction
@MainActor // Entire struct is MainActor-isolated
public struct ZBNavigationAction {
    private let action: @MainActor (ZBNavigationType) -> Void
    
    public init(action: @escaping @MainActor (ZBNavigationType) -> Void) {
        self.action = action
    }
    
    public func to(_ route: ZBRoute) { action(.to(route)) }
    public func back(result: (any Sendable)? = nil) { action(.back(result: result)) }
    public func off(_ route: ZBRoute) { action(.off(route)) }
    public func offAll(_ route: ZBRoute) { action(.offAll(route)) }
    public func offAllToRoot() { action(.offAllToRoot) }
    public func offUntil(_ route: ZBRoute, until predicate: @escaping @Sendable (ZBRoute) -> Bool) { action(.offUntil(route, predicate)) }
    public func until(_ predicate: @escaping @Sendable (ZBRoute) -> Bool) { action(.until(predicate)) }
    public func toWithResult(_ route: ZBRoute, completion: @escaping @Sendable (Any?) -> Void) { action(.toWithResult(route, completion: completion)) }
    public func snackbar(_ message: String, expandedMessage: String? = nil, duration: Double = 3.0) {
        action(.snackbar(message, expandedMessage: expandedMessage, duration: duration))
    }
    public func alert(
        title: String,
        message: String? = nil,
        primaryButton: Alert.Button,
        secondaryButton: Alert.Button? = nil
    ) {
        let alertData = AlertData(
            title: title,
            message: message,
            primaryButton: primaryButton,
            secondaryButton: secondaryButton
        )
        action(.alert(alertData))
    }
    
    public func sheet<Content: View>(
        @ViewBuilder content: @escaping @Sendable () -> Content, // Removed @MainActor from parameter
        isFullScreen: Bool = false
    ) {
        // Since ZBNavigationAction is @MainActor, this closure is executed on the main actor
        Task { @MainActor in
            let sheetData = SheetData(content: content, isFullScreen: isFullScreen)
            action(.sheet(sheetData, isFullScreen: isFullScreen))
        }
    }
    
    public func sheetDismiss() {
        Task { @MainActor in
            action(.sheetDismiss)
        }
    }
    
    public enum ZBNavigationType: Sendable {
        case to(ZBRoute)
        case back(result: (any Sendable)?)
        case off(ZBRoute)
        case offAll(ZBRoute)
        case offAllToRoot
        case offUntil(ZBRoute, @Sendable (ZBRoute) -> Bool)
        case until(@Sendable (ZBRoute) -> Bool)
        case toWithResult(ZBRoute, completion: @Sendable (Any?) -> Void)
        case snackbar(String, expandedMessage: String?, duration: Double)
        case alert(AlertData)
        case sheet(SheetData, isFullScreen: Bool)
        case sheetDismiss
        
        var route: ZBRoute? {
            switch self {
            case .to(let route),
                 .off(let route),
                 .offAll(let route),
                 .offUntil(let route, _),
                 .toWithResult(let route, _):
                return route
            case .back,
                 .until,
                 .offAllToRoot,
                 .snackbar,
                 .alert,
                 .sheet,
                 .sheetDismiss:
                return nil
            }
        }
    }
}

// MARK: - ZBNavigationHandler
@MainActor
public struct ZBNavigationHandler<T: ZBRoutable> {
    public static func handleNavigation(
        _ navigationType: ZBNavigationAction.ZBNavigationType,
        routes: inout [T],
        resultHandler: inout (@Sendable (Any?) -> Void)?,
        snackbarQueue: inout [ToastViewData],
        alertData: inout AlertData?,
        sheetData: inout SheetData?  // Add sheet state
    ) {
        switch navigationType {
        case .to(let route):
            if let routable = extractRoutable(route) {
                routes.append(routable)
            }
            
        case .back(let result):
            if !routes.isEmpty {
                routes.removeLast()
                resultHandler?(result)
                resultHandler = nil
            }
            
        case .off(let route):
            if let routable = extractRoutable(route) {
                if !routes.isEmpty { routes.removeLast() }
                routes.append(routable)
            }
            
        case .offAll(let route):
            if let routable = extractRoutable(route) {
                routes = [routable]
            }
            
        case .offAllToRoot:
            routes.removeAll()
            
        case .offUntil(let route, let predicate):
            if let routable = extractRoutable(route) {
                while !routes.isEmpty {
                    let lastRoute = routes.last!.asRoute
                    if predicate(lastRoute) {
                        break
                    }
                    routes.removeLast()
                }
                routes.append(routable)
            }
            
        case .until(let predicate):
            while !routes.isEmpty {
                let lastRoute = routes.last!.asRoute
                if predicate(lastRoute) {
                    break
                }
                routes.removeLast()
            }
            
        case .toWithResult(let route, let completion):
            if let routable = extractRoutable(route) {
                resultHandler = completion
                routes.append(routable)
            }
            
        case .snackbar(let message, let expandedMessage, let duration):
            snackbarQueue.append(ToastViewData(message: message, expandedMessage: expandedMessage, duration: duration))
            
        case .alert(let alertModel):
            alertData = alertModel
        case .sheet(let sheetModel, _):
            sheetData = sheetModel
        case .sheetDismiss:
            sheetData = nil
        }
    }
    
    private static func extractRoutable(_ route: ZBRoute) -> T? {
        switch route {
        case .custom(let anyRoutable):
            return anyRoutable.unwrap(as: T.self)
        }
    }
}
