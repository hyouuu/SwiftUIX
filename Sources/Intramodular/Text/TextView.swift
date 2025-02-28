//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

#if os(macOS)
import AppKit
#endif
import Swift
import SwiftUI
#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

/// A control that displays an editable text interface.
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
public struct TextView<Label: View>: View {
    public typealias _Configuration = _TextViewConfiguration

    @Environment(\.font) private var font
    @Environment(\.preferredMaximumLayoutWidth) private var preferredMaximumLayoutWidth

    fileprivate var label: Label
    fileprivate var data: _TextViewDataBinding
    private var heightToFit: Binding<CGFloat>?
    private var selectedRange: Binding<NSRange>?
    fileprivate var configuration: _Configuration
    fileprivate var customAppKitOrUIKitClassConfiguration = _CustomAppKitOrUIKitClassConfiguration()

    @State var representableUpdater = EmptyObservableObject()

    public var body: some View {
        ZStack(alignment: .top) {
            if let _fixedSize = configuration._fixedSize {
                switch _fixedSize {
                    case (false, false):
                        XSpacer()
                    default:
                        EmptyView() // TODO: Implement
                }
            }

            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                if data.wrappedValue.isEmpty {
                    label
                        .font(configuration.cocoaFont.map(Font.init) ?? font)
                        .foregroundColor(Color(configuration.placeholderColor ?? .placeholderText))
                        .animation(.none)
                        .padding(configuration.textContainerInset.edgeInsets)
                }

                _TextView<Label>(
                    updater: representableUpdater,
                    data: data,
                    heightToFit: heightToFit,
                    selectedRange: selectedRange,
                    configuration: configuration,
                    customAppKitOrUIKitClassConfiguration: customAppKitOrUIKitClassConfiguration
                )
            }
        }
    }
}

// MARK: - Initializers

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView where Label == EmptyView {
    @_spi(Internal)
    public init(
        data: _TextViewDataBinding,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        configuration: _Configuration
    ) {
        self.label = EmptyView()
        self.data = data
        self.heightToFit = heightToFit
        self.selectedRange = selectedRange
        self.configuration = configuration
    }

    public init(
        text: Binding<String>,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = EmptyView()
        self.data = .string(text)
        self.heightToFit = heightToFit
        self.selectedRange = selectedRange
        self.configuration = .init(
            isConstant: false,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }

    public init(
        text: Binding<String?>,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            text: text.withDefaultValue(String()),
            heightToFit: heightToFit,
            selectedRange: selectedRange,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }

    public init(
        text: Binding<NSMutableAttributedString>,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = EmptyView()
        self.data = .cocoaAttributedString(
            Binding(
                get: {
                    text.wrappedValue
                },
                set: { newValue in
                    if let newValue = newValue as? NSMutableAttributedString {
                        text.wrappedValue = newValue
                    } else {
                        text.wrappedValue = newValue.mutableCopy() as! NSMutableAttributedString
                    }
                }
            )
        )
        self.heightToFit = heightToFit
        self.selectedRange = selectedRange
        self.configuration = .init(
            isConstant: false,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }

    public init(
        _ text: String,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil
    ) {
        self.label = EmptyView()
        self.data = .string(.constant(text))
        self.heightToFit = heightToFit
        self.selectedRange = selectedRange
        self.configuration = .init(
            isConstant: true,
            onEditingChanged: { _ in },
            onCommit: { }
        )
    }

    public init(
        _ text: NSAttributedString,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil
    ) {
        self.label = EmptyView()
        self.data = .cocoaAttributedString(.constant(text))
        self.heightToFit = heightToFit
        self.selectedRange = selectedRange
        self.configuration = .init(
            isConstant: true,
            onEditingChanged: { _ in },
            onCommit: { }
        )
    }

    @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    public init(
        _ text: AttributedString,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil
    ) {
        self.label = EmptyView()
        self.data = .attributedString(Binding<AttributedString>.constant(text))
        self.heightToFit = heightToFit
        self.selectedRange = selectedRange
        self.configuration = .init(
            isConstant: true,
            onEditingChanged: { _ in },
            onCommit: { }
        )
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView: DefaultTextInputType where Label == Text {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        heightToFit: Binding<CGFloat>? = nil,
        selectedRange: Binding<NSRange>? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = Text(title)
        self.data = .string(text)
        self.heightToFit = heightToFit
        self.selectedRange = selectedRange
        self.configuration = .init(
            isConstant: false,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }

    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String?>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text.withDefaultValue(String()),
            heightToFit: nil,
            selectedRange: nil,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }
}

// MARK: - Modifiers

@available(macOS 11.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func _fixedSize(horizontal: Bool, vertical: Bool) -> Self {
        then {
            $0.configuration._fixedSize = (horizontal, vertical)
        }
    }
}

@available(macOS 11.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func _customAppKitOrUIKitClass(
        _ type: AppKitOrUIKitTextView.Type
    ) -> Self {
        then({ $0.customAppKitOrUIKitClassConfiguration = .init(class: type) })
    }

    public func _customAppKitOrUIKitClass<T: AppKitOrUIKitTextView>(
        _ type: T.Type,
        update: @escaping _CustomAppKitOrUIKitClassConfiguration.UpdateOperation<T>
    ) -> Self {
        then({ $0.customAppKitOrUIKitClassConfiguration = .init(class: type, update: update) })
    }

    @_disfavoredOverload
    public func _customAppKitOrUIKitClass<T: AppKitOrUIKitTextView>(
        _ type: T.Type,
        update: @escaping (T) -> Void
    ) -> Self {
        _customAppKitOrUIKitClass(type) { view, _ in
            update(view)
        }
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func onDeleteBackward(perform action: @escaping () -> Void) -> Self {
        then({ $0.configuration.onDeleteBackward = action })
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func isInitialFirstResponder(_ isInitialFirstResponder: Bool) -> Self {
        then({ $0.configuration.isInitialFirstResponder = isInitialFirstResponder })
    }

    public func focused(_ isFocused: Binding<Bool>) -> Self {
        then({ $0.configuration.isFocused = isFocused })
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public func autocapitalization(
        _ autocapitalization: UITextAutocapitalizationType
    ) -> Self {
        then({ $0.configuration.autocapitalization = autocapitalization })
    }
    #endif

    public func foregroundColor(
        _ foregroundColor: Color
    ) -> Self {
        then({ $0.configuration.cocoaForegroundColor = foregroundColor.toAppKitOrUIKitColor() })
    }

    @_disfavoredOverload
    public func foregroundColor(
        _ foregroundColor: AppKitOrUIKitColor
    ) -> Self {
        then({ $0.configuration.cocoaForegroundColor = foregroundColor })
    }

    public func placeholderColor(
        _ foregroundColor: Color
    ) -> Self {
        then({ $0.configuration.placeholderColor = foregroundColor.toAppKitOrUIKitColor() })
    }

    @_disfavoredOverload
    public func placeholderColor(
        _ placeholderColor: AppKitOrUIKitColor
    ) -> Self {
        then({ $0.configuration.placeholderColor = placeholderColor })
    }

    public func tint(
        _ tint: Color
    ) -> Self {
        then({ $0.configuration.tintColor = tint.toAppKitOrUIKitColor() })
    }

    @_disfavoredOverload
    public func tint(
        _ tint: AppKitOrUIKitColor
    ) -> Self {
        then({ $0.configuration.tintColor = tint })
    }

    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public func linkForegroundColor(
        _ linkForegroundColor: Color?
    ) -> Self {
        then({ $0.configuration.linkForegroundColor = linkForegroundColor?.toAppKitOrUIKitColor() })
    }
    #endif

    public func font(
        _ font: Font
    ) -> Self {
        then {
            do {
                $0.configuration.cocoaFont = try font.toAppKitOrUIKitFont()
            } catch {
                // print(error)
            }
        }
    }

    @_disfavoredOverload
    public func font(
        _ font: AppKitOrUIKitFont?
    ) -> Self {
        then({ $0.configuration.cocoaFont = font })
    }

    public func kerning(
        _ kerning: CGFloat
    ) -> Self {
        then({ $0.configuration.kerning = kerning })
    }

    @_disfavoredOverload
    public func textContainerInset(
        _ textContainerInset: AppKitOrUIKitInsets
    ) -> Self {
        then({ $0.configuration.textContainerInset = textContainerInset })
    }

    public func textContainerInset(
        _ textContainerInset: EdgeInsets
    ) -> Self {
        then({ $0.configuration.textContainerInset = AppKitOrUIKitInsets(textContainerInset) })
    }

    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public func textContentType(
        _ textContentType: UITextContentType?
    ) -> Self {
        then({ $0.configuration.textContentType = textContentType })
    }
    #endif
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func editable(
        _ editable: Bool
    ) -> Self {
        then({ $0.configuration.isEditable = editable })
    }

    public func isSelectable(
        _ isSelectable: Bool
    ) -> Self {
        then({ $0.configuration.isSelectable = isSelectable })
    }

    public func selectEndOfTextUponFocus(_ selectEndOfTextUponFocus: Bool) -> Self {
        then({ $0.configuration.selectEndOfTextUponFocus = selectEndOfTextUponFocus })
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func interceptReturn(_ interceptReturn: Bool) -> Self {
        then({ $0.configuration.interceptReturn = interceptReturn })
    }

    public func dismissKeyboardOnReturn(
        _ dismissKeyboardOnReturn: Bool
    ) -> Self {
        then({ $0.configuration.dismissKeyboardOnReturn = dismissKeyboardOnReturn })
    }

    public func enablesReturnKeyAutomatically(
        _ enablesReturnKeyAutomatically: Bool
    ) -> Self {
        then({ $0.configuration.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically })
    }

    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public func keyboardType(
        _ keyboardType: UIKeyboardType
    ) -> Self {
        then({ $0.configuration.keyboardType = keyboardType })
    }

    public func returnKeyType(
        _ returnKeyType: UIReturnKeyType
    ) -> Self {
        then({ $0.configuration.returnKeyType = returnKeyType })
    }
    #endif
}

// MARK: - Deprecated

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    @available(*, deprecated)
    public func isFirstResponder(
        _ isFirstResponder: Bool
    ) -> Self {
        then({ $0.configuration.isFirstResponder = isFirstResponder })
    }

    @available(*, deprecated, renamed: "TextView.editable(_:)")
    public func isEditable(
        _ isEditable: Bool
    ) -> Self {
        self.editable(isEditable)
    }

}

#endif
