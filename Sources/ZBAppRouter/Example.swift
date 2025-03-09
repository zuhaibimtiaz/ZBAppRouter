//
//  Example.swift
//  ZBAppRouterFrameworkSC
//
//  Created by Zuhaib Imtiaz on 3/5/25.
//

import SwiftUI

enum AppRoute: ZBRoutable {
    case home
    case detail(String)
    case settings
    
    var asRoute: ZBRoute {
        ZBRoute(self)
    }
}

struct ContentView: View {
    var body: some View {
        ZBNavigationStackView(rootView: {
            HomeView()
        }, destinationBuilder: { (route: AppRoute) in
            switch route {
            case .home:
                HomeView()
            case .detail(let id):
                DetailView(id: id)
            case .settings:
                SettingsView()
            }
        })
    }
}

#Preview {
    ContentView()
}

struct HomeView: View {
    @Environment(\.navigate) private var navigate
    
    var body: some View {
        VStack {
            Text("Home")
            Button("Go to Detail") {
                navigate.to(ZBRoute(AppRoute.detail("Item 1")))
                navigate.snackbar("Navigating to Detail", expandedMessage: "You clicked the detail button!")
                navigate.alert(
                                    title: "Settings Change",
                                    message: "Would you like to save changes?",
                                    primaryButton: .default(
                                        Text(
                                            "Save"
                                        )
                                    ) {
                                        print(
                                            "Saved"
                                        )
                                    }
                                )
            }
            Button("Multiple Snackbars") {
                navigate.snackbar("First message", expandedMessage: "This is the first snackbar.")
                navigate.snackbar("Second message", expandedMessage: "This is the second snackbar.")
                navigate.snackbar("Third message", duration: 5.0)
            }
            Button("Reset to Settings") {
                navigate.sheet { @MainActor in
                    BottomSheetContent()
                }
                navigate.offAll(ZBRoute(AppRoute.settings))
                navigate.snackbar("Reset navigation", expandedMessage: "Stack cleared and set to Settings.")
            }
        }
    }
}

struct DetailView: View {
    let id: String
    @Environment(\.navigate) private var navigate
    
    var body: some View {
        VStack {
            Text("Detail: \(id)")
            Button("Go Back") {
                navigate.back()
                navigate.snackbar("Returned to Home", expandedMessage: "You’ve navigated back successfully.")
            }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
    }
}

@MainActor
struct BottomSheetContent: View {
    @Environment(\.navigate) private var navigate
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Bottom Sheet")
                .font(.title2)
            Text("This is a modal bottom sheet.")
            Button("Dismiss") {
                navigate.sheetDismiss()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
    }
}
