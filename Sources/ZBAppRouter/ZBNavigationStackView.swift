//
//  ZBNavigationStackView.swift
//  ZBAppRouterFramework
//
//  Created by Zuhaib Imtiaz on 05/03/2025.
//
import SwiftUI

// MARK: - Navigation Stack View
@MainActor
public struct ZBNavigationStackView<RouteType: ZBRoutable, Content: View>: View {
    @State private var routes: [RouteType] = []
    @State private var resultHandler: (@Sendable (Any?) -> Void)?
    @State private var snackbarQueue: [ToastViewData] = []  // Queue for multiple snackbars
    @State private var alertData: AlertData?  // State for alert
    @State private var sheetData: SheetData?  // State for sheet, updated to use generic type
    private let rootView: Content
    private let destinationBuilder: (RouteType) -> any View
    
    public init(
        @ViewBuilder rootView: () -> Content,
        @ViewBuilder destinationBuilder: @escaping (RouteType) -> any View
    ) {
        self.rootView = rootView()
        self.destinationBuilder = destinationBuilder
    }
    
    public var body: some View {
        NavigationStack(path: $routes) {
            rootView
                .navigationDestination(for: RouteType.self) { route in
                    AnyView(destinationBuilder(route))
                }
                .alert(item: $alertData) { alert in
                    Alert(
                        title: Text(alert.title),
                        message: alert.message.map { Text($0) },
                        primaryButton: alert.primaryButton,
                        secondaryButton: alert.secondaryButton ?? .cancel()
                    )
                }
                .sheet(item: $sheetData) { sheet in
                    sheet.content()
                        .presentationDetents(sheet.isFullScreen ? [.large] : [.medium, .large])
                        .presentationDragIndicator(.visible)
                        .interactiveDismissDisabled(sheet.swipeToDismiss)
                }
        }
        .overlay(alignment: .bottom) {
            ToastView(queue: $snackbarQueue)
        }
        .environment(\.navigate, ZBNavigationAction { navigationType in
            ZBNavigationHandler<RouteType>.handleNavigation(
                navigationType,
                routes: &routes,
                resultHandler: &resultHandler,
                snackbarQueue: &snackbarQueue,  // Pass queue
                alertData: &alertData,  // Pass alert state
                sheetData: &sheetData  // Pass sheet state
            )
        })
    }
}

//// MARK: - Navigation Stack View
//@MainActor
//public struct ZBNavigationStackView<RouteType: ZBRoutable, Content: View>: View {
//    @State private var routes: [RouteType] = []
//    @State private var resultHandler: (@Sendable (Any?) -> Void)?
//    private let rootView: Content
//    private let destinationBuilder: (RouteType) -> any View
//
//    public init(
//        @ViewBuilder rootView: () -> Content,
//        @ViewBuilder destinationBuilder: @escaping (RouteType) -> any View
//    ) {
//        self.rootView = rootView()
//        self.destinationBuilder = destinationBuilder
//    }
//
//    public var body: some View {
//        NavigationStack(path: $routes) {
//            rootView
//                .navigationDestination(for: RouteType.self) { route in
//                    AnyView(destinationBuilder(route))
//                }
//        }
//        .environment(\.navigate, ZBNavigationAction { navigationType in
//            ZBNavigationHandler<RouteType>.handleNavigation(navigationType, routes: &routes, resultHandler: &resultHandler)
//        })
//    }
//}
