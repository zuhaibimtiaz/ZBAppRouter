//
//  ToastViewData.swift
//  ZBAppRouterFrameworkSC
//
//  Created by Zuhaib Imtiaz on 05/03/2025.
//
import SwiftUI

// MARK: - ToastView Model
public struct ToastViewData: Identifiable {
    public let id = UUID()
    public let message: String
    public let expandedMessage: String?  // Optional detailed content
    public let duration: Double  // In seconds
    
    public init(message: String, expandedMessage: String? = nil, duration: Double = 3.0) {
        self.message = message
        self.expandedMessage = expandedMessage
        self.duration = duration
    }
}

// MARK: - Toast View
public struct ToastView: View {
    @Binding var queue: [ToastViewData]
    @State private var isExpandedList = false
    
    private var layout: AnyLayout {
        if queue.count == 1 || isExpandedList {
            return AnyLayout(VStackLayout(spacing: 8))  // Expanded or single snackbar
        } else {
            return AnyLayout(ZStackLayout(alignment: .bottom))  // Collapsed multiple snackbars
        }
    }
    
    public var body: some View {
        if !queue.isEmpty {
            layout {
                ForEach(queue.reversed()) { snackbar in  // Reverse for ZStack top-down stacking
                    snackbarContent(for: snackbar)
                        .frame(width: queue.count > 1 && !isExpandedList ? calculateWidth(for: queue.firstIndex(where: { $0.id == snackbar.id }) ?? 0) : nil)  // Dynamic width in ZStack
                        .offset(y: queue.count > 1 && !isExpandedList ? calculateOffset(for: queue.firstIndex(where: { $0.id == snackbar.id }) ?? 0) : 0)  // Adjusted offset in ZStack
                        .padding(.horizontal,12)
                }
            }
            .padding(.bottom, 20)  // Keep bottom padding for spacing from screen edge
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onEnded { value in
                        if value.translation.height > 50 && isExpandedList && queue.count > 1 {  // Swipe down to collapse
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpandedList = false
                            }
                        }
                    }
            )
            .onTapGesture {
                if !isExpandedList && queue.count > 1 {  // Tap to expand only in ZStack mode
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpandedList = true
                    }
                }
            }
        }
    }
    
    private func calculateWidth(for index: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let widths: [CGFloat] = [0.9, 0.85, 0.8, 0.75, 0.7]  // Percentages for 1st, 2nd, 3rd, etc.
        let maxIndex = widths.count - 1
        let effectiveIndex = min(index, maxIndex)
        return screenWidth * widths[effectiveIndex]
    }
    
    private func calculateOffset(for index: Int) -> CGFloat {
        // Move snackbars upward, reducing the negative offset (e.g., -10, -20, -30 instead of -20 per snackbar)
        return CGFloat(index + 1) > 3 ? 3 * -10 : CGFloat(index + 1) * -10 // Smaller negative offset for a higher position
    }
    
    @ViewBuilder
    private func snackbarContent(for data: ToastViewData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(data.message)
                .font(.body)
            if data.expandedMessage != nil && isExpandedList {
                Text(data.expandedMessage ?? "")
                    .font(.caption)
                    .opacity(isExpandedList ? 1 : 0)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(16)  // Increased for capsule shape
        .clipShape(Capsule())  // Ensures a pill-like shape (capsule)
        .transition(.move(edge: .bottom))
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .global)
                .onEnded { value in
                    if value.translation.width > 50 {  // Swipe right to dismiss
                        withAnimation {
                            queue.removeAll(where: { $0.id == data.id })
                        }
                    }
                }
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + data.duration) {
                withAnimation {
                    queue.removeAll(where: { $0.id == data.id })
                }
            }
        }
    }
}
