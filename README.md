
# ZBAppRouter

A flexible and type-safe navigation stack solution for SwiftUI applications. `ZBAppRouter` provides a protocol-based routing system with support for custom navigation actions, type-erased routes, result handling, and advanced UI features like toasts (snackbars), alerts, and sheets.

## Features
- **Type-Safe Routing**: Define routes using the `ZBRoutable` protocol.
- **Custom Navigation**: Push, pop, replace, and navigate with advanced control (e.g., `offUntil`, `toWithResult`).
- **Result Handling**: Pass data back when navigating back.
- **SwiftUI Integration**: Built with SwiftUI's `NavigationStack` and environment values.
- **Thread Safety**: Uses `Sendable` for concurrency safety in Swift 6.
- **UI Enhancements**: Supports toasts (snackbars), alerts, and sheets for rich user feedback and modals.

## Requirements
- iOS 16.0+
- Swift 5.9+
- SwiftUI

## Installation

### Swift Package Manager
Add `ZBAppRouter` to your project via Swift Package Manager:

1. In Xcode, go to `File > Add Packages`.
2. Enter `https://github.com/zuhaibimtiaz/ZBAppRouter.git`

Or add it directly to your `Package.swift`:

```swift
.package(url: "https://github.com/zuhaibimtiaz/ZBAppRouter.git", from: "1.0.3")
```

## List of Navigation Actions

The `ZBNavigationAction` struct provides the following methods for navigation, feedback, and modals:

- **`to(_ route: ZBRoute)`**: Pushes a new route onto the navigation stack.
- **`back(result: (any Sendable)? = nil)`**: Pops the current route off the stack, optionally passing a result to the previous view.
- **`off(_ route: ZBRoute)`**: Replaces the current route with a new one, removing the previous route.
- **`offAll(_ route: ZBRoute)`**: Clears the stack and pushes a new route.
- **`offAllToRoot()`**: Clears the entire stack, returning to the root view.
- **`offUntil(_ route: ZBRoute, until: @escaping (ZBRoute) -> Bool)`**: Pops routes until a condition is met, then pushes a new route.
- **`until(_ predicate: @escaping (ZBRoute) -> Bool)`**: Pops routes until a condition is met, without pushing a new route.
- **`toWithResult(_ route: ZBRoute, completion: @escaping (Any?) -> Void)`**: Pushes a route and provides a completion handler to receive a result when the route is popped.
- **`snackbar(_ message: String, expandedMessage: String? = nil, duration: Double = 3.0)`**: Displays a toast/snackbar at the bottom of the screen or current view, with an optional expanded message and custom duration (default 3.0 seconds). Snackbars support swipe-to-dismiss (right) and can stack upward with dynamic widths (90%, 85%, 80%, etc.) and a capsule shape.
- **`alert(title: String, message: String? = nil, primaryButton: Alert.Button, secondaryButton: Alert.Button? = nil)`**: Presents a modal alert with a title, optional message, and customizable buttons (primary and optional secondary). Buttons can have roles (e.g., `.cancel`, `.destructive`) and actions executed on the main actor.
- **`sheet<Content: View>(content: @escaping @Sendable () -> Content, isFullScreen: Bool = false)`**: Presents a modal sheet (bottom sheet by default, or full-screen if `isFullScreen` is `true`) with custom content. Sheets support a drag indicator but are restricted from swipe-to-dismiss, requiring programmatic dismissal via `sheetDismiss()`.
- **`sheetDismiss()`**: Programmatically dismisses the currently presented sheet.

## Usage
### Defining Routes
Start by importing `ZBAppRouter` and defining your routes by conforming to the `ZBRoutable` protocol:

```swift
import ZBAppRouter

enum AppRoute: ZBRoutable {
    case home
    case detail(id: String)
    case settings
    
    var asRoute: ZBRoute {
        ZBRoute(self)
    }
}
```

### Setting Up the Navigation Stack

Create a navigation stack using `ZBNavigationStackView`. Provide a root view and a destination builder to handle route destinations:
```swift
import SwiftUI
import ZBAppRouterFramework

struct ContentView: View {
    var body: some View {
        ZBNavigationStackView<AppRoute, some View>(
            rootView: {
                HomeView()
            },
            destinationBuilder: { (route: AppRoute) in
                switch route {
                case .home:
                    HomeView()
                case .detail(let id):
                    DetailView(id: id)
                case .settings:
                    SettingsView()
                }
            }
        )
    }
}

struct HomeView: View {
    var body: some View {
        Text("Home Screen")
    }
}

struct DetailView: View {
    let id: String
    var body: some View {
        Text("Detail Screen: \(id)")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings Screen")
    }
}
```

### Example: Using ZBNavigationAction

- Here’s an example demonstrating all the navigation actions provided by `ZBNavigationAction`:
```swift
struct HomeView: View {
    @Environment(\.navigate) private var navigate
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Push to Detail") {
                navigate.to(ZBRoute(AppRoute.detail(id: "123")))
            }
            Button("Go Back") {
                navigate.back()
            }
            Button("Replace with Detail") {
                navigate.off(ZBRoute(AppRoute.detail(id: "456")))
            }
            Button("Clear and Set Home") {
                navigate.offAll(ZBRoute(AppRoute.home))
            }
            Button("Clear Stack to Root") {
                navigate.offAllToRoot()
            }
            Button("Pop Until Home") {
                navigate.until { route in
                    route == ZBRoute(AppRoute.home)
                }
            }
            Button("Push Detail with Result") {
                navigate.toWithResult(ZBRoute(AppRoute.detail(id: "999"))) { result in
                    print("Result from Detail: \(result ?? "nil")")
                }
            }
            Button("Show Toast") {
                navigate.snackbar("Hello, Toast!", expandedMessage: "This is an expanded message.", duration: 4.0)
            }
            Button("Show Alert") {
                navigate.alert(
                    title: "Confirm Action",
                    message: "Are you sure you want to proceed?",
                    primaryButton: .default(Text("Yes"), action: { print("Saved") }),
                    secondaryButton: .cancel()
                )
            }
            Button("Show Bottom Sheet") {
                navigate.sheet { @MainActor in
                    BottomSheetContent()
                }
            }
            Button("Show Full Screen Sheet") {
                navigate.sheet { @MainActor in
                    FullScreenSheetContent()
                } isFullScreen: true
            }
        }
        .padding()
    }
}

struct DetailView: View {
    @Environment(\.navigate) private var navigate
    let id: String
    
    var body: some View {
        VStack {
            Text("Detail ID: \(id)")
            Button("Back with Result") {
                navigate.back(result: "Completed Detail \(id)")
            }
            Button("Show Toast") {
                navigate.snackbar("Detail Toast", expandedMessage: "From Detail \(id)!", duration: 3.0)
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.navigate) private var navigate
    
    var body: some View {
        VStack {
            Text("Settings Screen")
            Button("Back") {
                navigate.back()
            }
            Button("Show Alert") {
                navigate.alert(
                    title: "Settings Change",
                    message: "Would you like to save changes?",
                    primaryButton: .default(Text("Yes"), action: { print("Saved") }),
                    secondaryButton: .cancel()
                )
            }
        }
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
            Button("Show Toast") {
                navigate.snackbar("Sheet Toast", expandedMessage: "From bottom sheet!", duration: 3.0)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
    }
}

@MainActor
struct FullScreenSheetContent: View {
    @Environment(\.navigate) private var navigate
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Full Screen Sheet")
                .font(.title)
            Text("This is a full-screen modal sheet.")
            Button("Dismiss") {
                navigate.sheetDismiss()
            }
            Button("Show Toast") {
                navigate.snackbar("Full Screen Toast", expandedMessage: "From full-screen sheet!", duration: 3.0)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
```
### Advanced Navigation Options

`ZBNavigationAction` provides a variety of navigation methods:

- Push a new route:
```swift
navigate.to(ZBRoute(AppRoute.settings))
```
- Pop back with a result:
 ```swift
navigate.back(result: "Operation completed")
```
- Replace the current route:
```swift
navigate.off(ZBRoute(AppRoute.detail(id: "456")))
```
- Clear the stack and set a new route:
```swift
navigate.offAll(ZBRoute(AppRoute.home))
```
- Navigate and expect a result:
 ```swift
navigate.toWithResult(ZBRoute(AppRoute.detail(id: "789"))) { result in
    print("Result received: \(result ?? "nil")")
}
```
- Pop until a condition is met:
 ```swift
navigate.until { route in
    route == ZBRoute(AppRoute.home)
}
```
- Show a toast/snackbar:
```swift
navigate.snackbar("Success!", expandedMessage: "Operation completed successfully.", duration: 4.0)
```
- Show an alert:
```swift
navigate.alert(
    title: "Confirm Action",
    message: "Are you sure?",
    primaryButton:.default(Text("Yes"), action: { print("Saved") }),
    secondaryButton: .cancel()

)
```
- Show a bottom sheet:
```swift
navigate.sheet {
    BottomSheetContent()
}
```
- Dismiss a sheet:
```swift
navigate.sheetDismiss()
```
### Handling Results
- Pass data back to the previous view when navigating back:
 ```swift
struct DetailView: View {
    @Environment(\.navigate) private var navigate
    let id: String
    
    var body: some View {
        Button("Back with Result") {
            navigate.back(result: "Detail \(id) completed")
        }
    }
}
```
## API Overview
### Protocols

- **`ZBRoutable`**: Conform your route types to this protocol to integrate with the navigation system.
### Core Types

- **`ZBRoute`**: An enum representing a route, wrapping any ZBRoutable type.
- **`ZBAnyRoutable`**: A type-erased wrapper for ZBRoutable types, ensuring hashability and equality.
### Views

- **`ZBNavigationStackView<RouteType: ZBRoutable, Content: View>`**: The main navigation stack component.
Navigation Actions

- **`ZBNavigationAction`**: Provides methods like `to`, `back`, `off`, `offUntil`, etc., for controlling navigation.
### Inspiration
- Inspired by Flutter GetX Package

