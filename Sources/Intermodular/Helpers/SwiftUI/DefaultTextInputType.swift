//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A text-input type where `Self.Label == SwiftUI.Text`.
public protocol DefaultTextInputType {    
    init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        heightToFit: Binding<CGFloat>?,
        selectedRange: Binding<NSRange>?,
        onEditingChanged: @escaping (Bool) -> Void,
        onCommit: @escaping () -> Void
    )
    
    init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        heightToFit: Binding<CGFloat>?,
        selectedRange: Binding<NSRange>?,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void
    )
}

// MARK: - Extensions

extension DefaultTextInputType {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text,
            heightToFit: heightToFit,
            selectedRange: selectedRange,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String?>,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text.withDefaultValue(String()),
            heightToFit: heightToFit,
            selectedRange: selectedRange,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String?>,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String>,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text,
            heightToFit: heightToFit,
            selectedRange: selectedRange,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String?>,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text,
            heightToFit: heightToFit,
            selectedRange: selectedRange,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String>,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text,
            heightToFit: heightToFit,
            selectedRange: selectedRange,
            onEditingChanged: { _ in },
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String?>,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text,
            heightToFit: heightToFit,
            selectedRange: selectedRange,
            onEditingChanged: { _ in },
            onCommit: onCommit
        )
    }
}

// MARK: - Conformances

extension TextField: DefaultTextInputType where Label == Text {
    public init<S>(
        _ title: S,
        text: Binding<String>,
        heightToFit: Binding<CGFloat>?,
        selectedRange: Binding<NSRange>?,
        onEditingChanged: @escaping (Bool) -> Void,
        onCommit: @escaping () -> Void
    ) where S : StringProtocol {
        self.init(title, text: text, onEditingChanged: onEditingChanged, onCommit: onCommit)
    }
}

extension SecureField where Label == Text {
    public init(
        text: Binding<String>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text,
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String?>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            String(),
            text: text.withDefaultValue(String()),
            onCommit: onCommit
        )
    }
}
