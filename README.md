
# ZBNavigationStack

A flexible and type-safe navigation stack solution for SwiftUI applications. `ZBNavigationStack` provides a protocol-based routing system with support for custom navigation actions, type-erased routes, and result handling.

## Features
- **Type-Safe Routing**: Define routes using the `ZBRoutable` protocol.
- **Custom Navigation**: Push, pop, replace, and navigate with advanced control (e.g., `offUntil`, `toWithResult`).
- **Result Handling**: Pass data back when navigating back.
- **SwiftUI Integration**: Built with SwiftUI's `NavigationStack` and environment values.
- **Thread Safety**: Uses `Sendable` for concurrency safety.

## Requirements
- iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+
- Swift 5.9+
- SwiftUI

## Installation

### Swift Package Manager
Add `ZBNavigationStack` to your project via Swift Package Manager:

1. In Xcode, go to `File > Add Packages`.
5. Enter https://github.com/zuhaib.imtiaz/ZBNavigationStack.git

Or add it directly to your `Package.swift`:

```swift
 .package(url: "https://github.com/zuhaib.imtiaz/ZBNavigationStack.git", from: "1.0.0")
```
## List of Navigation Actions

The `ZBNavigationAction` struct provides the following methods for navigation:

- **`to(_ route: ZBRoute)`**: Pushes a new route onto the navigation stack.
- **`toNamed(_ route: ZBRoute)`**: Pushes a new route with a named identifier (similar to `to`, but can be used for specific naming conventions).
- **`back(result: (any Sendable)? = nil)`**: Pops the current route off the stack, optionally passing a result to the previous view.
- **`off(_ route: ZBRoute)`**: Replaces the current route with a new one, removing the previous route.
- **`offNamed(_ route: ZBRoute)`**: Replaces the entire stack with a single named route.
- **`offAll(_ route: ZBRoute)`**: Clears the stack and pushes a new route.
- **`offAllNamed(_ route: ZBRoute)`**: Clears the stack and sets a single named route.
- **`offAllToRoot()`**: Clears the entire stack, returning to the root view.
- **`offUntil(_ route: ZBRoute, until: @escaping (ZBRoute) -> Bool)`**: Pops routes until a condition is met, then pushes a new route.
- **`offNamedUntil(_ route: ZBRoute, until: @escaping (ZBRoute) -> Bool)`**: Pops routes until a condition is met, then sets a named route.
- **`until(_ predicate: @escaping (ZBRoute) -> Bool)`**: Pops routes until a condition is met, without pushing a new route.
- **`toWithResult(_ route: ZBRoute, completion: @escaping (Any?) -> Void)`**: Pushes a route and provides a completion handler to receive a result when the route is popped.

## Usage
### Defining Routes
Start by importing `ZBNavigationStack` and defining your routes by conforming to the `ZBRoutable` protocol:

```swift
import ZBNavigationStack

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
import ZBNavigationStack

struct ContentView: View {
    var body: some View {
        ZBNavigationStackView<AppRoute, some View>(
            rootView: {
                HomeView()
            },
            destinationBuilder: { route in
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
            Button("Push to Settings with Name") {
                navigate.toNamed(ZBRoute(AppRoute.settings))
            }
            Button("Go Back") {
                navigate.back()
            }
            Button("Replace with Detail") {
                navigate.off(ZBRoute(AppRoute.detail(id: "456")))
            }
            Button("Replace Stack with Settings") {
                navigate.offNamed(ZBRoute(AppRoute.settings))
            }
            Button("Clear and Set Home") {
                navigate.offAll(ZBRoute(AppRoute.home))
            }
            Button("Clear and Set Settings") {
                navigate.offAllNamed(ZBRoute(AppRoute.settings))
            }
            Button("Clear Stack to Root") {
                navigate.offAllToRoot()
            }
            Button("Push Detail Until Home") {
                navigate.offUntil(ZBRoute(AppRoute.detail(id: "789"))) { route in
                    route == ZBRoute(AppRoute.home)
                }
            }
            Button("Push Settings Until Home (Named)") {
                navigate.offNamedUntil(ZBRoute(AppRoute.settings)) { route in
                    route == ZBRoute(AppRoute.home)
                }
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
        }
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
