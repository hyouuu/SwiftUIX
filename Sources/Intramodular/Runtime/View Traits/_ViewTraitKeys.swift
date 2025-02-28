//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct _ViewTraitKeys {
    public init() {
        
    }
}

// MARK: - Supplementary

extension View {
    public func _trait<TraitKey: _ViewTraitKey>(
        _ key: KeyPath<_ViewTraitKeys, TraitKey.Type>,
        _ value: TraitKey.Value
    ) -> some View {
        _trait(_ViewTraitKeys()[keyPath: key], value)
    }
    
    public func _trait<T>(
        _ key: T.Type,
        _ value: T
    ) -> some View {
        _trait(_TypeToViewTraitKeyAdaptor<T>.self, value)
    }
}

// MARK: - Auxiliary

extension _VariadicViewChildren.Subview {
    @dynamicMemberLookup
    @frozen
    public struct TraitsView {
        public var base: _VariadicViewChildren.Subview
        
        @_transparent
        public init(base: _VariadicViewChildren.Subview) {
            self.base = base
        }
        
        @inlinable
        public subscript<Key: _ViewTraitKey>(
            dynamicMember keyPath: KeyPath<_ViewTraitKeys, Key.Type>
        ) -> Key.Value {
            base[trait: keyPath]
        }
        
        @inlinable
        public subscript<Key: _ViewTraitKey>(
            dynamicMember keyPath: WritableKeyPath<_ViewTraitKeys, Key.Type>
        ) -> Key.Value {
            get {
                base[trait: keyPath]
            } set {
                base[trait: keyPath] = newValue
            }
        }
    }
    
    @_transparent
    public var traits: TraitsView {
        get {
            TraitsView(base: self)
        } set {
            self = newValue.base
        }
    }
}

public struct _TypeToViewTraitKeyAdaptor<T>: _ViewTraitKey {
    public typealias Value = T?
    
    public static var defaultValue: T? {
        nil
    }
}
